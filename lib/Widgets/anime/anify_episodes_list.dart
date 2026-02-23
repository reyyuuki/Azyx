// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/episode_bottom_sheet.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnifyEpisodesWidget extends StatelessWidget {
  final RxList<Episode> anifyEpisodes;
  final String title;
  final String id;
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
    String url,
    String number,
    String setTitle,
    context,
  ) async {
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
                episodeUrls: episodeUrls,
                episodeList: anifyEpisodes,
              ),
            ),
          ),
        );
      },
      child: AzyXContainer(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
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
    final colorScheme = Theme.of(context).colorScheme;

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
              hasError.value = false;
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: entry.thumbnail ?? image,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          placeholder: (context, url) => ShimmerEffect(
                            height: 160,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'EP ${entry.number}',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AzyXText(
                        text: entry.title ?? 'Episode ${entry.number}',
                        fontVariant: FontVariant.bold,
                        fontSize: 15,
                        maxLines: 2,
                        color: colorScheme.onSurface,
                      ),
                      if (entry.desc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AzyXText(
                          text: entry.desc,
                          fontSize: 12,
                          maxLines: 3,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
