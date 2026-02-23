import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class AnimeHistoryScreen extends StatefulWidget {
  const AnimeHistoryScreen({super.key});

  @override
  State<AnimeHistoryScreen> createState() => _AnimeHistoryScreenState();
}

class _AnimeHistoryScreenState extends State<AnimeHistoryScreen> {
  final RxList<AnimeHistoryItem> historyItems = RxList<AnimeHistoryItem>();
  final RxBool isLoading = RxBool(true);
  final RxString selectedFilter = RxString('All');
  final List<String> filterOptions = [
    'All',
    'Today',
    'This Week',
    'This Month'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.delayed(const Duration(milliseconds: 800), () {
      historyItems.value = _getMockData();
      isLoading.value = false;
    });
  }

  // Enhanced mock data with more variety
  List<AnimeHistoryItem> _getMockData() {
    return [
      AnimeHistoryItem(
        id: 1,
        title: "Attack on Titan: Final Season",
        image:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx131681-ODIRpBIbR5Eu.jpg",
        url:
            "https://anilist.co/anime/131681/Shingeki-no-Kyojin-The-Final-Season/",
        currentEpisode: 5,
        totalEpisodes: 16,
        currentTimeWatched: 18 * 60 + 45,
        totalDuration: 24 * 60,
        source: "Gogoanime",
        lastWatched: DateTime.now().subtract(const Duration(hours: 2)),
        rating: 9.2,
        genre: "Action, Drama",
        status: "Continuing",
      ),
      AnimeHistoryItem(
        id: 2,
        title: "Jujutsu Kaisen Season 2",
        image:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx145064-oNJGBxbDELkW.jpg",
        url: "https://anilist.co/anime/145064/Jujutsu-Kaisen-2nd-Season/",
        currentEpisode: 12,
        totalEpisodes: 23,
        currentTimeWatched: 20 * 60 + 30,
        totalDuration: 24 * 60,
        source: "AnimePahe",
        lastWatched: DateTime.now().subtract(const Duration(days: 1)),
        rating: 8.9,
        genre: "Action, Supernatural",
        status: "Continuing",
      ),
      AnimeHistoryItem(
        id: 3,
        title: "Demon Slayer: Entertainment District Arc",
        image:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx142329-f0a5pIaYnRLS.jpg",
        url: "https://anilist.co/anime/142329/Kimetsu-no-Yaiba-Yuukakuhen/",
        currentEpisode: 3,
        totalEpisodes: 11,
        currentTimeWatched: 15 * 60 + 10,
        totalDuration: 24 * 60 + 30,
        source: "Zoro",
        lastWatched: DateTime.now().subtract(const Duration(days: 2)),
        rating: 8.7,
        genre: "Action, Historical",
        status: "Completed",
      ),
      AnimeHistoryItem(
        id: 4,
        title: "Chainsaw Man",
        image:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx127230-FlochcFsyoF4.png",
        url: "https://anilist.co/anime/127230/Chainsaw-Man/",
        currentEpisode: 8,
        totalEpisodes: 12,
        currentTimeWatched: 22 * 60,
        totalDuration: 24 * 60,
        source: "Crunchyroll",
        lastWatched: DateTime.now().subtract(const Duration(days: 3)),
        rating: 8.5,
        genre: "Action, Horror",
        status: "Continuing",
      ),
      AnimeHistoryItem(
        id: 5,
        title: "Spy x Family",
        image:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx140960-vN39AmOWrVB5.jpg",
        url: "https://anilist.co/anime/140960/SPYFAMILY/",
        currentEpisode: 10,
        totalEpisodes: 25,
        currentTimeWatched: 10 * 60 + 45,
        totalDuration: 24 * 60 + 30,
        source: "Gogoanime",
        lastWatched: DateTime.now().subtract(const Duration(days: 4)),
        rating: 8.8,
        genre: "Comedy, Family",
        status: "Continuing",
      ),
      AnimeHistoryItem(
        id: 6,
        title: "My Hero Academia Season 6",
        image:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx139630-J0jXl0MQWj5n.jpg",
        url: "https://anilist.co/anime/139630/Boku-no-Hero-Academia-6/",
        currentEpisode: 15,
        totalEpisodes: 25,
        currentTimeWatched: 5 * 60 + 30,
        totalDuration: 24 * 60,
        source: "AnimePahe",
        lastWatched: DateTime.now().subtract(const Duration(days: 5)),
        rating: 8.3,
        genre: "Action, School",
        status: "Completed",
      ),
    ];
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatLastWatched(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'continuing':
        return Theme.of(context).colorScheme.primary;
      case 'paused':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
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
                  text: "Watch History",
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
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => _showOptionsBottomSheet(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Broken.more,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    tooltip: "Options",
                  ),
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            _buildFilterChips(context),
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return _buildLoadingState();
                }
                if (historyItems.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildHistoryList(context, historyItems);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                final option = filterOptions[index];
                return Obx(() {
                  final isSelected = selectedFilter.value == option;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      selected: isSelected,
                      label: AzyXText(
                        text: option,
                        fontSize: 12,
                        fontVariant:
                            isSelected ? FontVariant.bold : FontVariant.regular,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (selected) {
                        selectedFilter.value = option;
                      },
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerLow,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Broken.video_play,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            AzyXText(
              text: "No Watch History Yet",
              fontSize: 22,
              fontVariant: FontVariant.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 12),
            AzyXText(
              text:
                  "Your anime watching journey starts here.\nDiscover amazing stories and start watching!",
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/explore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Broken.discover, color: Colors.white),
                label: const AzyXText(
                  text: "Explore Anime",
                  fontSize: 16,
                  fontVariant: FontVariant.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<AnimeHistoryItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildEnhancedHistoryCard(context, item),
        );
      },
    );
  }

  Widget _buildEnhancedHistoryCard(
      BuildContext context, AnimeHistoryItem item) {
    final watchProgress = item.currentTimeWatched / item.totalDuration;
    final percentWatched = (watchProgress * 100).toInt();
    final formattedCurrentTime = _formatDuration(item.currentTimeWatched);
    final formattedTotalTime = _formatDuration(item.totalDuration);
    final formattedLastWatched = _formatLastWatched(item.lastWatched);

    return GestureDetector(
      onTap: () => Get.toNamed('/anime-details/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surfaceContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content row
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Enhanced Image Section
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: item.image,
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                              highlightColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              child: Container(
                                width: 100,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Broken.image,
                                color: Theme.of(context).colorScheme.outline,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                        // Episode badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AzyXText(
                              text: "EP ${item.currentEpisode}",
                              fontSize: 11,
                              fontVariant: FontVariant.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Rating badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 10, color: Colors.white),
                                const SizedBox(width: 2),
                                AzyXText(
                                  text: item.rating.toString(),
                                  fontSize: 9,
                                  fontVariant: FontVariant.bold,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        AzyXText(
                          text: item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                          fontVariant: FontVariant.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),

                        const SizedBox(height: 8),

                        // Genre and Status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status, context)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AzyXText(
                                text: item.status,
                                fontSize: 10,
                                fontVariant: FontVariant.bold,
                                color: _getStatusColor(item.status, context),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Genre
                        AzyXText(
                          text: item.genre,
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(height: 12),

                        // Progress section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AzyXText(
                                  text: "Progress: $percentWatched%",
                                  fontSize: 12,
                                  fontVariant: FontVariant.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                AzyXText(
                                  text:
                                      "${item.currentEpisode}/${item.totalEpisodes}",
                                  fontSize: 12,
                                  fontVariant: FontVariant.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: watchProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom info bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerLow
                    .withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Broken.clock,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      AzyXText(
                        text: "$formattedCurrentTime / $formattedTotalTime",
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AzyXText(
                          text: item.source,
                          fontSize: 10,
                          fontVariant: FontVariant.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AzyXText(
                        text: formattedLastWatched,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            AzyXText(
              text: "History Options",
              fontSize: 20,
              fontVariant: FontVariant.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              context,
              Broken.sort,
              "Sort History",
              "Change sorting order",
              () => Navigator.pop(context),
            ),
            _buildOptionTile(
              context,
              Broken.filter,
              "Filter Options",
              "Advanced filtering",
              () => Navigator.pop(context),
            ),
            _buildOptionTile(
              context,
              Broken.export,
              "Export History",
              "Save your watch history",
              () => Navigator.pop(context),
            ),
            _buildOptionTile(
              context,
              Broken.trash,
              "Clear All History",
              "Remove all watch history",
              () {
                Navigator.pop(context);
                _showClearHistoryDialog(context);
              },
              isDestructive: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: AzyXText(
        text: title,
        fontSize: 16,
        fontVariant: FontVariant.bold,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface,
      ),
      subtitle: AzyXText(
        text: subtitle,
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Broken.warning_2,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            AzyXText(
              text: "Clear Watch History",
              fontVariant: FontVariant.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AzyXText(
                text:
                    "This action cannot be undone. All your watch history will be permanently removed.",
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Broken.info_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AzyXText(
                        text:
                            "This will remove ${historyItems.length} items from your history",
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: AzyXText(
              text: "Cancel",
              fontSize: 14,
              fontVariant: FontVariant.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.error,
                  Theme.of(context).colorScheme.error.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                historyItems.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Watch history cleared"),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const AzyXText(
                text: "Clear All",
                fontSize: 14,
                fontVariant: FontVariant.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced model class for anime history item
class AnimeHistoryItem {
  final int id;
  final String title;
  final String image;
  final String url;
  final int currentEpisode;
  final int totalEpisodes;
  final int currentTimeWatched; // in seconds
  final int totalDuration; // in seconds
  final String source;
  final DateTime lastWatched;
  final double rating;
  final String genre;
  final String status;

  AnimeHistoryItem({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
    required this.currentEpisode,
    required this.totalEpisodes,
    required this.currentTimeWatched,
    required this.totalDuration,
    required this.source,
    required this.lastWatched,
    required this.rating,
    required this.genre,
    required this.status,
  });
}
