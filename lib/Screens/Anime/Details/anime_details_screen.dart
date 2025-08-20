// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Screens/Anime/Details/tabs/add_to_list_floater.dart';
import 'package:azyx/Screens/Anime/Details/tabs/details_section.dart';
import 'package:azyx/Screens/Anime/Details/tabs/watch_section.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
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

class AnimeDetailsScreen extends StatefulWidget {
  final String tagg;
  final CarousaleData? smallMedia;
  final OfflineItem? allData;
  final bool isOffline;
  const AnimeDetailsScreen(
      {super.key,
      required this.tagg,
      this.isOffline = false,
      this.smallMedia,
      this.allData});

  @override
  State<AnimeDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<AnimeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final RxString title = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> coverImage = ''.obs;
  final Rx<int> id = 0.obs;
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
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final response = await serviceHandler.fetchAnimeDetails(id.value);
      mediaData.value = response;
      isLoading.value = false;
      coverImage.value = mediaData.value.coverImage ?? image.value;
    } catch (e) {
      _anilistError.value = e.toString();
      log("Error while getting data for details: $e");
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
      anilistAddToListController.findAnime(AnilistMediaData(
          id: widget.smallMedia?.id,
          title: widget.smallMedia?.title,
          episodes: widget.allData?.episodesList?.length ?? 0));
      image.value = widget.smallMedia!.image;
      title.value = widget.smallMedia!.title;
      id.value = widget.smallMedia!.id;
      loadData();
    }
  }

  Future<void> getEpisodes(String link) async {
    final episodeResult = await sourceController.activeSource.value!.methods
        .getDetail(DMedia.withUrl(link));
    final data = episodeResult.episodes!.reversed.toList();
    final mappedList = data.map((item) {
      return mChapterToEpisode(item, episodeResult);
    }).toList();
    episodesList.value = mappedList;
    totalEpisodes.value = episodesList.length.toString();
  }

  Future<void> loadDetails() async {
    try {
      final result = await mapMedia(formatTitles(mediaData.value), title);

      if (result != null) {
        getEpisodes(result.url!);
        animeTitle.value = result.title ?? '';
      } else {
        log("error");
        _extenstionError.value = true;
      }
    } catch (e, stackTrace) {
      log("Error while loading episode data: $e / $stackTrace");
    }
  }

  List<String> formatTitles(AnilistMediaData media) {
    return ['${media.title}*ANIME', media.title!];
  }

  void _onPageChanged(int index) {
    _currentIndex.value = index;
    _tabBarController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 10),
        child: Obx(
          () => AddToListFloater(
              data: OfflineItem(
                  mediaData: mediaData.value,
                  number: '1',
                  animeTitle: title.value,
                  chaptersList: []),
              mediaData: mediaData.value),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScrollableAppBar(
                mediaData: mediaData, image: image.value, tagg: widget.tagg),
            if (sourceController.installedMangaExtensions.isNotEmpty)
              if (sourceController.installedExtensions.isNotEmpty)
                AzyXContainer(
                  padding: const EdgeInsets.all(8),
                  margin: EdgeInsets.fromLTRB(
                      getResponsiveSize(context,
                          mobileSize: 15, dektopSize: Get.width * 0.2),
                      40,
                      getResponsiveSize(context,
                          mobileSize: 15, dektopSize: Get.width * 0.2),
                      0),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest
                                .withOpacity(1.glowMultiplier()),
                            spreadRadius: 2.spreadMultiplier(),
                            offset: const Offset(0, 7),
                            blurRadius: 20.blurMultiplier())
                      ]),
                  child: SizedBox(
                    height: 52,
                    child: TabBar(
                      controller: _tabBarController,
                      splashBorderRadius: BorderRadius.circular(8),
                      tabs: const [
                        Tab(
                          icon: Icon(Broken.information, size: 24),
                          text: 'Details',
                        ),
                        Tab(
                          icon: Icon(Icons.movie_filter, size: 24),
                          text: 'Watch',
                        ),
                      ],
                      labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Bold",
                          color: Colors.black),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Poppins-Bold",
                        color: Colors.grey,
                      ),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            ExpandablePageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                Obx(() => isLoading.value || _anilistError.value.isNotEmpty
                    ? SizedBox(
                        height: 400,
                        child: Center(
                          child: _anilistError.value.isNotEmpty
                              ? AzyXText(
                                  text: _anilistError.value,
                                  textAlign: TextAlign.center,
                                  fontSize: 20,
                                )
                              : const CircularProgressIndicator(),
                        ),
                      )
                    : DetailsSection(
                        animeTitle: animeTitle.value,
                        episodesList: episodesList,
                        mediaData: mediaData,
                        index: 0,
                        isManga: false,
                      )),
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
          ],
        ),
      ),
    );
  }
}
