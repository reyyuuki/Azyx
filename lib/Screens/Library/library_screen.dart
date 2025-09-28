import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Library/widgets/grid_list.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/Animation/drop_animation.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/main.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  TabController? tabController;
  final Rx<String> contentType = "Anime".obs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });
  }

  void _initializeTabController() {
    tabController = TabController(
      length: contentType.value == "Anime"
          ? offlineController.offlineAnimeCategories.length
          : offlineController.offlineMangaCategories.length,
      vsync: this,
    );
  }

  void _updateTabController() {
    tabController?.dispose();
    _initializeTabController();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
    _searchAnimationController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: BouncePageAnimation(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aesthetic Header with integrated design
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: AzyXText(
                                      text: "MY LIBRARY",
                                      fontVariant: FontVariant.bold,
                                      fontSize: 10,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  8.height,
                                  const AzyXText(
                                    text: "Continue Your",
                                    fontVariant: FontVariant.bold,
                                    fontSize: 28,
                                  ),
                                  const AzyXText(
                                    text: "Journey",
                                    fontVariant: FontVariant.bold,
                                    fontSize: 28,
                                  ),
                                ],
                              ),
                            ),
                            // Content Type Selector with glassmorphism
                            GestureDetector(
                              onTap: () {
                                changeContentSheet();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Obx(
                                  () => Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          contentType.value == "Anime"
                                              ? Ionicons.logo_youtube
                                              : Broken.book,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                      8.height,
                                      AzyXText(
                                        text: contentType.value,
                                        fontVariant: FontVariant.bold,
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        25.height,
                        // Aesthetic Glowing Search Bar
                        AnimatedBuilder(
                          animation: _searchAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withOpacity(
                                          0.1 + (_searchAnimation.value * 0.2),
                                        ),
                                    blurRadius:
                                        20 + (_searchAnimation.value * 10),
                                    spreadRadius:
                                        0 + (_searchAnimation.value * 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary
                                        .withOpacity(
                                          0.1 + (_searchAnimation.value * 0.3),
                                        ),
                                    width: 1 + _searchAnimation.value,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(
                                              0.1 +
                                                  (_searchAnimation.value *
                                                      0.1),
                                            ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Icon(
                                        Broken.search_normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(
                                              0.7 +
                                                  (_searchAnimation.value *
                                                      0.3),
                                            ),
                                        size: 18,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        focusNode: searchFocusNode,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontSize: 16,
                                          fontFamily: "Poppins-Medium",
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Search your library...",
                                          hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                            fontSize: 16,
                                            fontFamily: "Poppins-Regular",
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                        ),
                                      ),
                                    ),
                                    if (searchController.text.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.all(8),
                                        child: GestureDetector(
                                          onTap: () {
                                            searchController.clear();
                                            searchFocusNode.unfocus();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    if (contentType.value == "Anime"
                        ? offlineController.offlineAnimeCategories.isNotEmpty
                        : offlineController.offlineMangaCategories.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: TabBar(
                          controller: tabController,
                          isScrollable: true,
                          tabs: contentType.value == "Anime"
                              ? offlineController.offlineAnimeCategories.map((
                                  category,
                                ) {
                                  return Tab(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: Text(category.name ?? ""),
                                    ),
                                  );
                                }).toList()
                              : offlineController.offlineMangaCategories.map((
                                  category,
                                ) {
                                  return Tab(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: Text(category.name ?? ""),
                                    ),
                                  );
                                }).toList(),
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins-Bold",
                            color: Colors.black,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins-Medium",
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Theme.of(context).colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabAlignment: TabAlignment.start,
                          automaticIndicatorColorAdjustment: true,
                          indicatorAnimation: TabIndicatorAnimation.elastic,
                        ),
                      ),
                    10.height,
                    Expanded(
                      child: contentType.value == "Anime"
                          ? (offlineController.offlineAnimeCategories.isEmpty
                                ? _buildEmptyState()
                                : TabBarView(
                                    controller: tabController,
                                    children: offlineController
                                        .offlineAnimeCategories
                                        .map((i) {
                                          final data = offlineController
                                              .offlineAnimeList
                                              .where((item) {
                                                return i.anilistIds.contains(
                                                  item.mediaData.id,
                                                );
                                              })
                                              .toList();

                                          if (data.isEmpty) {
                                            return _buildCategoryEmptyState(
                                              i.name ?? "Category",
                                            );
                                          }
                                          return GridList(
                                            data: data,
                                            tagg: i.name!,
                                            ontap: (item, tagg) {
                                              Get.to(
                                                AnimeDetailsScreen(
                                                  tagg: tagg,
                                                  allData: item,
                                                  isOffline: true,
                                                ),
                                              );
                                            },
                                          );
                                        })
                                        .toList(),
                                  ))
                          : (offlineController.offlineMangaCategories.isEmpty
                                ? _buildEmptyState()
                                : TabBarView(
                                    controller: tabController,
                                    children: offlineController
                                        .offlineMangaCategories
                                        .map((i) {
                                          final data = offlineController
                                              .offlineMangaList
                                              .where((item) {
                                                return i.anilistIds.contains(
                                                  item.mediaData.id,
                                                );
                                              })
                                              .toList();
                                          if (data.isEmpty) {
                                            return _buildCategoryEmptyState(
                                              i.name ?? "Category",
                                            );
                                          }
                                          return GridList(
                                            data: data,
                                            tagg: i.name!,
                                            ontap: (item, tagg) {
                                              contentType.value == "Anime"
                                                  ? Get.to(
                                                      AnimeDetailsScreen(
                                                        tagg: tagg,
                                                        allData: item,
                                                        isOffline: true,
                                                      ),
                                                    )
                                                  : Get.to(
                                                      MangaDetailsScreen(
                                                        tagg: tagg,
                                                        allData: item,
                                                        isOffline: true,
                                                      ),
                                                    );
                                            },
                                          );
                                        })
                                        .toList(),
                                  )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeContentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AzyXText(
                      text: "Select Content Type",
                      fontVariant: FontVariant.bold,
                      fontSize: 20,
                    ),
                    8.height,
                    AzyXText(
                      text: "Choose what you want to explore",
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    25.height,
                    GestureDetector(
                      onTap: () {
                        contentType.value = "Anime";
                        _updateTabController();
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          () => Get.back(),
                        );
                      },
                      child: modernListItem(
                        context,
                        "Anime",
                        Ionicons.logo_youtube,
                      ),
                    ),
                    15.height,
                    GestureDetector(
                      onTap: () {
                        contentType.value = "Manga";
                        _updateTabController();
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          () => Get.back(),
                        );
                      },
                      child: modernListItem(context, "Manga", Broken.book),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget modernListItem(BuildContext context, String title, IconData icon) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: contentType.value == title
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: contentType.value == title
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: contentType.value == title ? 2 : 1,
          ),
          boxShadow: contentType.value == title
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: contentType.value == title
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: contentType.value == title
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                size: 20,
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AzyXText(
                    text: title,
                    fontVariant: FontVariant.bold,
                    fontSize: 16,
                    color: contentType.value == title
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  4.height,
                  AzyXText(
                    text: "Browse ${title.toLowerCase()} collection",
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            if (contentType.value == title)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          100.height,
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              contentType.value == "Anime"
                  ? Ionicons.library_outline
                  : Broken.book_1,
              size: 50,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
          ),
          40.height,
          AzyXText(
            text: "Your Library is Empty",
            fontVariant: FontVariant.bold,
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          12.height,
          AzyXText(
            text:
                "Start building your ${contentType.value.toLowerCase()} collection",
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            textAlign: TextAlign.center,
          ),
          8.height,
          AzyXText(
            text:
                "Add your favorite ${contentType.value.toLowerCase()} to get started",
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
          60.height,
          Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    index.value = contentType.value == 'Anime' ? 2 : 3;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Broken.search_normal, size: 20),
                      12.width,
                      AzyXText(
                        text: "Discover ${contentType.value}",
                        fontVariant: FontVariant.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              16.height,
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    changeContentSheet();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        contentType.value == "Anime"
                            ? Broken.book
                            : Ionicons.logo_youtube,
                        size: 20,
                      ),
                      12.width,
                      AzyXText(
                        text:
                            "Switch to ${contentType.value == "Anime" ? "Manga" : "Anime"}",
                        fontVariant: FontVariant.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          40.height,
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                AzyXText(
                  text: "What you can do:",
                  fontVariant: FontVariant.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                20.height,
                _buildFeatureItem(
                  Broken.bookmark,
                  "Save Favorites",
                  "Bookmark your favorite titles",
                ),
                _buildFeatureItem(
                  Broken.clock,
                  "Track Progress",
                  "Keep track of your watching/reading progress",
                ),
                _buildFeatureItem(
                  Broken.category,
                  "Organize Categories",
                  "Create custom categories for better organization",
                ),
              ],
            ),
          ),
          50.height,
        ],
      ),
    );
  }

  Widget _buildCategoryEmptyState(String categoryName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          80.height,
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh.withOpacity(0.5),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Icon(
              Broken.folder_open,
              size: 35,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          30.height,
          AzyXText(
            text: "$categoryName is Empty",
            fontVariant: FontVariant.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          12.height,
          AzyXText(
            text:
                "No ${contentType.value.toLowerCase()} found in this category",
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            textAlign: TextAlign.center,
          ),
          40.height,
          Container(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () =>
                  index.value = 'Anime' == contentType.value ? 2 : 3,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              icon: const Icon(Broken.add, size: 18),
              label: AzyXText(
                text: "Add ${contentType.value}",
                fontVariant: FontVariant.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  text: title,
                  fontVariant: FontVariant.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                4.height,
                AzyXText(
                  text: subtitle,
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
