import 'dart:convert';
import 'dart:developer';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Screens/Manga/Read/view/read.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
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

  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'All'.obs;
  final RxBool _isSearching = false.obs;
  final TextEditingController _searchController = TextEditingController();

  void handleTap(LocalHistoryItem item, bool isAnime) {
    if (item.mediaId != null) {
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
              number: item.progress?.replaceAll(RegExp(r'[^0-9]'), '') ?? '1',
              episodeTitle: item.title,
              source: item.sourceName,
              episodeList: item.episodeList,
              episodeUrls: episodeUrls,
              startFromSeconds: item.currentTimeSeconds,
            ),
          ),
        );
      } else {
        final sourceIndex = sourceController.installedMangaExtensions
            .indexWhere((e) => e.name == item.sourceName);

        if (sourceIndex != -1 || item.mangaSourceJson != null) {
          final Source source = sourceIndex != -1
              ? sourceController.installedMangaExtensions[sourceIndex]
              : Source.fromJson(jsonDecode(item.mangaSourceJson!));

          Get.to(
            () => ReadPage(
              source: source,
              link: item.link ?? '',
              chapterList: item.chapterList ?? [],
              mangaTitle: item.title ?? 'Unknown',
              mangaImage: item.image ?? '',
              mediaId: item.mediaId?.toString(),
              syncId: item.mediaId?.toString(),
              initialPage: item.currentPage,
            ),
          );
        }
      }
    } else {
      log('no media id: ${item.mediaId}');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LocalHistoryController>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

  List<LocalHistoryItem> _getFilteredItems(List<LocalHistoryItem> originalItems) {
    var items = originalItems.toList();

    // 1. Time-based filtering
    if (_selectedFilter.value != 'All') {
      final now = DateTime.now();
      items = items.where((e) {
        if (e.lastWatched == null) return false;
        final localLastWatched = e.lastWatched!.toLocal();
        final localNow = now.toLocal();

        switch (_selectedFilter.value) {
          case 'Today':
            return localLastWatched.year == localNow.year &&
                localLastWatched.month == localNow.month &&
                localLastWatched.day == localNow.day;
          case 'This Week':
            final difference = now.difference(e.lastWatched!);
            return difference.inDays <= 7;
          case 'This Month':
            final difference = now.difference(e.lastWatched!);
            return difference.inDays <= 30;
          default:
            return true;
        }
      }).toList();
    }

    // 2. Search query filtering
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      items = items.where((e) => e.title?.toLowerCase().contains(query) ?? false).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: AzyXGradientContainer(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(cs),
              _buildTabBar(cs),
              _buildFilterChips(cs),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Obx(() {
                      final originalItems = _controller.animeWatchingHistory;
                      final items = _getFilteredItems(originalItems);
                      if (items.isEmpty) return _buildEmptyState(context, "Anime");
                      return _buildHistoryList(context, items, true);
                    }),
                    Obx(() {
                      final originalItems = _controller.mangaReadingHistory;
                      final items = _getFilteredItems(originalItems);
                      if (items.isEmpty) return _buildEmptyState(context, "Manga");
                      return _buildHistoryList(context, items, false);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Obx(() {
        final isSearching = _isSearching.value;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isSearching
              ? Container(
                  key: const ValueKey('searchBar'),
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    onChanged: (val) => _searchQuery.value = val,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: cs.primary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          _isSearching.value = false;
                          _searchQuery.value = '';
                          _searchController.clear();
                        },
                      ),
                      hintText: _tabController.index == 0
                          ? 'Search anime history...'
                          : 'Search manga history...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: cs.onSurfaceVariant.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('titleBar'),
                  children: [
                    IconButton(
                      icon: Icon(Broken.arrow_left_2, color: cs.onSurface, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HISTORY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tabController.index == 0 ? 'Anime Watched' : 'Manga Read',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search_rounded, color: cs.onSurface, size: 24),
                      onPressed: () => _isSearching.value = true,
                    ),
                    IconButton(
                      icon: Icon(Broken.trash, color: cs.error, size: 22),
                      onPressed: () => _showClearHistoryDialog(context),
                    ),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildTabBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorColor: cs.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: "Anime"),
            Tab(text: "Manga"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme cs) {
    final filterOptions = ['All', 'Today', 'This Week', 'This Month'];
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          return Obx(() {
            final isSelected = _selectedFilter.value == option;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _selectedFilter.value = option,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary
                        : cs.surfaceContainerHigh.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary
                          : cs.outlineVariant.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AzyXText(
                      text: option,
                      fontSize: 12,
                      fontVariant: isSelected ? FontVariant.bold : FontVariant.regular,
                      color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String type) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(0.15),
                    cs.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: cs.primary.withOpacity(0.1), width: 1.5),
              ),
              child: Icon(
                type == "Anime" ? Broken.video_play : Broken.book,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            AzyXText(
              text: "No $type History",
              fontSize: 18,
              fontVariant: FontVariant.bold,
              color: cs.onSurface,
            ),
            const SizedBox(height: 8),
            Obx(() => AzyXText(
                  text: _searchQuery.value.isNotEmpty
                      ? "Try searching for something else"
                      : "Start exploring to build your history!",
                  fontSize: 13,
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                )),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
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
    final cs = Theme.of(context).colorScheme;
    int currentSecs = item.currentTimeSeconds ?? 0;
    int totalSecs = item.totalDurationSeconds ?? 1;
    if (totalSecs == 0) totalSecs = 1;
    final watchProgress = (currentSecs / totalSecs).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => handleTap(item, isAnime),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: settingsController.isGradient.value
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.surfaceContainerHigh.withOpacity(0.6),
                    cs.surfaceContainerLow.withOpacity(0.4),
                  ],
                )
              : null,
          color: settingsController.isGradient.value
              ? null
              : cs.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Poster image with progress/status overlay on top of shadow container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: item.image ?? '',
                          width: 85,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: cs.surfaceContainerHighest,
                            highlightColor: cs.surfaceContainerLow,
                            child: Container(
                              width: 85,
                              height: 120,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, err) => Container(
                            width: 85,
                            height: 120,
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Broken.image,
                              color: cs.outline,
                            ),
                          ),
                        ),
                      ),
                      // Play Store style circular progress indicator overlayed
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: isAnime
                            ? _PlayStoreProgressIndicator(
                                progress: watchProgress,
                                icon: Icons.play_arrow_rounded,
                                size: 30,
                              )
                            : const _PlayStoreProgressIndicator(
                                progress: 1.0,
                                icon: Icons.menu_book_rounded,
                                size: 30,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Information Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AzyXText(
                        text: item.title ?? 'Unknown',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 15,
                        fontVariant: FontVariant.bold,
                        color: cs.onSurface,
                      ),
                      const SizedBox(height: 6),

                      // Progress text details
                      if (isAnime) ...[
                        if (item.progress != null && item.progress!.isNotEmpty)
                          AzyXText(
                            text: item.progress!,
                            fontSize: 12,
                            color: cs.primary,
                            fontVariant: FontVariant.bold,
                          )
                        else
                          AzyXText(
                            text: "Watching",
                            fontSize: 12,
                            color: cs.primary,
                            fontVariant: FontVariant.bold,
                          ),
                        if (item.totalDurationSeconds != null) ...[
                          const SizedBox(height: 2),
                          AzyXText(
                            text: "${_formatDuration(currentSecs)} / ${_formatDuration(totalSecs)}",
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ],
                      ] else ...[
                        if (item.progress != null && item.progress!.isNotEmpty)
                          AzyXText(
                            text: item.progress!,
                            fontSize: 12,
                            color: cs.primary,
                            fontVariant: FontVariant.bold,
                          )
                        else if (item.currentPage != null)
                          AzyXText(
                            text: "Reading",
                            fontSize: 12,
                            color: cs.primary,
                            fontVariant: FontVariant.bold,
                          ),
                        if (item.currentPage != null) ...[
                          const SizedBox(height: 2),
                          AzyXText(
                            text: "Page ${item.currentPage}",
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ],
                      ],
                      const SizedBox(height: 8),

                      // Badges/Metadata row
                      Row(
                        children: [
                          if (item.sourceName != null && item.sourceName!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: cs.primary.withOpacity(0.15), width: 0.5),
                              ),
                              child: AzyXText(
                                text: item.sourceName!,
                                fontSize: 10,
                                fontVariant: FontVariant.bold,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            Broken.clock,
                            size: 12,
                            color: cs.onSurfaceVariant.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          AzyXText(
                            text: _formatLastWatched(item.lastWatched),
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: cs.errorContainer.withOpacity(0.12),
                    hoverColor: cs.errorContainer.withOpacity(0.2),
                    highlightColor: cs.errorContainer.withOpacity(0.2),
                    padding: const EdgeInsets.all(10),
                  ),
                  icon: Icon(
                    Broken.trash,
                    size: 18,
                    color: cs.error,
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
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAnime = _tabController.index == 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              Broken.warning_2,
              color: cs.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            AzyXText(
              text: isAnime ? "Clear Anime History" : "Clear Manga History",
              fontVariant: FontVariant.bold,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ],
        ),
        content: AzyXText(
          text: "Are you sure you want to clear your entire ${isAnime ? 'anime' : 'manga'} history? This action cannot be undone.",
          fontSize: 14,
          color: cs.onSurfaceVariant,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AzyXText(
              text: "Cancel",
              color: cs.onSurfaceVariant,
              fontVariant: FontVariant.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              if (isAnime) {
                _controller.clearAnimeHistory();
              } else {
                _controller.clearMangaHistory();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${isAnime ? 'Anime' : 'Manga'} history cleared"),
                  backgroundColor: cs.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: AzyXText(
              text: "Clear All",
              color: cs.error,
              fontVariant: FontVariant.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayStoreProgressIndicator extends StatelessWidget {
  final double progress;
  final IconData icon;
  final double size;

  const _PlayStoreProgressIndicator({
    required this.progress,
    required this.icon,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size - 6,
            height: size - 6,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                cs.primary.withOpacity(0.15),
              ),
            ),
          ),
          // Progress track
          SizedBox(
            width: size - 6,
            height: size - 6,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          Icon(
            icon,
            size: size * 0.45,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
