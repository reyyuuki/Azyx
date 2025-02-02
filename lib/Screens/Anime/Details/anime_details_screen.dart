// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
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
  final int id;
  final String title;
  final String tagg;
  final String image;
  const AnimeDetailsScreen(
      {super.key,
      required this.id,
      required this.tagg,
      required this.title,
      required this.image});

  @override
  ConsumerState<AnimeDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<AnimeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final AnilistDataController _controller = Get.put(AnilistDataController());
  final UiSettingController _settings = Get.put(UiSettingController());
  final Rx<DetailsData> mediaData = DetailsData().obs;
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
      final response = await _controller.fetchAnilistAnimeDetails(widget.id);
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
        await container.read(getExtensionsStreamProvider(false).future);
    installedExtensions.value =
        extensions.where((source) => source.isAdded!).toList();
    if (installedExtensions.isNotEmpty) {
      selectedSource.value = installedExtensions.first;
      loadDetails(installedExtensions.first);
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
    final temp = await fetchAnifyEpisodes(widget.id, mappedList);
    episodesList.value = temp;
    setState(() {});
  }

  Future<void> loadDetails(Source source) async {
    try {
      //Step:1 - Searching Anime
      final response = await search(
          source: source, query: widget.title, page: 1, filterList: []);

      //Step:2 - Mapping Anime by title
      if (response != null) {
        final result =
            await mappingHelper(widget.title, response.toJson()['list']);

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
    loadData();
    _initExtensions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ScrollableAppBar(
            settings: _settings,
            mediaData: mediaData,
            image: widget.image,
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
                        mediaData: mediaData, settings: _settings)),
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
                          hasError: _extenstionError,
                          id: widget.id,
                          image: mediaData.value.coverImage ?? widget.image,
                          settings: _settings,
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
