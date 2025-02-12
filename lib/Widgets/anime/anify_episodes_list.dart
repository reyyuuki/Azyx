// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Classes/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/video.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/getVideo.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnifyEpisodesWidget extends StatelessWidget {
  final RxList<Episode> anifyEpisodes;
  final Source selectedSource;
  final String title;
  final int id;
  final String image;
  final AnilistMediaData data;
  AnifyEpisodesWidget(
      {super.key,
      required this.title,
      required this.id,
      required this.anifyEpisodes,
      required this.image,
      required this.data,
      required this.selectedSource});

  final RxList<Video> episodeUrls = RxList();
  final Rx<String> episodeTitle = ''.obs;
  AnimeAllData playerData = AnimeAllData();
  final Rx<bool> hasError = false.obs;

  Future<void> fetchEpisodeLink(
      String url, String number, String setTitle, context) async {
    try {
      final response = await getVideo(source: selectedSource, url: url);
      if (response.isNotEmpty) {
        episodeUrls.value = response;
        episodeTitle.value = setTitle;
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
      log("Error while fetching episode url: $e");
    }
  }

  void displayBottomSheet(BuildContext context, String number) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      enableDrag: true,
      elevation: 5,
      barrierColor: Colors.black87.withOpacity(0.5),
      builder: (context) => AzyXGradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        height: 350,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            AzyXText(
              "Select Quality",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: "Poppins-Bold",
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(
              height: 15,
            ),
            Obx(() => hasError.value
                ? Image.asset(
                    'assets/images/sticker.png',
                    fit: BoxFit.contain,
                  )
                : episodeUrls.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        height: 250,
                        child: const CircularProgressIndicator(),
                      )
                    : Column(
                        children: episodeUrls.map((item) {
                          return serverAzyXContainer(
                              context, item.quality, item.url, number);
                        }).toList(),
                      )),
          ],
        ),
      ),
    );
  }

  GestureDetector serverAzyXContainer(
    BuildContext context,
    String name,
    String url,
    String number,
  ) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WatchScreen(
                playerData: AnimeAllData(
                    url: url,
                    episodeTitle: episodeTitle.value,
                    title: title,
                    number: number,
                    id: id,
                    image: image,
                    source: selectedSource,
                    episodeUrls: episodeUrls,
                    episodeList: anifyEpisodes),
              ),
            ));
      },
      child: AzyXContainer(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 1, color: Theme.of(context).colorScheme.inversePrimary)),
        child: Center(
          child: AzyXText(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: anifyEpisodes.map((entry) {
      return GestureDetector(
        onTap: () {
          if (episodeTitle.value == entry.title) {
            displayBottomSheet(context, entry.number);
          } else {
            episodeUrls.value = [];
            displayBottomSheet(context, entry.number);
            fetchEpisodeLink(entry.url!, entry.number, entry.title!, context);
          }
        },
        child: AzyXContainer(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ]),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: entry.thumbnail ?? image,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          placeholder: (context, url) => ShimmerEffect(
                              height: 150,
                              width: MediaQuery.of(context).size.width),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        left: 0,
                        child: AzyXContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(10)),
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
                          child: AzyXText(
                            entry.number.toString(),
                            style: TextStyle(
                                fontFamily: "Poppins-Bold",
                                fontSize: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ))
                  ],
                ),
                AzyXContainer(
                  padding: const EdgeInsets.all(10),
                  width: Get.width,
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20))),
                  child: Column(
                    children: [
                      AzyXText(
                        entry.title!,
                        style: TextStyle(
                            fontFamily: "Poppins-Bold",
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AzyXText(
                        entry.desc ?? "Enjoy the episode",
                        style: const TextStyle(
                            fontFamily: "Poppins", fontSize: 12),
                        maxLines: 3,
                      )
                    ],
                  ),
                )
              ],
            )),
      );
    }).toList());
  }
}
