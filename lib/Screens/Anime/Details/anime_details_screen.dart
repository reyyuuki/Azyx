// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ui';

import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Screens/Anime/Details/tabs/add_to_list_floater.dart';
import 'package:azyx/Screens/Anime/Details/tabs/details_section.dart';
import 'package:azyx/Screens/Anime/Details/tabs/watch_section.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/scrollable_app_bar.dart';
import 'package:azyx/Widgets/helper/platform_builder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/mapper.dart';
import 'package:azyx/utils/utils.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

class AnimeDetailsScreen extends StatefulWidget {
  final String tagg;
  final CarousaleData? smallMedia;
  final OfflineItem? allData;
  final bool isOffline;
  const AnimeDetailsScreen({
    super.key,
    required this.tagg,
    this.isOffline = false,
    this.smallMedia,
    this.allData,
  });

  @override
  State<AnimeDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<AnimeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final RxString title = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> coverImage = ''.obs;
  final Rx<String> id = ''.obs;
  final Rx<AnilistMediaData> mediaData = AnilistMediaData().obs;
  final Rx<bool> isLoading = true.obs;
  final Rx<Source> selectedSource = Source().obs;
  final Rx<String> animeTitle = "??".obs;
  final Rx<String> totalEpisodes = "??".obs;
  final RxList<Episode> episodesList = RxList();

  late TabController _tabBarController;
  late PageController _pageController;

  final Rx<String> _anilistError = ''.obs;
  final Rx<bool> _extenstionError = false.obs;
  final Rx<String> syncId = ''.obs;
  final RxInt _currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _tabBarController.addListener(() {
      if (_tabBarController.indexIsChanging) {
        _currentIndex.value = _tabBarController.index;
        _pageController.animateToPage(
          _tabBarController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    convertData();
    getMediaStatus();
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void getMediaStatus() {
    if (serviceHandler.isLoggedIn.value) {
      serviceHandler.currentMedia.value = serviceHandler.userAnimeList
          .firstWhere((e) => e.id == id.value, orElse: UserAnime().obs);
    }
    Utils.log('st; ${serviceHandler.currentMedia.value.status} / $id');
  }

  Future<void> loadData() async {
    try {
      final response = await serviceHandler.fetchAnimeDetails(
        FetchDetailsParams(id: id.value),
      );
      mediaData.value = response;
      isLoading.value = false;
      coverImage.value = mediaData.value.coverImage ?? image.value;
    } catch (e) {
      _anilistError.value = e.toString();
      Utils.log("Error while getting data for details for anime: $e");
    }
    _syncMedia();
    loadDetails();
  }

  Future<void> _syncMedia() async {
    final response = await MediaSyncer.mapMediaId(
      id.value.toString(),
      isManga: false,
    );
    syncId.value = response ?? '';
    Utils.log('MAL ${syncId.value} / ${id.value}');
  }

  void convertData() {
    if (widget.isOffline) {
      anilistAddToListController.findAnime(widget.allData!.mediaData);
      image.value = widget.allData!.mediaData.image!;
      title.value = widget.allData!.mediaData.title!;
      id.value = widget.allData!.mediaData.id!;
      episodesList.value = widget.allData!.episodesList!;
      animeTitle.value = widget.allData!.animeTitle ?? '';
      mediaData.value = widget.allData!.mediaData;
      coverImage.value = widget.allData?.mediaData.coverImage! ?? image.value;
      totalEpisodes.value = episodesList.length.toString();
      isLoading.value = false;
    } else {
      anilistAddToListController.findAnime(
        AnilistMediaData(
          id: widget.smallMedia?.id,
          title: widget.smallMedia?.title,
          episodes: widget.allData?.episodesList?.length ?? 0,
        ),
      );
      image.value = widget.smallMedia!.image;
      title.value = widget.smallMedia!.title;
      id.value = widget.smallMedia!.id;
      loadData();
    }
  }

  Future<void> getEpisodes(String link) async {
    Utils.log('ext: ${sourceController.activeSource.value?.name}');
    final episodeResult = await sourceController.activeSource.value!.methods
        .getDetail(DMedia.withUrl(link));
    final data = episodeResult.episodes!.reversed.toList();
    final mappedList = data.map((item) {
      return mChapterToEpisode(item, episodeResult);
    }).toList();
    episodesList.value = mappedList;
    totalEpisodes.value = episodesList.length.toString();

    final resp = await get(
      Uri.parse(
        "https://api.ani.zip/mappings?${serviceHandler.serviceType.value == ServicesType.anilist ? 'anilist_id' : 'mal_id'}=${id.value}",
      ),
    );

    final check = jsonDecode(resp.body);
    final ep = (check['episodes'] as Map<String, dynamic>).entries
        .map((entry) {
          final data = entry.value;
          final number = entry.key;

          if (data['absoluteEpisodeNumber'] == null) {
            Utils.log('no ep');
            return null;
          }

          Utils.log(number);

          final epNum = (data['absoluteEpisodeNumber']).toString();

          final matched = mappedList.firstWhere(
            (e) => e.number.toString() == epNum,
            orElse: () => Episode(url: '', number: epNum, desc: ''),
          );

          return Episode(
            url: matched.url ?? '',
            number: epNum,
            desc: data['overview'] ?? '',
            thumbnail: data['image'] ?? '',
            title: (data['title']?['en']) ?? '',
          );
        })
        .whereType<Episode>()
        .toList();
    if (ep.first.number.isNotEmpty) {
      episodesList.value = ep;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadDetails() async {
    try {
      final result = await mapMedia(formatTitles(mediaData.value), title);

      if (result != null) {
        getEpisodes(result.url!);
        animeTitle.value = result.title ?? '';
      } else {
        Utils.log("error");
        _extenstionError.value = true;
      }
    } catch (e, stackTrace) {
      Utils.log("Error while loading episode data: $e / $stackTrace");
    }
  }

  List<String> formatTitles(AnilistMediaData media) {
    return ['${media.title}*ANIME', media.title ?? ''];
  }

  void _onPageChanged(int index) {
    _currentIndex.value = index;
    _tabBarController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 10),
        child: Obx(
          () => AddToListFloater(
            data: OfflineItem(
              mediaData: mediaData.value,
              number: '1',
              animeTitle: title.value,
              episodesList: episodesList,
            ),
            mediaData: mediaData.value,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScrollableAppBar(
              mediaData: mediaData,
              image: image.value,
              tagg: widget.tagg,
            ),
            if (sourceController.installedExtensions.isNotEmpty)
              Container(
                margin: EdgeInsets.fromLTRB(
                  getResponsiveSize(
                    context,
                    mobileSize: 15,
                    dektopSize: Get.width * 0.2,
                  ),
                  40,
                  getResponsiveSize(
                    context,
                    mobileSize: 15,
                    dektopSize: Get.width * 0.2,
                  ),
                  0,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                            Colors.white.withOpacity(0.12),
                          ]
                        : [Colors.white, Colors.white],
                  ),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: -5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              Theme.of(context).brightness == Brightness.dark
                              ? [
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.02),
                                ]
                              : [Colors.white, Colors.white],
                        ),
                      ),
                      child: TabBar(
                        controller: _tabBarController,
                        splashBorderRadius: BorderRadius.circular(20),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.9),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: -2,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Broken.information,
                                    size: 20,
                                    color: _currentIndex.value == 0
                                        ? Colors.white
                                        : Theme.of(context).brightness ==
                                              Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  AzyXText(
                                    text: 'Details',
                                    fontVariant: FontVariant.bold,
                                    fontSize: 14,
                                    color: _currentIndex.value == 0
                                        ? Colors.white
                                        : Theme.of(context).brightness ==
                                              Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.movie_filter,
                                    size: 20,
                                    color: _currentIndex.value == 1
                                        ? Colors.white
                                        : Theme.of(context).brightness ==
                                              Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Watch',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins-Bold",
                                      color: _currentIndex.value == 1
                                          ? Colors.white
                                          : Theme.of(context).brightness ==
                                                Brightness.dark
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.black.withOpacity(0.7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ExpandablePageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                Obx(
                  () => isLoading.value || _anilistError.value.isNotEmpty
                      ? Container(
                          height: 400,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.03),
                                Colors.white.withOpacity(0.06),
                              ],
                            ),
                            border: Border.all(
                              width: 1,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _anilistError.value.isNotEmpty
                                ? AzyXText(
                                    text: _anilistError.value,
                                    textAlign: TextAlign.center,
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.error,
                                  )
                                : CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                          ),
                        )
                      : DetailsSection(
                          animeTitle: animeTitle.value,
                          episodesList: episodesList,
                          mediaData: mediaData,
                          index: 0,
                          isManga: false,
                        ),
                ),
                Obx(
                  () => sourceController.installedExtensions.isEmpty
                      ? const SizedBox.shrink()
                      : WatchSection(
                          onChanged: (value) {
                            totalEpisodes.value = '??';
                            getEpisodes(value);
                            _extenstionError.value = false;
                          },
                          onTitleChanged: (value) {
                            animeTitle.value = value;
                          },
                          onSourceChanged: (value) {
                            animeTitle.value = '??';
                            totalEpisodes.value = '??';
                            episodesList.value = [];
                            _extenstionError.value = false;
                            loadDetails();
                          },
                          mediaData: mediaData.value,
                          hasError: _extenstionError,
                          id: id.value,
                          image: coverImage.value,
                          animeTitle: animeTitle,
                          installedExtensions:
                              sourceController.installedExtensions,
                          totalEpisodes: totalEpisodes,
                          episodelist: episodesList,
                        ),
                ),
              ],
            ),
            100.height,
          ],
        ),
      ),
    );
  }
}
