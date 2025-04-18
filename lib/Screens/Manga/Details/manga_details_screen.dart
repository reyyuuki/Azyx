// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Screens/Anime/Details/tabs/details_section.dart';
import 'package:azyx/Screens/Manga/Details/tabs/read_section.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/_placeholder.dart';
import 'package:azyx/Widgets/common/scrollable_app_bar.dart';
import 'package:azyx/api/Mangayomi/Extensions/extensions_provider.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/get_detail.dart';
import 'package:azyx/api/Mangayomi/Search/search.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/mapping_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class MangaDetailsScreen extends ConsumerStatefulWidget {
  final String tagg;
  final CarousaleData? smallMedia;
  final OfflineItem? allData;
  final bool isOffline;
  const MangaDetailsScreen(
      {super.key,
      required this.tagg,
      this.isOffline = false,
      this.smallMedia,
      this.allData});

  @override
  ConsumerState<MangaDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<MangaDetailsScreen>
    with SingleTickerProviderStateMixin {
  final Rx<String> title = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> coverImage = ''.obs;
  final Rx<int> id = 0.obs;
  final Rx<AnilistMediaData> mediaData = AnilistMediaData().obs;
  final Rx<bool> isLoading = true.obs;
  final RxList<Source> installedExtensions = RxList<Source>();
  final Rx<Source> selectedSource = Source().obs;
  final Rx<String> mangaTitle = "??".obs;
  final Rx<String> totalChapters = "??".obs;
  final RxList<Chapter> chaptersList = RxList();
  late TabController _tabBarController;
  final Rx<String> _anilistError = ''.obs;
  final Rx<bool> _extenstionError = false.obs;
  Future<void> loadData() async {
    try {
      final response = await anilistDataController
          .fetchAnilistMangaDetails(widget.smallMedia!.id);
      mediaData.value = response;
      isLoading.value = false;
    } catch (e) {
      _anilistError.value = e.toString();
      log("Error while getting data for details: $e");
    }
  }

  Future<void> _initExtensions() async {
    final container = ProviderContainer();
    final extensions =
        await container.read(getExtensionsStreamProvider(true).future);
    installedExtensions.value =
        extensions.where((source) => source.isAdded!).toList();
    if (installedExtensions.isNotEmpty) {
      selectedSource.value = installedExtensions.first;
      loadDetails(installedExtensions.first);
    }
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
      anilistAddToListController.findManga(AnilistMediaData(
          id: widget.smallMedia?.id,
          title: widget.smallMedia?.title,
          episodes: widget.allData?.episodesList!.length));
      image.value = widget.smallMedia!.image;
      title.value = widget.smallMedia!.title;
      id.value = widget.smallMedia!.id;
      loadData();
    }
  }

  Future<void> getChapters(String link, Source source) async {
    final episodeResult = await getDetail(url: link, source: source);
    log(episodeResult.chapters!.first.dateUpload.toString());
    totalChapters.value = chaptersList.length.toString();
    //Step:4 - Mapping Chapters
    chaptersList.value =
        mChapterToChapter(episodeResult.chapters!, widget.smallMedia!.title);
  }

  Future<void> loadDetails(Source source) async {
    try {
      //Step:1 - Searching Manga
      final response = await search(
          source: source,
          query: widget.smallMedia!.title,
          page: 1,
          filterList: []);

      //Step:2 - Mapping Manga by title
      if (response != null) {
        final result = await mappingHelper(
            widget.smallMedia!.title, response.toJson()['list']);
        log(result.toString());

        //Step:3 - Fetchting details
        if (result != null) {
          mangaTitle.value = result['name'] ?? '';
          getChapters(result['link'], source);
        } else {
          log("error");
          _extenstionError.value = true;
        }
      }
    } catch (e) {
      log("Error while loading episode data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 2, vsync: this);
    _initExtensions();
    convertData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ScrollableAppBar(
            mediaData: mediaData,
            image: image.value,
            tagg: widget.tagg,
          ),
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: _TabBarDelegate(
              tabBar: AzyXContainer(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.fromLTRB(15, 40, 15, 0),
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest,
                          spreadRadius: 2,
                          offset: const Offset(0, 7),
                          blurRadius: 20)
                    ]),
                child: TabBar(
                  controller: _tabBarController,
                  tabs: const [
                    Tab(
                      icon: Icon(Broken.information, size: 24),
                      text: 'Details',
                    ),
                    Tab(
                      icon: Icon(Broken.book, size: 24),
                      text: 'Read',
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
          ),
          SliverFillRemaining(
            fillOverscroll: true,
            child: TabBarView(
              controller: _tabBarController,
              children: [
                Obx(() => isLoading.value || _anilistError.value.isNotEmpty
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
                      )),
                Obx(
                  () => installedExtensions.isEmpty
                      ? const PlaceholderExtensions()
                      : ReadSection(
                          onChanged: (value) {
                            int total = 0;
                            for (var item in value) {
                              final match = RegExp(
                                      r'\b(?:Chap(?:ter)?|Ch)\s*(\d+)\b',
                                      caseSensitive: false)
                                  .firstMatch(item['name']);

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
                          onSourceChanged: (value) {
                            selectedSource.value = value;
                            _extenstionError.value = false;
                            loadDetails(value);
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
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AzyXContainer(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => 105;

  @override
  double get minExtent => 105;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
