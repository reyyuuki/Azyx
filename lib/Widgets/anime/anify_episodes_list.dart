// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/episode_bottom_sheet.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartotsu_extension_bridge/Models/DEpisode.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:dartotsu_extension_bridge/Models/Video.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnifyEpisodesWidget extends StatelessWidget {
  final RxList<Episode> anifyEpisodes;
  final String title;
  final int id;
  final String image;
  final AnilistMediaData data;
  AnifyEpisodesWidget({
    super.key,
    required this.title,
    required this.id,
    required this.anifyEpisodes,
    required this.image,
    required this.data,
  });

  final RxList<Video> episodeUrls = RxList();
  final Rx<String> episodeTitle = ''.obs;
  AnimeAllData playerData = AnimeAllData();
  final Rx<bool> hasError = false.obs;

  Future<void> fetchEpisodeLink(
      String url, String number, String setTitle, context) async {
    Utils.log('start');
    try {
      final response = await sourceController.activeSource.value!.methods
          .getVideoList(DEpisode(episodeNumber: number, url: url));
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
                    // source: selectedSource,
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
            text: name,
            fontSize: 18,
            fontVariant: FontVariant.bold,
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
            showEpisodeBottomSheet(
              context,
              entry.number,
              episodeUrls,
              hasError,
              (context, name, url, number) =>
                  serverAzyXContainer(context, name, url, number),
            );
          } else {
            episodeUrls.value = [];
            showEpisodeBottomSheet(
              context,
              entry.number,
              episodeUrls,
              hasError,
              (context, name, url, number) =>
                  serverAzyXContainer(context, name, url, number),
            );
            Utils.log('${entry.url} ?? ${entry.number} ?? ${entry.title}');
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
                            text: entry.number.toString(),
                            fontVariant: FontVariant.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.inversePrimary,
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
                        text: entry.title!,
                        fontVariant: FontVariant.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AzyXText(
                        text: entry.desc,
                        fontSize: 12,
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
