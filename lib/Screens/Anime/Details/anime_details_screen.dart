// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:azyx/Classes/anime_class.dart';
import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Classes/offline_item.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Screens/Anime/Details/tabs/details_section.dart';
import 'package:azyx/Screens/Anime/Details/tabs/watch_section.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/scrollable_app_bar.dart';
import 'package:azyx/api/Mangayomi/Extensions/extensions_provider.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/get_detail.dart';
import 'package:azyx/api/Mangayomi/Search/search.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Anify/anify_episodes.dart';
import 'package:azyx/utils/Functions/mapping_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AnimeDetailsScreen extends ConsumerStatefulWidget {
  final String tagg;
  final Anime? smallMedia;
  final OfflineItem? allData;
  final bool isOffline;
  const AnimeDetailsScreen(
      {super.key,
      required this.tagg,
      this.isOffline = false,
      this.smallMedia,
      this.allData});

  @override
  ConsumerState<AnimeDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<AnimeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final Rx<String> title = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> coverImage = ''.obs;
  final Rx<int> id = 0.obs;
  final Rx<AnilistMediaData> mediaData = AnilistMediaData().obs;
  final Rx<bool> isLoading = true.obs;
  final RxList<Source> installedExtensions = RxList<Source>();
  final Rx<Source> selectedSource = Source().obs;
  final Rx<String> animeTitle = "??".obs;
  final Rx<String> totalEpisodes = "??".obs;
  final RxList<Episode> episodesList = RxList();
  late TabController _tabBarController;
  final Rx<String> _anilistError = ''.obs;
  final Rx<bool> _extenstionError = false.obs;

  Future<void> loadData() async {
    try {
      final response =
          await anilistDataController.fetchAnilistAnimeDetails(id.value);
      mediaData.value = response;
      isLoading.value = false;
      coverImage.value = mediaData.value.coverImage ?? image.value;
    } catch (e) {
      _anilistError.value = e.toString();
      log("Error while getting data for details: $e");
    }
    loadDetails(selectedSource.value);
  }

  Future<void> _initExtensions() async {
    final container = ProviderContainer();
    final extensions =
        await container.read(getExtensionsStreamProvider(false).future);
    installedExtensions.value =
        extensions.where((source) => source.isAdded!).toList();
    if (installedExtensions.isNotEmpty) {
      selectedSource.value = installedExtensions.first;
    }
  }

  void convertData() {
    _initExtensions();
    if (widget.isOffline) {
      image.value = widget.allData!.mediaData.image!;
      title.value = widget.allData!.mediaData.title!;
      id.value = widget.allData!.mediaData.id!;
      episodesList.value = widget.allData!.episodesList;
      animeTitle.value = widget.allData!.animeTitle ?? '';
      mediaData.value = widget.allData!.mediaData;
      coverImage.value = widget.allData?.mediaData.coverImage! ?? image.value;
      totalEpisodes.value = episodesList.length.toString();
      isLoading.value = false;
    } else {
      image.value = widget.smallMedia!.image!;
      title.value = widget.smallMedia!.title!;
      id.value = widget.smallMedia!.id!;
      loadData();
    }
  }

  Future<void> getEpisodes(String link, Source source) async {
    final episodeResult = await getDetail(url: link, source: source);
    final data = episodeResult.chapters!.reversed.toList();

    //Step:1 - Mapping Basic Episodes
    final mappedList = data.map((item) {
      return mChapterToEpisode(item, episodeResult);
    }).toList();
    episodesList.value = mappedList;
    totalEpisodes.value = episodesList.length.toString();
    //Step:2 - Fetching AnifyEpisodes
    final temp = await fetchAnifyEpisodes(widget.smallMedia!.id!, mappedList);
    episodesList.value = temp;
    setState(() {});
  }

  Future<void> loadDetails(Source source) async {
    try {
      //Step:1 - Searching Anime
      final response = await search(
          source: source,
          query: widget.smallMedia!.title!,
          page: 1,
          filterList: []);

      //Step:2 - Mapping Anime by title
      if (response != null) {
        final result =
            await mappingHelper(title.value, response.toJson()['list']);

        //Step:3 - Fetchting details
        if (result != null) {
          getEpisodes(result['link'], source);
          animeTitle.value = result['name'] ?? '';
        } else {
          log("error");
          _extenstionError.value = true;
        }
      }
    } catch (e, stackTrace) {
      log("Error while loading episode data: $e / $stackTrace");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 2, vsync: this);
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
                                _anilistError.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: "Poppins", fontSize: 20),
                              )
                            : const CircularProgressIndicator(),
                      )
                    : DetailsSection(
                        animeTitle: animeTitle.value,
                        episodesList: episodesList,
                        mediaData: mediaData,
                        index: _tabBarController.index,
                      )),
                Obx(
                  () => installedExtensions.isEmpty
                      ? const Placeholder()
                      : WatchSection(
                          onChanged: (value) {
                            totalEpisodes.value = '??';
                            getEpisodes(value, selectedSource.value);
                          },
                          onTitleChanged: (value) {
                            animeTitle.value = value;
                          },
                          onSourceChanged: (value) {
                            animeTitle.value = '??';
                            totalEpisodes.value = '??';
                            selectedSource.value = value;
                            episodesList.value = [];
                            _extenstionError.value = false;
                            loadDetails(value);
                          },
                          mediaData: mediaData.value,
                          hasError: _extenstionError,
                          id: id.value,
                          image: coverImage.value,
                          animeTitle: animeTitle,
                          installedExtensions: installedExtensions,
                          selectedSource: selectedSource,
                          totalEpisodes: totalEpisodes,
                          episodelist: episodesList,
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
