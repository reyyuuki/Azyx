// ignore_for_file: invalid_use_of_protected_member

import 'dart:math';

import 'package:azyx/AI/ai_pics.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/item_card.dart';
import 'package:azyx/Widgets/common/custom_app_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiRecommendationsPage extends StatefulWidget {
  final bool isManga;
  const AiRecommendationsPage({super.key, required this.isManga});

  @override
  State<AiRecommendationsPage> createState() => _AiRecommendationsPageState();
}

class _AiRecommendationsPageState extends State<AiRecommendationsPage> {
  final RxList<Anime> recommendationsList = RxList();
  final RxBool isAdult = false.obs;
  @override
  void initState() {
    super.initState();
    loadData(isAdult.value);
  }

  void loadData(bool isAdult) async {
    recommendationsList.value = await getAiRecommendations(widget.isManga, 1,
        username: anilistAuthController.userData.value.name, isAdult: isAdult);
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.9, maxHeight);
    return Scaffold(
      body: AzyXGradientContainer(
          child: Column(
        children: [
          30.height,
          CustomAppBar(
            title: "AI Recommendations",
            icon: Broken.setting_2,
            size: 22,
            ontap: () => settingsBottomSheet(),
          ),
          Expanded(
            child: Obx(
              () => recommendationsList.value.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: max(itemCount, minCount),
                          childAspectRatio: gridWidth / gridHeight,
                          crossAxisSpacing: 5),
                      itemCount: recommendationsList.value.length,
                      itemBuilder: (context, index) {
                        final tagg = recommendationsList.value[index].id;
                        final item = recommendationsList.value[index];
                        final CarousaleData data = CarousaleData(
                            id: item.id!,
                            image: item.image!,
                            title: item.title!);
                        return GestureDetector(
                          onTap: () {
                            widget.isManga
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MangaDetailsScreen(
                                              smallMedia: data,
                                              tagg: item.title! +
                                                  item.id.toString(),
                                              isOffline: false,
                                            )))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AnimeDetailsScreen(
                                              smallMedia: data,
                                              tagg: item.title! +
                                                  item.id.toString(),
                                              isOffline: false,
                                            )));
                          },
                          child: ItemCard(item: data, tagg: tagg.toString()),
                        );
                      },
                    ),
            ),
          )
        ],
      )),
    );
  }

  void settingsBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return AzyXGradientContainer(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.eighteen_up_rating,
                    size: 28,
                  ),
                  title: const AzyXText(
                    text: "18+ content",
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                  subtitle: const AzyXText(
                    text: "Show NSFW content in your recommendations",
                    fontSize: 12,
                  ),
                  trailing: Obx(
                    () => Switch(
                        value: isAdult.value,
                        onChanged: (bool isTrue) async {
                          isAdult.value = isTrue;
                          loadData(isTrue);
                        }),
                  ),
                ),
              ],
            ),
          ));
        });
  }
}
