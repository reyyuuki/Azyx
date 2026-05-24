import 'dart:convert';
import 'dart:ui';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Screens/History/history_screen.dart' as azyx_history;
import 'package:azyx/Screens/Library/manage_library_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Screens/Manga/Read/view/read.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

enum LibraryContentType { anime, manga }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  LibraryContentType _contentType = LibraryContentType.anime;
  Category? _selectedCategory;
  late AnimationController _heroController;
  late Animation<double> _heroFade;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _switchContentType(LibraryContentType type) {
    if (_contentType == type) return;
    _heroController.reset();
    setState(() {
      _contentType = type;
      _selectedCategory = null;
    });
    _heroController.forward();
  }

  List<OfflineItem> _filterItems(List<OfflineItem> all) {
    List<OfflineItem> result = all;
    if (_selectedCategory != null) {
      result = result
          .where(
            (i) =>
                _selectedCategory!.anilistIds?.contains(
                  i.mediaData?.id?.toString(),
                ) ??
                false,
          )
          .toList();
    }
    if (_isSearching && _searchQuery.isNotEmpty) {
      result = result
          .where(
            (i) =>
                (i.mediaData?.title?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false),
          )
          .toList();
    }
    return result;
  }

  void _handleContinueTap(LocalHistoryItem item) {
    final isAnime = _contentType == LibraryContentType.anime;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: cs.surface,
      body: AzyXGradientContainer(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<Category>>(
            stream: _contentType == LibraryContentType.anime
                ? offlineController.getAnimeCategories()
                : offlineController.getMangaCategoriesStream(),
            builder: (context, catSnap) {
              final categories = catSnap.data ?? [];
              if (_selectedCategory != null) {
                try {
                  _selectedCategory = categories.firstWhere(
                    (c) => c.id == _selectedCategory!.id,
                  );
                } catch (_) {
                  _selectedCategory = null;
                }
              }
              return StreamBuilder<List<OfflineItem>>(
                stream: _contentType == LibraryContentType.anime
                    ? offlineController.getOfflineAnimeStream()
                    : offlineController.getOfflineMangaStream(),
                builder: (context, itemSnap) {
                  final allItems = itemSnap.data ?? [];
                  final filtered = _filterItems(allItems);

                  return Obx(() {
                    final histList = _contentType == LibraryContentType.anime
                        ? localHistoryController.animeWatchingHistory
                        : localHistoryController.mangaReadingHistory;
                    final histHero = histList.isNotEmpty
                        ? histList.first
                        : null;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildTopBar(cs)),
                        SliverToBoxAdapter(child: _buildTypeChips(cs)),
                        SliverToBoxAdapter(
                          child: _buildHeroCard(cs, histHero, allItems),
                        ),
                        SliverToBoxAdapter(
                          child: _buildStatsRow(cs, allItems, categories),
                        ),
                        SliverToBoxAdapter(
                          child: _buildCategorySection(
                            cs,
                            categories,
                            allItems,
                          ),
                        ),
                        filtered.isEmpty
                            ? SliverToBoxAdapter(child: _buildEmptyState(cs))
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  24,
                                ),
                                sliver: SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) =>
                                        _buildMediaCard(cs, filtered[i]),
                                    childCount: filtered.length,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.65,
                                      ),
                                ),
                              ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    );
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            ),
          );
        },
        child: _isSearching
            ? Container(
                key: const ValueKey('searchBar'),
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
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
                        setState(() {
                          _isSearching = false;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    ),
                    hintText: _contentType == LibraryContentType.anime
                        ? 'Search anime in library...'
                        : 'Search manga in library...',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY LIBRARY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Collection',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _iconBtn(
                        cs,
                        icon: Icons.search_rounded,
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _iconBtn(
                        cs,
                        icon: Icons.history_rounded,
                        onTap: () =>
                            Get.to(() => const azyx_history.HistoryScreen()),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _iconBtn(
    ColorScheme cs, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
        ),
        child: Icon(icon, color: cs.onSurface, size: 20),
      ),
    );
  }

  Widget _buildTypeChips(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _typeChip(
            cs,
            label: 'Anime',
            icon: Icons.tv_rounded,
            selected: _contentType == LibraryContentType.anime,
            onTap: () => _switchContentType(LibraryContentType.anime),
          ),
          const SizedBox(width: 8),
          _typeChip(
            cs,
            label: 'Manga',
            icon: Icons.menu_book_rounded,
            selected: _contentType == LibraryContentType.manga,
            onTap: () => _switchContentType(LibraryContentType.manga),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(
    ColorScheme cs, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary
              : cs.surfaceContainerHigh.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    ColorScheme cs,
    LocalHistoryItem? histItem,
    List<OfflineItem> allItems,
  ) {
    if (histItem == null) return const SizedBox(height: 14);
    final String? imageUrl = histItem.image;
    final String title = histItem.title ?? '';
    final String progress = histItem.progress ?? '';
    final int mediaId = histItem.mediaId ?? 0;
    final OfflineItem? offlineMatch = allItems.firstWhereOrNull(
      (i) => i.mediaData?.id == mediaId.toString(),
    );

    double prog = 0.0;
    if (histItem.totalDurationSeconds != null &&
        histItem.totalDurationSeconds! > 0) {
      prog =
          ((histItem.currentTimeSeconds ?? 0) / histItem.totalDurationSeconds!)
              .clamp(0.0, 1.0);
    } else if (offlineMatch != null) {
      final int cur = int.tryParse(offlineMatch.number) ?? 0;
      final int total = offlineMatch.mediaData?.episodes ?? 0;
      prog = total > 0 ? (cur / total).clamp(0.0, 1.0) : 0.0;
    }

    final tagg = '$mediaId&hero';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: FadeTransition(
        opacity: _heroFade,
        child: GestureDetector(
          onTap: () {
            if (offlineMatch != null) {
              _contentType == LibraryContentType.anime
                  ? Get.to(
                      () => AnimeDetailsScreen(
                        tagg: tagg,
                        allData: offlineMatch,
                        isOffline: true,
                      ),
                    )
                  : Get.to(
                      () => MangaDetailsScreen(
                        tagg: tagg,
                        allData: offlineMatch,
                        isOffline: true,
                      ),
                    );
            } else {
              _contentType == LibraryContentType.anime
                  ? Get.to(
                      () => AnimeDetailsScreen(
                        tagg: tagg,
                        smallMedia: CarousaleData(
                          id: mediaId.toString(),
                          image: imageUrl ?? '',
                          title: title,
                        ),
                      ),
                    )
                  : Get.to(
                      () => MangaDetailsScreen(
                        tagg: tagg,
                        smallMedia: CarousaleData(
                          id: mediaId.toString(),
                          image: imageUrl ?? '',
                          title: title,
                        ),
                      ),
                    );
            }
          },
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              gradient: settingsController.isGradient.value
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.surfaceContainerHigh.withOpacity(0.7),
                        cs.surfaceContainerLow.withOpacity(0.5),
                      ],
                    )
                  : null,
              color: settingsController.isGradient.value
                  ? null
                  : cs.surfaceContainerHigh.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: cs.surfaceContainerHighest),
                    errorWidget: (_, __, ___) =>
                        Container(color: cs.surfaceContainerHighest),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        cs.surfaceContainerHigh,
                        cs.surfaceContainerHigh.withOpacity(0.85),
                        cs.surfaceContainerHigh.withOpacity(0.2),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _contentType == LibraryContentType.anime
                                  ? 'CONTINUE WATCHING'
                                  : 'CONTINUE READING',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              height: 1.15,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            progress.isNotEmpty ? progress : 'Progress unknown',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: prog,
                                    backgroundColor: cs.outlineVariant
                                        .withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation(
                                      cs.primary,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${(prog * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: () => _handleContinueTap(histItem),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _contentType == LibraryContentType.anime
                            ? Icons.play_arrow_rounded
                            : Icons.menu_book_rounded,
                        color: cs.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    ColorScheme cs,
    List<OfflineItem> items,
    List<Category> cats,
  ) {
    final histCount =
        (_contentType == LibraryContentType.anime
                ? localHistoryController.animeWatchingHistory
                : localHistoryController.mangaReadingHistory)
            .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _statChip(
            cs,
            value: items.length.toString(),
            label: 'Total',
            valueColor: cs.primary,
          ),
          const SizedBox(width: 8),
          _statChip(
            cs,
            value: cats.length.toString(),
            label: 'Lists',
            valueColor: cs.onSurface,
          ),
          const SizedBox(width: 8),
          _statChip(
            cs,
            value: histCount.toString(),
            label: 'History',
            valueColor: cs.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _statChip(
    ColorScheme cs, {
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: valueColor,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    ColorScheme cs,
    List<Category> categories,
    List<OfflineItem> allItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(
                  () => ManageLibraryScreen(
                    isManga: _contentType == LibraryContentType.manga,
                  ),
                ),
                child: Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _categoryPill(cs, null, 'All', allItems.length),
              ...categories.map((cat) {
                final cnt = allItems
                    .where(
                      (i) =>
                          cat.anilistIds?.contains(
                            i.mediaData?.id?.toString(),
                          ) ??
                          false,
                    )
                    .length;
                return _categoryPill(cs, cat, cat.name ?? '', cnt);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryPill(ColorScheme cs, Category? cat, String label, int count) {
    final selected =
        _selectedCategory?.id == cat?.id &&
        (_selectedCategory == null) == (cat == null);
    final displayText = count > 0 ? '$label ($count)' : label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary
              : cs.surfaceContainerHigh.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCard(ColorScheme cs, OfflineItem item) {
    final media = item.mediaData;
    final tagg = '${media?.id}&library';
    final isReleasing =
        media?.status == 'RELEASING' || media?.status == 'Ongoing';
    final cur = int.tryParse(item.number) ?? 0;
    final total = media?.episodes ?? 0;
    final prog = total > 0 ? (cur / total).clamp(0.0, 1.0) : 0.0;
    final genre = (media?.genres?.isNotEmpty == true)
        ? media!.genres!.first
        : '';
    final formattedRating = _formatRating(media?.rating);

    return GestureDetector(
      onTap: () => _contentType == LibraryContentType.anime
          ? Get.to(
              () => AnimeDetailsScreen(
                tagg: tagg,
                allData: item,
                isOffline: true,
              ),
            )
          : Get.to(
              () => MangaDetailsScreen(
                tagg: tagg,
                allData: item,
                isOffline: true,
              ),
            ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: media?.image ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: cs.surfaceContainerHighest,
                        highlightColor: cs.surfaceContainerLow,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                          stops: const [0.0, 0.25, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (formattedRating != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: Colors.black.withOpacity(0.45),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  formattedRating,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _statusBadge(cs, isReleasing, media?.status),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (genre.isNotEmpty) ...[
                    Text(
                      genre.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: cs.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    media?.title ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              total > 0
                                  ? (_contentType == LibraryContentType.anime
                                        ? 'Ep $cur/$total'
                                        : 'Ch $cur/$total')
                                  : (_contentType == LibraryContentType.anime
                                        ? 'Ep $cur'
                                        : 'Ch $cur'),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: cs.onSurfaceVariant.withOpacity(0.8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (total > 0) ...[
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 4,
                                  color: cs.primary.withOpacity(0.12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: prog,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [cs.primary, cs.secondary],
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite_rounded, size: 16, color: cs.primary),
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

  String? _formatRating(String? r) {
    if (r == null || r.isEmpty || r == 'null' || r == '??') return null;
    try {
      final val = double.tryParse(r);
      if (val != null) {
        if (val <= 0.0) return null;
        if (val > 10.0) {
          return (val / 10.0).toStringAsFixed(1);
        }
        return val.toStringAsFixed(1);
      }
    } catch (_) {}
    return r;
  }

  Widget _statusBadge(ColorScheme cs, bool isReleasing, String? status) {
    if (status == 'FINISHED' || status == 'Completed') {
      return const SizedBox.shrink();
    }
    final Color color;
    final String label;
    if (isReleasing) {
      color = const Color(0xFF4CAF50);
      label = 'Active';
    } else {
      color = cs.primary;
      label = 'Saved';
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.black.withOpacity(0.4),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 32,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nothing here yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No titles found in this category',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
