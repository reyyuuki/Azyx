import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_chip.dart';
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
import 'package:azyx/Screens/Anime/Details/widgets/section_tabs.dart';
import 'package:azyx/Screens/Anime/Details/widgets/side_column.dart';
import 'package:azyx/Screens/Anime/Details/widgets/synopsis_block.dart';
import 'package:azyx/Screens/Anime/Details/widgets/tags_section.dart';
import 'package:azyx/Screens/Anime/Details/widgets/up_next_strip.dart';
import 'package:azyx/Widgets/common/comments_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        name:
            '/anime_details_' +
            (id != null
                ? id.toString()
                : (smallMedia != null ? smallMedia.id : (tagg ?? ''))),
      ),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) =>
          AnimeDetailsScreen(
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
  final ValueNotifier<bool> _showBackButton = ValueNotifier<bool>(true);
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    final animeId = _resolveAnimeId();
    _controllerTag =
        widget.tagg ??
        'anime_${animeId ?? DateTime.now().millisecondsSinceEpoch}';

    _controller = Get.put(AnimeDetailsController(), tag: _controllerTag);

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

    _controller.scrollController.addListener(_handleTopBarScroll);
  }

  void _handleTopBarScroll() {
    if (!_controller.scrollController.hasClients) return;
    final offset = _controller.scrollController.offset;
    if (offset <= 24.0) {
      if (!_showBackButton.value) _showBackButton.value = true;
    } else if (offset > _lastScrollOffset + 6.0) {
      if (_showBackButton.value) _showBackButton.value = false;
    } else if (offset < _lastScrollOffset - 6.0) {
      if (!_showBackButton.value) _showBackButton.value = true;
    }
    _lastScrollOffset = offset;
  }

  @override
  void dispose() {
    _controller.scrollController.removeListener(_handleTopBarScroll);
    _showBackButton.dispose();
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
    Navigator.of(
      context,
    ).push(AnimeDetailsScreen.route(id: targetId, tagg: 'anime_$targetId'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isDesktop = AzTokens.isExpanded(context);

    return Obx(() {
      final media = _controller.mediaData.value;
      final tones = AzTones.fromScheme(theme.colorScheme);

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
      final recommendations = PosterRow.fromRecommendations(
        media.recommendations,
      );
      final hasRelationsOrRecs =
          relations.isNotEmpty || recommendations.isNotEmpty;

      final hasInitialData =
          (media.title != null && media.title!.isNotEmpty) ||
          widget.smallMedia != null ||
          widget.allData != null;

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
              if (isLoading && !hasInitialData)
                const DetailsSkeleton()
              else if (hasError && !hasInitialData)
                DetailsError(
                  errorMessage: _controller.error.value,
                  onRetry: () => _controller.loadData(),
                  onSearch: () => Navigator.of(context).maybePop(),
                )
              else
                CustomScrollView(
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
                        onWatchTap: () => _controller.onPrimaryAction(context),
                        onListTap: () => _openListSheet(context),
                        onFavTap: () => _controller.toggleFavourite(),
                        heroTag: widget.tagg,
                        isLoading: isLoading,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: AzTokens.contentMaxWidth,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop
                                ? AzTokens.horizontalPadding
                                : 18.0,
                          ),
                          child: UpNextStrip(
                            controller: _controller,
                            media: media,
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
                            isDesktop ? AzTokens.horizontalPadding : 18.0,
                            isDesktop ? 32.0 : 24.0,
                            isDesktop ? AzTokens.horizontalPadding : 18.0,
                            24.0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: switch (_controller.activeTab.value) {
                              'ep' => KeyedSubtree(
                                key: const ValueKey('ep'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    EpisodeGrid(controller: _controller),
                                    if (!isDesktop) const SizedBox(height: 96),
                                  ],
                                ),
                              ),
                              'cm' => KeyedSubtree(
                                key: const ValueKey('cm'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (media.id != null &&
                                        media.id!.isNotEmpty)
                                      CommentsSection(
                                        mediaId: media.id!,
                                        mediaTitle:
                                            media.title ??
                                            media.titleRomaji ??
                                            '',
                                        mediaPoster:
                                            media.coverImage ??
                                            media.image ??
                                            '',
                                        isManga: false,
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
                                              isLoading: isLoading,
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
                                        isLoading: isLoading,
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
                                        onMuteTag: (tagName) => _controller
                                            .showToast('Muted "$tagName"'),
                                      ),
                                    ],
                                    const SizedBox(height: AzTokens.sectionGap),
                                    CharacterGrid(characters: media.characters),
                                    if (hasRelationsOrRecs) ...[
                                      const SizedBox(
                                        height: AzTokens.sectionGap,
                                      ),
                                      if (relations.isNotEmpty)
                                        PosterRow(
                                          title: 'Related',
                                          items: relations,
                                          onItemTapped: _navigateToMedia,
                                        ),
                                      if (recommendations.isNotEmpty)
                                        PosterRow(
                                          title: 'Fans also liked',
                                          isSubheading: true,
                                          items: recommendations,
                                          onItemTapped: _navigateToMedia,
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
                  ),
                ),
              ),
              if (!isDesktop && !isLoading && !hasError)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MobileDock(
                    primaryLabel: primaryLabel,
                    onWatchTap: () => _controller.onPrimaryAction(context),
                    onListTap: () => _openListSheet(context),
                    onFavTap: () => _controller.toggleFavourite(),
                    isFavourite: isFav,
                    isListOn: isListOn,
                  ),
                ),
              AzToast(controller: _controller),
            ],
          ),
        ),
      );
    });
  }
}
