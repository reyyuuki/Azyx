import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_toast.dart';
import 'package:azyx/Screens/Anime/Details/widgets/character_grid.dart';
import 'package:azyx/Screens/Anime/Details/widgets/community_charts.dart';
import 'package:azyx/Screens/Anime/Details/widgets/details_error.dart';
import 'package:azyx/Screens/Anime/Details/widgets/details_skeleton.dart';
import 'package:azyx/Screens/Anime/Details/widgets/details_top_bar.dart';
import 'package:azyx/Screens/Anime/Details/widgets/episode_grid.dart';
import 'package:azyx/Screens/Anime/Details/widgets/hero_backdrop.dart';
import 'package:azyx/Screens/Anime/Details/widgets/hero_section.dart';
import 'package:azyx/Screens/Anime/Details/widgets/list_sheet.dart';
import 'package:azyx/Screens/Anime/Details/widgets/mobile_dock.dart';
import 'package:azyx/Screens/Anime/Details/widgets/poster_row.dart';
import 'package:azyx/Screens/Anime/Details/widgets/search_overlay.dart';
import 'package:azyx/Screens/Anime/Details/widgets/section_tabs.dart';
import 'package:azyx/Screens/Anime/Details/widgets/side_column.dart';
import 'package:azyx/Screens/Anime/Details/widgets/synopsis_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AnimeDetailsScreen extends StatefulWidget {
  final String? tagg;
  final CarousaleData? smallMedia;
  final OfflineItem? allData;
  final bool isOffline;
  final int? id;

  const AnimeDetailsScreen({
    super.key,
    this.tagg,
    this.isOffline = false,
    this.smallMedia,
    this.allData,
    this.id,
  });

  static Route<void> route({
    String? tagg,
    CarousaleData? smallMedia,
    OfflineItem? allData,
    bool isOffline = false,
    int? id,
  }) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(
        name: '/anime_details_' + (id != null ? id.toString() : (smallMedia != null ? smallMedia.id : (tagg ?? ''))),
      ),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => AnimeDetailsScreen(
        tagg: tagg,
        smallMedia: smallMedia,
        allData: allData,
        isOffline: isOffline,
        id: id,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  late final String _controllerTag;
  late final AnimeDetailsController _controller;
  final GlobalKey _tabsKey = GlobalKey();
  final ValueNotifier<bool> _showStickyTabs = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final animeId = _resolveAnimeId();
    _controllerTag = widget.tagg ??
        'anime_${animeId ?? DateTime.now().millisecondsSinceEpoch}';

    _controller = Get.put(
      AnimeDetailsController(),
      tag: _controllerTag,
    );

    if (widget.smallMedia != null) {
      _controller.mediaData.value = AnilistMediaData(
        id: widget.smallMedia!.id,
        title: widget.smallMedia!.title,
        image: widget.smallMedia!.image,
        coverImage: widget.smallMedia!.image,
      );
    }

    _controller.initialize(
      animeId: animeId ?? 0,
      offlineData: widget.allData,
      isOffline: widget.isOffline,
    );

    _controller.scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleScroll();
    });
  }

  void _handleScroll() {
    final renderBox =
        _tabsKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && mounted) {
      final position = renderBox.localToGlobal(Offset.zero);
      final topPadding = MediaQuery.of(context).padding.top;
      final threshold = topPadding + 56.0;
      final shouldShow = position.dy <= threshold;
      if (_showStickyTabs.value != shouldShow) {
        _showStickyTabs.value = shouldShow;
      }
    }
  }

  @override
  void dispose() {
    _controller.scrollController.removeListener(_handleScroll);
    _showStickyTabs.dispose();
    Get.delete<AnimeDetailsController>(tag: _controllerTag);
    super.dispose();
  }

  int? _resolveAnimeId() {
    if (widget.id != null) return widget.id;
    if (widget.allData?.mediaData?.id != null) {
      return int.tryParse(widget.allData!.mediaData!.id!);
    }
    if (widget.smallMedia?.id != null) {
      return int.tryParse(widget.smallMedia!.id);
    }
    return null;
  }

  void _openListSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListSheet(controller: _controller),
    );
  }

  void _navigateToMedia(int targetId) {
    Navigator.of(context).push(
      AnimeDetailsScreen.route(
        id: targetId,
        tagg: 'anime_$targetId',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isDesktop = AzTokens.isExpanded(context);

    return Obx(() {
      final media = _controller.mediaData.value;
      final tones = AzTones.fromScheme(
        theme.colorScheme,
      );

      final isLoading = _controller.isLoading.value;
      final hasError = _controller.error.value.isNotEmpty;

      final isNotYetReleased =
          media.status?.toUpperCase() == 'NOT_YET_RELEASED';
      final isCurrentlyWatching =
          _controller.listStatus.value == 'Currently watching';

      final primaryLabel = isNotYetReleased
          ? 'Not released yet'
          : (isCurrentlyWatching ? 'Continue watching' : 'Start watching');

      final listButtonLabel = _controller.listStatus.value.isNotEmpty
          ? _controller.listStatus.value
          : 'Add to list';

      final isListOn = _controller.listStatus.value.isNotEmpty;
      final isFav = _controller.isFavourite.value;

      final relations = PosterRow.fromRelations(media.relations);
      final recommendations =
          PosterRow.fromRecommendations(media.recommendations);
      final hasRelationsOrRecs =
          relations.isNotEmpty || recommendations.isNotEmpty;

      final hasInitialData = (media.title != null && media.title!.isNotEmpty) ||
          widget.smallMedia != null ||
          widget.allData != null;

      return AzTonesProvider(
        tones: tones,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.slash): () {
              if (!_controller.isSearchOpen.value) {
                _controller.openSearch();
              }
            },
          },
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
                if (isLoading && !hasInitialData)
                  const DetailsSkeleton()
                else if (hasError && !hasInitialData)
                  DetailsError(
                    errorMessage: _controller.error.value,
                    onRetry: () => _controller.loadData(),
                    onSearch: () => _controller.openSearch(),
                  )
                else
                  NotificationListener<ScrollNotification>(
                    onNotification: (_) {
                      _handleScroll();
                      return false;
                    },
                    child: CustomScrollView(
                      controller: _controller.scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: HeroSection(
                            media: media,
                            primaryLabel: primaryLabel,
                            listButtonLabel: listButtonLabel,
                            isListOn: isListOn,
                            isFavourite: isFav,
                            onWatchTap: () =>
                                _controller.onPrimaryAction(context),
                            onListTap: () => _openListSheet(context),
                            onFavTap: () => _controller.toggleFavourite(),
                            heroTag: widget.tagg,
                            isLoading: isLoading,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              key: _tabsKey,
                              constraints: const BoxConstraints(
                                maxWidth: AzTokens.contentMaxWidth,
                              ),
                              child: SectionTabs(controller: _controller),
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
                              isDesktop ? AzTokens.horizontalPadding : 16.0,
                              isDesktop ? 28.0 : 16.0,
                              isDesktop ? AzTokens.horizontalPadding : 16.0,
                              24.0,
                            ),
                            child: isDesktop
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              key: _controller.sectionKeys['ov'],
                                              child:
                                                  SynopsisBlock(media: media, isLoading: isLoading),
                                            ),
                                            const SizedBox(
                                                height: AzTokens.sectionGap),
                                            Container(
                                              key: _controller.sectionKeys['ep'],
                                              child: EpisodeGrid(
                                                controller: _controller,
                                              ),
                                            ),
                                            if (hasRelationsOrRecs) ...[
                                              const SizedBox(
                                                  height: AzTokens.sectionGap),
                                              Container(
                                                key: _controller
                                                    .sectionKeys['rl'],
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (relations.isNotEmpty)
                                                      PosterRow(
                                                        title: 'Related',
                                                        items: relations,
                                                        onItemTapped:
                                                            _navigateToMedia,
                                                      ),
                                                    if (recommendations
                                                        .isNotEmpty)
                                                      PosterRow(
                                                        title:
                                                            'Fans also liked',
                                                        isSubheading: true,
                                                        items: recommendations,
                                                        onItemTapped:
                                                            _navigateToMedia,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            const SizedBox(
                                                height: AzTokens.sectionGap),
                                            Container(
                                              key: _controller.sectionKeys['ch'],
                                              child: CharacterGrid(
                                                characters: media.characters,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AzTokens.sectionGap),
                                            Container(
                                              key: _controller.sectionKeys['cm'],
                                              child: CommunityCharts(
                                                media: media,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 56),
                                      SizedBox(
                                        width: 320,
                                        child: SideColumn(media: media),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        key: _controller.sectionKeys['ov'],
                                        child: SynopsisBlock(media: media, isLoading: isLoading),
                                      ),
                                      const SizedBox(height: 28.0),
                                      Container(
                                        key: _controller.sectionKeys['ep'],
                                        child: EpisodeGrid(
                                          controller: _controller,
                                        ),
                                      ),
                                      if (hasRelationsOrRecs) ...[
                                        const SizedBox(height: 28.0),
                                        Container(
                                          key: _controller.sectionKeys['rl'],
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (relations.isNotEmpty)
                                                PosterRow(
                                                  title: 'Related',
                                                  items: relations,
                                                  onItemTapped:
                                                      _navigateToMedia,
                                                ),
                                              if (recommendations.isNotEmpty)
                                                PosterRow(
                                                  title: 'Fans also liked',
                                                  isSubheading: true,
                                                  items: recommendations,
                                                  onItemTapped:
                                                      _navigateToMedia,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 28.0),
                                      Container(
                                        key: _controller.sectionKeys['ch'],
                                        child: CharacterGrid(
                                          characters: media.characters,
                                        ),
                                      ),
                                      const SizedBox(height: 28.0),
                                      Container(
                                        key: _controller.sectionKeys['cm'],
                                        child: CommunityCharts(
                                          media: media,
                                        ),
                                      ),
                                      const SizedBox(height: 28.0),
                                      SideColumn(media: media),
                                      const SizedBox(height: 96),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: DetailsTopBar(
                    onSearchTap: () => _controller.openSearch(),
                    showBackButton: Navigator.of(context).canPop(),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showStickyTabs,
                  builder: (context, show, _) {
                    if (!show) return const SizedBox.shrink();
                    return Positioned(
                      top: topPadding + 56.0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: AzTokens.contentMaxWidth,
                          ),
                          child: SectionTabs(controller: _controller),
                        ),
                      ),
                    );
                  },
                ),
                if (!isDesktop && !isLoading && !hasError)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MobileDock(
                      primaryLabel: primaryLabel,
                      onWatchTap: () =>
                          _controller.onPrimaryAction(context),
                      onListTap: () => _openListSheet(context),
                      onFavTap: () => _controller.toggleFavourite(),
                      isFavourite: isFav,
                      isListOn: isListOn,
                    ),
                  ),
                AzToast(controller: _controller),
                SearchOverlay(
                  controller: _controller,
                  onSelectMedia: _navigateToMedia,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
