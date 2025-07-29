// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'dart:math';

import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Home/UserLists/user_lists.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage>
    with TickerProviderStateMixin {
  TabController? tabController;
  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  void _initializeTabController() {
    tabController = TabController(
      length: anilistDataController.anilistSchedules.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListAppBar(
        title: "Calender",
        ontap: () {},
        subtitle: "Track your favorite anime's weekly schedule.",
      ),
      body: AzyXGradientContainer(
        child: Column(
          children: [
            AzyXContainer(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Obx(
                () => TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabs: anilistDataController.anilistSchedules.value
                      .map((category) {
                    return Tab(
                      text: category.date,
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
            ),
            10.height,
            Expanded(
              child: Obx(
                () => TabBarView(
                    controller: tabController,
                    children:
                        anilistDataController.anilistSchedules.value.map((i) {
                      int itemCount =
                          (MediaQuery.of(context).size.width ~/ 200).toInt();
                      int minCount = 3;
                      double gridWidth = MediaQuery.of(context).size.width /
                          max(itemCount, minCount);
                      double maxHeight =
                          MediaQuery.of(context).size.height / 2.5;
                      double gridHeight = min(gridWidth * 1.9, maxHeight);
                      return Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: max(itemCount, minCount),
                            childAspectRatio: gridWidth / gridHeight,
                          ),
                          itemCount: i.animeList.length,
                          itemBuilder: (context, index) {
                            final item = i.animeList[index];
                            final taggname = "${item.id}";
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AnimeDetailsScreen(
                                            smallMedia: CarousaleData(
                                                id: item.id!,
                                                image: item.image!,
                                                title: item.title!),
                                            tagg: item.title! +
                                                item.id.toString(),
                                            isOffline: false,
                                          ))),
                              child: SizedBox(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      AzyXContainer(
                                        height:
                                            Platform.isAndroid || Platform.isIOS
                                                ? 150
                                                : 230,
                                        width:
                                            Platform.isAndroid || Platform.isIOS
                                                ? 103
                                                : 160,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(45),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                  offset: const Offset(2, 2))
                                            ]),
                                        child: Hero(
                                          tag: taggname,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: CachedNetworkImage(
                                              imageUrl: item.image!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  ShimmerEffect(
                                                height: Platform.isAndroid ||
                                                        Platform.isIOS
                                                    ? 150
                                                    : 230,
                                                width: Platform.isAndroid ||
                                                        Platform.isIOS
                                                    ? 103
                                                    : 160,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      item.rating != null
                                          ? Positioned(
                                              top: 0,
                                              left: 0,
                                              child: AzyXContainer(
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceBright
                                                            .withOpacity(0.6),
                                                        blurRadius: 10)
                                                  ],
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  15)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      AzyXText(
                                                        text: item.rating!,
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontVariant:
                                                            FontVariant.bold,
                                                      ),
                                                      const Icon(
                                                        Icons.star_half,
                                                        size: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AzyXText(
                                    text: Platform.isAndroid || Platform.isIOS
                                        ? (item.title!.length > 12
                                            ? '${item.title!.substring(0, 10)}...'
                                            : item.title!)
                                        : (item.title!.length > 20
                                            ? '${item.title!.substring(0, 17)}...'
                                            : item.title!),
                                    fontVariant: FontVariant.bold,
                                  ),
                                ],
                              )),
                            );
                          },
                        ),
                      );
                    }).toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
