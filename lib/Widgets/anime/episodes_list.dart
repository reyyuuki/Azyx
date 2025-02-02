// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Classes/player_class.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/video.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/getVideo.dart';
import 'package:azyx/utils/loaders/bottom_sheet_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodesList extends StatelessWidget {
  final List<Episode> episodeList;
  final String image;
  final UiSettingController settings;
  final Source selectedSource;
  final String title;
  final int id;
  EpisodesList(
      {super.key,
      required this.episodeList,
      required this.image,
      required this.selectedSource,
      required this.settings,
      required this.title,
      required this.id});

  final RxList<Video> epiosdeUrls = RxList();
  final Rx<String> episodeTitle = ''.obs;
  PlayerData playerData = PlayerData();

  Future<void> fetchEpisodeLink(
      String url, String number, String setTitle, context) async {
    try {
      final response = await getVideo(source: selectedSource, url: url);
      if (response.isNotEmpty) {
        epiosdeUrls.value = response;
        episodeTitle.value = setTitle;
        Get.back();
        displayBottomSheet(context, number);
      }
    } catch (e) {
      log("Error while fetching episode url: $e");
    }
  }


  void displayBottomSheet(BuildContext context, String number) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          height: 320,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AzyXText(
                  "Select Server",
                  style: TextStyle(fontSize: 25, fontFamily: "Poppins-Bold"),
                ),
                const SizedBox(
                  height: 10,
                ),
                ...epiosdeUrls.map<Widget>((item) {
                  return serverAzyXContainer(
                      context, item.quality, item.url, number);
                }),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
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
                playerData: PlayerData(
                    url: url,
                    episodeTitle: episodeTitle.value,
                    title: title,
                    number: number,
                    image: image,
                    id: id,
                    episodeUrls: epiosdeUrls,
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
        children: episodeList.map((episode) {
      return GestureDetector(
         onTap: () {
          if (episodeTitle.value == episode.title) {
            displayBottomSheet(context, episode.number!);
          } else {
            showloader(context);
            fetchEpisodeLink(episode.url!, episode.number!, title, context);
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
                      episode.title!.length > 25
                          ? '${episode.title!.substring(0, 25)}...'
                          : episode.title!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontFamily: "Poppins-Bold",
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AzyXText(
                    'Ep- ${episode.number}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontWeight: FontWeight.w500,
                    ),
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
