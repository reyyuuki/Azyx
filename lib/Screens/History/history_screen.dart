import 'dart:convert';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Screens/Manga/Read/view/read.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final LocalHistoryController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LocalHistoryController>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatLastWatched(DateTime? dateTime) {
    if (dateTime == null) return '';
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: AzyXText(
                  text: "History",
                  fontSize: 20,
                  fontVariant: FontVariant.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3),
                        Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showClearHistoryDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Broken.trash,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  tabs: const [
                    Tab(text: "Anime"),
                    Tab(text: "Manga"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            Obx(() {
              final items = _controller.animeWatchingHistory;
              if (items.isEmpty) return _buildEmptyState(context, "Anime");
              return _buildHistoryList(context, items, true);
            }),
            Obx(() {
              final items = _controller.mangaReadingHistory;
              if (items.isEmpty) return _buildEmptyState(context, "Manga");
              return _buildHistoryList(context, items, false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                type == "Anime" ? Broken.video_play : Broken.book,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            AzyXText(
              text: "No $type History",
              fontSize: 22,
              fontVariant: FontVariant.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<LocalHistoryItem> items,
    bool isAnime,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(context, items[index], isAnime);
      },
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    LocalHistoryItem item,
    bool isAnime,
  ) {
    int currentSecs = item.currentTimeSeconds ?? 0;
    int totalSecs = item.totalDurationSeconds ?? 1;
    if (totalSecs == 0) totalSecs = 1;
    final watchProgress = (currentSecs / totalSecs).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        if (item.mediaId != null) {
          final tgg = "${item.mediaId}History";
          final smallMedia = CarousaleData(
            id: item.mediaId.toString(),
            image: item.image ?? '',
            title: item.title ?? 'Unknown',
          );
          if (isAnime) {
            final decodedList = item.episodeUrlsJson != null
                ? jsonDecode(item.episodeUrlsJson!) as List
                : [];
            final List<Video> episodeUrls = decodedList
                .map((e) => Video.fromJson(e as Map<String, dynamic>))
                .toList();

            Get.to(
              () => WatchScreen(
                playerData: AnimeAllData(
                  id: item.mediaId.toString(),
                  image: item.image ?? '',
                  title: item.title ?? 'Unknown',
                  url: item.link ?? '',
                  number:
                      item.progress?.replaceAll(RegExp(r'[^0-9]'), '') ?? '1',
                  episodeTitle: item.title,
                  source: item.sourceName,
                  episodeList: item.episodeList,
                  episodeUrls: episodeUrls,
                  startFromSeconds: item.currentTimeSeconds,
                ),
              ),
            );
          } else {
            final Source source = sourceController.installedMangaExtensions
                .firstWhere((e) => e.name == item.sourceName);

            Get.to(
              () => ReadPage(
                source: source,
                link: item.link ?? '',
                chapterList: item.chapterList ?? [],
                mangaTitle: item.title ?? 'Unknown',
                syncId: item.mediaId?.toString(),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.image ?? '',
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        highlightColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        child: Container(
                          width: 80,
                          height: 120,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, err) => Container(
                        width: 80,
                        height: 120,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Broken.image,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AzyXText(
                          text: item.title ?? 'Unknown',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                          fontVariant: FontVariant.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        if (isAnime && item.totalDurationSeconds != null) ...[
                          AzyXText(
                            text:
                                "${_formatDuration(currentSecs)} / ${_formatDuration(totalSecs)}",
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontVariant: FontVariant.bold,
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: watchProgress,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 4,
                          ),
                        ] else if (!isAnime && item.currentPage != null) ...[
                          AzyXText(
                            text: "Page ${item.currentPage}",
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontVariant: FontVariant.bold,
                          ),
                        ] else ...[
                          if (item.progress != null &&
                              item.progress!.isNotEmpty)
                            AzyXText(
                              text: item.progress!,
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontVariant: FontVariant.bold,
                            ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (item.sourceName != null &&
                                item.sourceName!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AzyXText(
                                  text: item.sourceName!,
                                  fontSize: 10,
                                  fontVariant: FontVariant.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              Broken.clock,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            AzyXText(
                              text: _formatLastWatched(item.lastWatched),
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Broken.trash,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      if (item.mediaId != null) {
                        if (isAnime) {
                          _controller.removeFromWatchingHistory(item.mediaId!);
                        } else {
                          _controller.removeFromReadingHistory(item.mediaId!);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AzyXText(
          text: "Clear History",
          fontVariant: FontVariant.bold,
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        content: AzyXText(
          text:
              "Are you sure you want to clear your entire history? This action cannot be undone.",
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AzyXText(
              text: "Cancel",
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _controller.clearAnimeHistory();
              } else {
                _controller.clearMangaHistory();
              }
              Navigator.pop(context);
            },
            child: AzyXText(
              text: "Clear",
              color: Theme.of(context).colorScheme.error,
              fontVariant: FontVariant.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
