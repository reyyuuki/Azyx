// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/episode_bottom_sheet.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodesList extends StatelessWidget {
  final List<Episode> episodeList;
  final String image;
  final String title;
  final int id;
  EpisodesList(
      {super.key,
      required this.episodeList,
      required this.image,
      required this.title,
      required this.id});

  final RxList<Video> epiosdeUrls = RxList();
  final Rx<String> episodeTitle = ''.obs;
  AnimeAllData playerData = AnimeAllData();
  final Rx<bool> hasError = false.obs;

  Future<void> fetchEpisodeLink(
      String url, String number, String setTitle, context) async {
    try {
      final response = await sourceController.activeSource.value!.methods
          .getVideoList(DEpisode(episodeNumber: number, url: url));
      if (response.isNotEmpty) {
        epiosdeUrls.value = response;
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
        log("Selected URL: $url");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WatchScreen(
                playerData: AnimeAllData(
                    url: url,
                    episodeTitle: episodeTitle.value,
                    title: title,
                    number: number,
                    image: image,
                    id: id,
                    episodeUrls: epiosdeUrls.value,
                    episodeList: episodeList),
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
        children: episodeList.map((episode) {
      return GestureDetector(
        onTap: () {
          if (episodeTitle.value == episode.title) {
            showEpisodeBottomSheet(
              context,
              episode.number,
              epiosdeUrls,
              hasError,
              (context, name, url, number) =>
                  serverAzyXContainer(context, name, url, number),
            );
          } else {
            epiosdeUrls.value = [];
            hasError.value = false;
            showEpisodeBottomSheet(
              context,
              episode.number,
              epiosdeUrls,
              hasError,
              (context, name, url, number) =>
                  serverAzyXContainer(context, name, url, number),
            );
            fetchEpisodeLink(episode.url!, episode.number, title, context);
          }
        },
        child: AzyXContainer(
          height: 100,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Stack(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  child: SizedBox(
                    height: 100,
                    width: 150,
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const ShimmerEffect(height: 100, width: 150),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AzyXText(
                      text: episode.title!.length > 25
                          ? '${episode.title!.substring(0, 25)}...'
                          : episode.title!,
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontVariant: FontVariant.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AzyXText(
                    text: 'Ep- ${episode.number}',
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ],
            ),
            // Positioned(
            //   bottom:
            //       0,
            //   right:
            //       0,
            //   child:
            //       GestureDetector(
            //     onTap: () {
            //       showloader();
            //       fetchm3u8(episodeNumber);
            //     },
            //     child: AzyXContainer(
            //       height: 27,
            //       width: 45,
            //       decoration: BoxDecoration(
            //         color: Theme.of(context).colorScheme.secondary,
            //         borderRadius: const BorderRadius.only(
            //           topLeft: Radius.circular(20),
            //           bottomRight: Radius.circular(10),
            //         ),
            //       ),
            //       child: Icon(Icons.download_for_offline, color: Theme.of(context).colorScheme.inversePrimary),
            //     ),
            //   ),
            // ),
          ]),
        ),
      );
    }).toList());
  }
}
