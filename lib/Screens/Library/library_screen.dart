import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Library/widgets/grid_list.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeTabController();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AzyXText(
                      text: "Library",
                      fontVariant: FontVariant.bold,
                      fontSize: 20,
                    ),
                    AzyXText(
                      text: "Continue Where You Left Off",
                      color: Theme.of(context).colorScheme.primary,
                      fontVariant: FontVariant.bold,
                      fontSize: 12,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    changeContentSheet();
                  },
                  child: AzyXContainer(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(1.glowMultiplier()),
                            blurRadius: 10.blurMultiplier(),
                            spreadRadius: 2.spreadMultiplier())
                      ],
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          Icon(
                            contentType.value == "Anime"
                                ? Ionicons.logo_youtube
                                : Broken.book,
                            color: Colors.black,
                          ),
                          5.width,
                          AzyXText(
                            text: contentType.value,
                            fontVariant: FontVariant.bold,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainerHigh),
                      padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
                    ),
                    icon: const Icon(Broken.search_normal))
              ],
            ),
          ),
          Expanded(
            child: AzyXGradientContainer(
              child: Column(
                children: [
                  AzyXContainer(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      tabs: contentType.value == "Anime"
                          ? offlineController.offlineAnimeCategories
                              .map((category) {
                              return Tab(
                                text: category.name,
                              );
                            }).toList()
                          : offlineController.offlineMangaCategories
                              .map((category) {
                              return Tab(
                                text: category.name,
                              );
                            }).toList(),
                      labelStyle: const TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins-Bold",
                          color: Colors.black),
                      unselectedLabelStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins-Bold",
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.6)),
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(1.glowMultiplier()),
                                spreadRadius: 2.spreadMultiplier(),
                                blurRadius: 5.blurMultiplier())
                          ]),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabAlignment: TabAlignment.start,
                      automaticIndicatorColorAdjustment: true,
                      indicatorAnimation: TabIndicatorAnimation.elastic,
                      indicatorPadding: const EdgeInsets.all(6),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: contentType.value == "Anime"
                          ? offlineController.offlineAnimeCategories.map((i) {
                              final data = offlineController.offlineAnimeList
                                  .where((item) {
                                return i.anilistIds.contains(item.mediaData.id);
                              }).toList();
                              return GridList(
                                data: data,
                                tagg: i.name!,
                                ontap: (item, tagg) {
                                  Get.to(AnimeDetailsScreen(
                                    tagg: tagg,
                                    allData: item,
                                    isOffline: true,
                                  ));
                                },
                              );
                            }).toList()
                          : offlineController.offlineMangaCategories.map((i) {
                              final data = offlineController.offlineMangaList
                                  .where((item) {
                                return i.anilistIds.contains(item.mediaData.id);
                              }).toList();
                              return GridList(
                                data: data,
                                tagg: i.name!,
                                ontap: (item, tagg) {
                                  contentType.value == "Anime"
                                      ? Get.to(AnimeDetailsScreen(
                                          tagg: tagg,
                                          allData: item,
                                          isOffline: true,
                                        ))
                                      : Get.to(MangaDetailsScreen(
                                          tagg: tagg,
                                          allData: item,
                                          isOffline: true));
                                },
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeContentSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        builder: (context) {
          return AzyXContainer(
            height: 150,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    contentType.value = "Anime";
                    _updateTabController();
                    Future.delayed(
                        const Duration(milliseconds: 300), () => Get.back());
                  },
                  child: listItem(
                    context,
                    "Anime",
                    Ionicons.logo_youtube,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      contentType.value = "Manga";
                      _updateTabController();
                      Future.delayed(
                          const Duration(milliseconds: 300), () => Get.back());
                    },
                    child: listItem(context, "Manga", Broken.book)),
              ],
            ),
          );
        });
  }

  Obx listItem(BuildContext context, String title, IconData icon) {
    return Obx(
      () => AzyXContainer(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: contentType.value == title
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: contentType.value == title
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(1.glowMultiplier())
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(1.glowMultiplier()),
                spreadRadius: 2.spreadMultiplier(),
                blurRadius: 10.blurMultiplier(),
              )
            ],
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: contentType.value == title
                  ? Colors.black
                  : Theme.of(context).colorScheme.inverseSurface,
            ),
            10.width,
            AzyXText(
              text: title,
              fontVariant: FontVariant.bold,
              color: contentType.value == title
                  ? Colors.black
                  : Theme.of(context).colorScheme.inverseSurface,
            )
          ],
        ),
      ),
    );
  }
}
