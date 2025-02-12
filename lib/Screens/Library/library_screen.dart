// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';
import 'dart:io';

import 'package:azyx/Classes/offline_item.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(length: offlineController.categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const AzyXText(
            "Library",
            style: TextStyle(fontFamily: "Poppins-Bold"),
          ),
          centerTitle: true,
          bottom: TabBar(
              controller: tabController,
              tabs: offlineController.categories.map((i) {
                return Tab(
                  text: i.name,
                );
              }).toList())),
      body: AzyXGradientContainer(
        padding: const EdgeInsets.all(10),
        child: TabBarView(
            controller: tabController,
            children: offlineController.categories.map((i) {
              final data =
                  offlineController.allOfflineAnime.value.where((item) {
                log('Checking item: ${item.mediaData.id}, Category IDs: ${i.anilistIds}');
                return i.anilistIds.contains(item.mediaData.id);
              });
              return listWidget(data, i.name!);
            }).toList()),
      ),
    );
  }

  ListView listWidget(Iterable<OfflineItem> data, String name) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: data.map((i) {
        final item = i.mediaData;
        final tagg = '$name&${item.id}';
        return GestureDetector(
          onTap: () {
            Get.to(AnimeDetailsScreen(
              allData: i,
              isOffline: true,
              tagg: tagg,
            ));
          },
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AzyXContainer(
                      height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
                      width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(2, 2))
                          ]),
                      child: Hero(
                        tag: tagg,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: item.image!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => ShimmerEffect(
                              height: Platform.isAndroid || Platform.isIOS
                                  ? 150
                                  : 230,
                              width: Platform.isAndroid || Platform.isIOS
                                  ? 103
                                  : 160,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    item.rating != null
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: AzyXContainer(
                              height: 22,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright
                                          .withOpacity(0.6),
                                      blurRadius: 10)
                                ],
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topLeft: Radius.circular(25)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AzyXText(
                                      item.rating!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontFamily: "Poppins-Bold"),
                                    ),
                                    Icon(
                                      Broken.star,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    item.status != null &&
                            (item.status == "RELEASING" ||
                                item.status == "Ongoing")
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            child: AzyXContainer(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 95, 209, 99),
                                  border: Border.all(
                                      width: 2,
                                      color: const Color.fromARGB(
                                          255, 8, 117, 11)),
                                  borderRadius: BorderRadius.circular(20)),
                            ))
                        : const SizedBox.shrink()
                  ],
                ),
                const SizedBox(height: 10),
                AzyXText(
                  Platform.isAndroid || Platform.isIOS
                      ? (item.title!.length > 12
                          ? '${item.title!.substring(0, 10)}...'
                          : item.title!)
                      : (item.title!.length > 20
                          ? '${item.title!.substring(0, 17)}...'
                          : item.title!),
                  style: const TextStyle(fontFamily: "Poppins-Bold"),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
