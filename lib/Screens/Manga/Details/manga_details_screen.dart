import 'dart:developer';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Database/isar_models/offline_item.dart'
    as azyx_offline_item;
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_chip.dart';
import 'package:azyx/Screens/Anime/Details/widgets/character_grid.dart';
import 'package:azyx/Screens/Anime/Details/widgets/community_charts.dart';
import 'package:azyx/Screens/Anime/Details/widgets/details_error.dart';
import 'package:azyx/Screens/Anime/Details/widgets/details_skeleton.dart';
import 'package:azyx/Screens/Anime/Details/widgets/details_top_bar.dart';
import 'package:azyx/Screens/Anime/Details/widgets/hero_backdrop.dart';
import 'package:azyx/Screens/Anime/Details/widgets/hero_section.dart';
import 'package:azyx/Screens/Anime/Details/widgets/mobile_dock.dart';
import 'package:azyx/Screens/Anime/Details/widgets/poster_row.dart';
import 'package:azyx/Screens/Anime/Details/widgets/side_column.dart';
import 'package:azyx/Screens/Anime/Details/widgets/synopsis_block.dart';
import 'package:azyx/Screens/Anime/Details/widgets/tags_section.dart';
import 'package:azyx/Screens/Manga/Details/tabs/read_section.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/common/comments_section.dart';
import 'package:azyx/utils/mapper.dart';
import 'package:azyx/utils/source_mapper.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../utils/utils.dart';

class MangaDetailsScreen extends StatefulWidget {
  final String tagg;
  final CarousaleData? smallMedia;
  final azyx_offline_item.OfflineItem? allData;
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

class _DetailsScreenState extends State<MangaDetailsScreen> {
  final RxString title = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> coverImage = ''.obs;
  final Rx<String> id = ''.obs;
  final Rx<AnilistMediaData> mediaData = AnilistMediaData().obs;
  final RxBool isLoading = true.obs;
  final RxList<Source> installedExtensions = RxList<Source>();
  final Rx<Source> selectedSource = Source().obs;
  final Rx<String> mangaTitle = "??".obs;
  final Rx<String> totalChapters = "??".obs;
  final RxList<Chapter> chaptersList = RxList();
  final Rx<String> _anilistError = ''.obs;
  final Rx<bool> _extenstionError = false.obs;
  final Rx<bool> isFetchingChapters = true.obs;
  final Rx<String> syncId = ''.obs;
  final RxString _activeTab = 'ov'.obs;
  final RxBool _isFavourite = false.obs;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBackButton = ValueNotifier<bool>(true);
  double _lastScrollOffset = 0.0;

  Future<void> loadData() async {
    try {
      _anilistError.value = '';
      final response = await serviceHandler.fetchAnimeDetails(
        FetchDetailsParams(id: id.value, isManga: true),
      );
      mediaData.value = response;
      isLoading.value = false;
      coverImage.value = mediaData.value.coverImage ?? image.value;
    } catch (e) {
      _anilistError.value = e.toString();
      isLoading.value = false;
      log("Error while getting data for details: $e");
      azyxSnackBar('${serviceHandler.serviceType.toString()} not working');
    }
    await loadDetails();
  }

  void getMediaStatus() {
    if (serviceHandler.isLoggedIn.value) {
      serviceHandler.currentMedia.value = serviceHandler.userMangaList
          .firstWhere(
            (e) => e.id == id.value,
            orElse: () => UserMedia(id: id.value),
          );
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
      anilistAddToListController.findManga(widget.allData!.mediaData!);
      image.value = widget.allData!.mediaData!.image!;
      title.value = widget.allData!.mediaData!.title!;
      id.value = widget.allData!.mediaData!.id!;
      chaptersList.value = widget.allData!.chaptersList!;
      mangaTitle.value = widget.allData!.animeTitle ?? '';
      mediaData.value = widget.allData!.mediaData!;
      coverImage.value = widget.allData?.mediaData?.coverImage ?? image.value;
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
      image.value = widget.smallMedia?.image ?? '';
      title.value = widget.smallMedia?.title ?? '';
      id.value = widget.smallMedia?.id ?? '';
      coverImage.value = image.value;
      mediaData.value = AnilistMediaData(
        id: id.value,
        title: title.value,
        image: image.value,
        coverImage: image.value,
      );
      Utils.log('idd: ${id.value}');
      loadData();
    }
  }

  Future<void> getChapters(String link) async {
    final token = "manga_detail_${id.value}";
    sourceController.updateToken('manga_detail', token);
    isFetchingChapters.value = true;
    _extenstionError.value = false;
    try {
      final episodeResult = await sourceController
          .activeMangaSource
          .value!
          .methods
          .getDetail(
            DMedia.withUrl(link),
            parameters: SourceParams(cancelToken: token),
          );
      chaptersList.value = mChapterToChapter(
        episodeResult.episodes ?? [],
        widget.smallMedia?.title ?? title.value,
      );
      totalChapters.value = chaptersList.length.toString();
    } catch (e) {
      log("Error fetching chapters or cancelled: $e");
      _extenstionError.value = true;
    } finally {
      isFetchingChapters.value = false;
    }
  }

  Future<void> loadDetails() async {
    isFetchingChapters.value = true;
    _extenstionError.value = false;
    try {
      final result = await SourceMapper.mapMedia(
        formatTitles(mediaData.value),
        title,
        mediaId: id.value,
        type: ItemType.manga,
        synonyms: mediaData.value.synonyms ?? [],
      );
      if (result != null) {
        await getChapters(result.url!);
        mangaTitle.value = result.title ?? '';
      } else {
        _extenstionError.value = true;
        isFetchingChapters.value = false;
      }
    } catch (e, stackTrace) {
      log("Error while loading episode data: $e / $stackTrace");
      _extenstionError.value = true;
      isFetchingChapters.value = false;
    }
  }

  List<String> formatTitles(AnilistMediaData media) {
    return [media.title ?? '', media.titleRomaji ?? ''];
  }

  void _handleTopBarScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    if (offset <= 24.0) {
      if (!_showBackButton.value) _showBackButton.value = true;
    } else if (offset > _lastScrollOffset + 6.0) {
      if (_showBackButton.value) _showBackButton.value = false;
    } else if (offset < _lastScrollOffset - 6.0) {
      if (!_showBackButton.value) _showBackButton.value = true;
    }
    _lastScrollOffset = offset;
  }

  Future<void> _toggleFavourite() async {
    final mangaId = int.tryParse(id.value);
    if (mangaId == null) return;

    if (!serviceHandler.isLoggedIn.value) {
      azyxSnackBar('Sign in to AniList to favourite this');
      return;
    }

    final previous = _isFavourite.value;
    _isFavourite.value = !previous;
    azyxSnackBar(
      _isFavourite.value ? 'Added to favourites' : 'Removed from favourites',
    );

    final success = await serviceHandler.toggleFavourite(mangaId, isManga: true);
    if (!success) {
      _isFavourite.value = previous;
      azyxSnackBar('Failed to update favourites');
    }
  }

  void _openListSheet(BuildContext context) {
    final total = mediaData.value.episodes ?? chaptersList.length;
    anilistAddToListController.addToMangaListSheet(
      context,
      coverImage.value.isNotEmpty ? coverImage.value : image.value,
      title.value,
      total,
    );
  }

  void _navigateToManga(PosterRowItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MangaDetailsScreen(
          tagg: 'manga_${item.id}',
          smallMedia: CarousaleData(
            id: item.id.toString(),
            title: item.title,
            image: item.coverImage ?? '',
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleTopBarScroll);
    _syncMedia();
    convertData();
    getMediaStatus();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleTopBarScroll);
    _scrollController.dispose();
    _showBackButton.dispose();
    sourceController.cancelInProgress('manga_search');
    sourceController.cancelInProgress('manga_detail');
    SourceMapper.cancelMapping();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = AzTokens.isExpanded(context);

    return Obx(() {
      final media = mediaData.value;
      final tones = AzTones.fromScheme(theme.colorScheme);
      final loading = isLoading.value;
      final hasError = _anilistError.value.isNotEmpty;

      final isNotYetReleased =
          media.status?.toUpperCase() == 'NOT_YET_RELEASED';
      final currentStatus = serviceHandler.currentMedia.value.status ?? '';
      final isCurrentlyReading = currentStatus.toUpperCase() == 'CURRENT';

      final primaryLabel = isNotYetReleased
          ? 'Not released yet'
          : (isCurrentlyReading ? 'Continue reading' : 'Start reading');

      final listButtonLabel = currentStatus.isNotEmpty
          ? _formatListStatus(currentStatus)
          : 'Add to list';

      final isListOn = currentStatus.isNotEmpty;
      final isFav = _isFavourite.value;

      final relations = PosterRow.fromRelations(media.relations);
      final recommendations = PosterRow.fromRecommendations(
        media.recommendations,
      );
      final hasRelationsOrRecs =
          relations.isNotEmpty || recommendations.isNotEmpty;

      final hasInitialData =
          (media.title != null && media.title!.isNotEmpty) ||
          widget.smallMedia != null ||
          widget.allData != null;

      final hasChaptersTab =
          sourceController.installedMangaExtensions.isNotEmpty;

      return AzTonesProvider(
        tones: tones,
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HeroBackdrop(
                  bannerUrl: media.bannerImage,
                  coverUrl: media.coverImage ?? media.image,
                  height: 540,
                ),
              ),
              if (loading && !hasInitialData)
                const DetailsSkeleton()
              else if (hasError && !hasInitialData)
                DetailsError(
                  errorMessage: _anilistError.value,
                  onRetry: () => loadData(),
                  onSearch: () => Navigator.of(context).maybePop(),
                )
              else
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: HeroSection(
                        media: media,
                        primaryLabel: primaryLabel,
                        listButtonLabel: listButtonLabel,
                        isListOn: isListOn,
                        isFavourite: isFav,
                        onWatchTap: () {
                          if (hasChaptersTab) {
                            _activeTab.value = 'ch';
                          } else {
                            azyxSnackBar('No manga extensions installed');
                          }
                        },
                        onListTap: () => _openListSheet(context),
                        onFavTap: _toggleFavourite,
                        heroTag: widget.tagg,
                        isLoading: loading,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: AzTokens.contentMaxWidth,
                          ),
                          child: _MangaSectionTabs(
                            activeTab: _activeTab,
                            showChapters: hasChaptersTab,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: AzTokens.contentMaxWidth,
                          ),
                          padding: EdgeInsets.fromLTRB(
                            isDesktop ? AzTokens.horizontalPadding : 18.0,
                            isDesktop ? 32.0 : 24.0,
                            isDesktop ? AzTokens.horizontalPadding : 18.0,
                            24.0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: switch (_activeTab.value) {
                              'ch' when hasChaptersTab => KeyedSubtree(
                                key: const ValueKey('ch'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ReadSection(
                                      syncId: syncId,
                                      onChanged: (value) {
                                        int total = 0;
                                        for (var item in value) {
                                          final match = RegExp(
                                            r'\b(?:Chap(?:ter)?|Ch)\s*(\d+)\b',
                                            caseSensitive: false,
                                          ).firstMatch(item.name ?? '');
                                          if (match != null) {
                                            int episodeNumber = int.parse(
                                              match.group(1)!,
                                            );
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
                                      isFetching: isFetchingChapters,
                                      id: id.value,
                                      image: media.coverImage ?? image.value,
                                      animeTitle: mangaTitle,
                                      installedExtensions: installedExtensions,
                                      selectedSource: selectedSource,
                                      totalEpisodes: totalChapters,
                                      chaptersList: chaptersList,
                                    ),
                                    if (!isDesktop) const SizedBox(height: 96),
                                  ],
                                ),
                              ),
                              'cm' => KeyedSubtree(
                                key: const ValueKey('cm'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (id.value.isNotEmpty)
                                      CommentsSection(
                                        mediaId: id.value,
                                        mediaTitle: title.value,
                                        mediaPoster: image.value,
                                        isManga: true,
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 32,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Comments are unavailable for this title.',
                                            style: AzTokens.caption(
                                              theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (!isDesktop) const SizedBox(height: 96),
                                  ],
                                ),
                              ),
                              _ => KeyedSubtree(
                                key: const ValueKey('ov'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isDesktop)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: SynopsisBlock(
                                              media: media,
                                              isLoading: loading,
                                            ),
                                          ),
                                          const SizedBox(width: 28),
                                          Expanded(
                                            flex: 4,
                                            child: FactsCard(media: media),
                                          ),
                                        ],
                                      )
                                    else ...[
                                      SynopsisBlock(
                                        media: media,
                                        isLoading: loading,
                                      ),
                                      const SizedBox(height: 28.0),
                                      FactsCard(media: media),
                                    ],
                                    const SizedBox(height: AzTokens.sectionGap),
                                    CommunityCharts(
                                      media: media,
                                      showHeading: false,
                                      showComments: false,
                                    ),
                                    if (media.tagsList != null &&
                                        media.tagsList!.isNotEmpty) ...[
                                      const SizedBox(
                                        height: AzTokens.sectionGap,
                                      ),
                                      TagsSection(
                                        tags: media.tagsList!,
                                        isManga: true,
                                        onMuteTag: (tagName) =>
                                            azyxSnackBar('Muted "$tagName"'),
                                      ),
                                    ],
                                    const SizedBox(height: AzTokens.sectionGap),
                                    CharacterGrid(characters: media.characters),
                                    if (hasRelationsOrRecs) ...[
                                      const SizedBox(
                                        height: AzTokens.sectionGap,
                                      ),
                                      if (relations.isNotEmpty)
                                        _MangaPosterRowWrapper(
                                          title: 'Related',
                                          items: relations,
                                          onItemTapped: _navigateToManga,
                                        ),
                                      if (recommendations.isNotEmpty)
                                        _MangaPosterRowWrapper(
                                          title: 'Fans also liked',
                                          isSubheading: true,
                                          items: recommendations,
                                          onItemTapped: _navigateToManga,
                                        ),
                                    ],
                                    if (media.siteUrl != null &&
                                        media.siteUrl!.isNotEmpty) ...[
                                      const SizedBox(height: 24),
                                      AzChip(
                                        label: 'View on AniList',
                                        icon: Icons.open_in_new_rounded,
                                        onTap: () {
                                          launchUrlString(
                                            media.siteUrl!,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                    ],
                                    if (!isDesktop) const SizedBox(height: 96),
                                  ],
                                ),
                              ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showBackButton,
                  builder: (context, visible, child) {
                    return IgnorePointer(
                      ignoring: !visible,
                      child: AnimatedSlide(
                        offset: visible ? Offset.zero : const Offset(0, -1.2),
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: visible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: DetailsTopBar(
                    showBackButton: Navigator.of(context).canPop(),
                    title: media.title ?? media.titleRomaji,
                    categoryLabel: 'Manga',
                  ),
                ),
              ),
              if (!isDesktop && !loading && !hasError)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MobileDock(
                    primaryLabel: primaryLabel,
                    onWatchTap: () {
                      if (hasChaptersTab) {
                        _activeTab.value = 'ch';
                      } else {
                        azyxSnackBar('No manga extensions installed');
                      }
                    },
                    onListTap: () => _openListSheet(context),
                    onFavTap: _toggleFavourite,
                    isFavourite: isFav,
                    isListOn: isListOn,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  String _formatListStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'CURRENT':
        return 'Currently reading';
      case 'PLANNING':
        return 'Plan to read';
      case 'COMPLETED':
        return 'Completed';
      case 'PAUSED':
        return 'Paused';
      case 'DROPPED':
        return 'Dropped';
      case 'REPEATING':
        return 'Rereading';
      default:
        return raw;
    }
  }
}

class _MangaSectionTabs extends StatelessWidget {
  final RxString activeTab;
  final bool showChapters;

  const _MangaSectionTabs({
    required this.activeTab,
    required this.showChapters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final tabs = <MapEntry<String, String>>[
        const MapEntry('ov', 'Details'),
        if (showChapters) const MapEntry('ch', 'Chapters'),
        const MapEntry('cm', 'Comments'),
      ];

      final currentTab = activeTab.value;
      final hPad = MediaQuery.of(context).size.width < 600
          ? 16.0
          : AzTokens.horizontalPadding;

      return Container(
        height: 48,
        margin: EdgeInsets.symmetric(horizontal: hPad),
        constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = currentTab == tab.key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => activeTab.value = tab.key,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab.value,
                      style: AzTokens.body(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _MangaPosterRowWrapper extends StatelessWidget {
  final String title;
  final bool isSubheading;
  final List<PosterRowItem> items;
  final void Function(PosterRowItem item) onItemTapped;

  const _MangaPosterRowWrapper({
    required this.title,
    this.isSubheading = false,
    required this.items,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return PosterRow(
      title: title,
      isSubheading: isSubheading,
      items: items,
      onItemTapped: (id) {
        final match = items.firstWhere(
          (e) => e.id == id,
          orElse: () => items.first,
        );
        onItemTapped(match);
      },
    );
  }
}
