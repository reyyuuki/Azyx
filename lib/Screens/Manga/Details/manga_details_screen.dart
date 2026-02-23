// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

import 'dart:developer';

import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Screens/Anime/Details/tabs/details_section.dart';
import 'package:azyx/Screens/Manga/Details/tabs/read_section.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/manga_add_to_list.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/scrollable_app_bar.dart';
import 'package:azyx/utils/mapper.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/utils.dart';

class MangaDetailsScreen extends StatefulWidget {
  final String tagg;
  final CarousaleData? smallMedia;
  final OfflineItem? allData;
  final bool isOffline;
  const MangaDetailsScreen({
    super.key,
    required this.tagg,
    this.isOffline = false,
    this.smallMedia,
    this.allData,
  });

  @override
  State<MangaDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<MangaDetailsScreen>
    with SingleTickerProviderStateMixin {
  final RxString title = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> coverImage = ''.obs;
  final Rx<String> id = ''.obs;
  final Rx<AnilistMediaData> mediaData = AnilistMediaData().obs;
  final Rx<bool> isLoading = true.obs;
  final RxList<Source> installedExtensions = RxList<Source>();
  final Rx<Source> selectedSource = Source().obs;
  final Rx<String> mangaTitle = "??".obs;
  final Rx<String> totalChapters = "??".obs;
  final RxList<Chapter> chaptersList = RxList();
  late TabController _tabBarController;
  final PageController pageController = PageController();
  final Rx<String> _anilistError = ''.obs;
  final Rx<bool> _extenstionError = false.obs;
  final Rx<String> syncId = ''.obs;
  final RxInt _currentIndex = 0.obs;

  Future<void> loadData() async {
    try {
      final response = await serviceHandler.fetchAnimeDetails(
        FetchDetailsParams(id: id.value, isManga: true),
      );
      mediaData.value = response;
      isLoading.value = false;
      coverImage.value = mediaData.value.coverImage ?? image.value;
    } catch (e) {
      _anilistError.value = e.toString();
      log("Error while getting data for details: $e");
      azyxSnackBar('${serviceHandler.serviceType.toString()} not working');
    }
    await loadDetails();
  }

  void getMediaStatus() {
    if (serviceHandler.isLoggedIn.value) {
      serviceHandler.currentMedia.value = serviceHandler.userMangaList
          .firstWhere((e) => e.id == id.value, orElse: UserAnime().obs);
    }
    Utils.log('st; ${serviceHandler.currentMedia.value.status} / $id');
  }

  Future<void> _syncMedia() async {
    final response = await MediaSyncer.mapMediaId(
      id.value.toString(),
      isManga: true,
    );
    syncId.value = response ?? '';
    Utils.log('MAL ${syncId.value} / ${id.value}');
  }

  void convertData() {
    if (widget.isOffline) {
      anilistAddToListController.findManga(widget.allData!.mediaData);
      image.value = widget.allData!.mediaData.image!;
      title.value = widget.allData!.mediaData.title!;
      id.value = widget.allData!.mediaData.id!;
      chaptersList.value = widget.allData!.chaptersList!;
      mangaTitle.value = widget.allData!.animeTitle ?? '';
      mediaData.value = widget.allData!.mediaData;
      coverImage.value = widget.allData?.mediaData.coverImage! ?? image.value;
      totalChapters.value = chaptersList.length.toString();
      isLoading.value = false;
    } else {
      Utils.log('online');
      anilistAddToListController.findManga(
        AnilistMediaData(
          id: widget.smallMedia?.id,
          title: widget.smallMedia?.title,
          episodes: widget.allData?.episodesList!.length,
        ),
      );
      image.value = widget.smallMedia!.image;
      title.value = widget.smallMedia!.title;
      id.value = widget.smallMedia!.id;
      Utils.log('idd: ${id.value}');
      loadData();
    }
  }

  Future<void> getChapters(String link) async {
    final episodeResult = await sourceController
        .activeMangaSource
        .value!
        .methods
        .getDetail(DMedia.withUrl(link));
    totalChapters.value = chaptersList.length.toString();
    chaptersList.value = mChapterToChapter(
      episodeResult.episodes!,
      widget.smallMedia!.title,
    );
  }

  Future<void> loadDetails() async {
    try {
      final result = await mapMedia(formatTitles(mediaData.value), title);
      if (result != null) {
        getChapters(result.url!);
        mangaTitle.value = result.title ?? '';
      } else {
        _extenstionError.value = true;
        log("error ${_extenstionError.value}");
      }
    } catch (e, stackTrace) {
      log("Error while loading episode data: $e / $stackTrace");
      _extenstionError.value = true;
    }
  }

  List<String> formatTitles(AnilistMediaData media) {
    return ['${media.title}*ANIME', media.title ?? ''];
  }

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 2, vsync: this);

    _tabBarController.addListener(() {
      if (_tabBarController.indexIsChanging) {
        _currentIndex.value = _tabBarController.index;
        pageController.animateToPage(
          _tabBarController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    _syncMedia();
    convertData();
    getMediaStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 10),
        child: Obx(
          () => MangaAddToList(
            data: OfflineItem(
              mediaData: mediaData.value,
              number: '1',
              animeTitle: title.value,
              chaptersList: chaptersList.value,
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
            if (sourceController.installedMangaExtensions.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: TabBar(
                  controller: _tabBarController,
                  splashBorderRadius: BorderRadius.circular(26),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicatorPadding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: theme.textTheme.titleMedium?.fontFamily,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: theme.textTheme.titleMedium?.fontFamily,
                  ),
                  tabs: const [
                    Tab(text: "Overview"),
                    Tab(text: "Chapters"),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ExpandablePageView(
              controller: pageController,
              children: [
                Obx(
                  () => isLoading.value || _anilistError.value.isNotEmpty
                      ? Center(
                          child: _anilistError.value.isNotEmpty
                              ? AzyXText(
                                  text: _anilistError.value,
                                  textAlign: TextAlign.center,
                                  fontSize: 20,
                                )
                              : const CircularProgressIndicator(),
                        )
                      : DetailsSection(
                          mediaData: mediaData,
                          index: _tabBarController.index,
                          animeTitle: mangaTitle.value,
                          isManga: true,
                          chapterList: chaptersList,
                        ),
                ),
                Obx(
                  () => sourceController.installedMangaExtensions.value.isEmpty
                      ? const SizedBox.shrink()
                      : ReadSection(
                          syncId: syncId,
                          onChanged: (value) {
                            int total = 0;
                            for (var item in value) {
                              final match = RegExp(
                                r'\b(?:Chap(?:ter)?|Ch)\s*(\d+)\b',
                                caseSensitive: false,
                              ).firstMatch(item.name ?? '');
                              if (match != null) {
                                int episodeNumber = int.parse(match.group(1)!);
                                total++;
                                log(episodeNumber.toString());
                              }
                            }
                            totalChapters.value = total.toString();
                          },
                          onTitleChanged: (value) {
                            mangaTitle.value = value;
                          },
                          onSourceChanged: () {
                            _extenstionError.value = false;
                            loadDetails();
                          },
                          hasError: _extenstionError,
                          id: id.value,
                          image: mediaData.value.coverImage ?? image.value,
                          animeTitle: mangaTitle,
                          installedExtensions: installedExtensions,
                          selectedSource: selectedSource,
                          totalEpisodes: totalChapters,
                          chaptersList: chaptersList,
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
