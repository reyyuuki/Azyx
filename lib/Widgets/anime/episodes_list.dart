// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/episode_class.dart';
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
  final String id;

  EpisodesList({
    super.key,
    required this.episodeList,
    required this.image,
    required this.title,
    required this.id,
  });

  final RxList<Video> epiosdeUrls = RxList();
  final Rx<String> episodeTitle = ''.obs;
  AnimeAllData playerData = AnimeAllData();
  final Rx<bool> hasError = false.obs;

  Future<void> fetchEpisodeLink(
    String url,
    String number,
    String setTitle,
    context,
  ) async {
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
                episodeUrls: epiosdeUrls,
                episodeList: episodeList,
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
          child: Container(
            height: 105,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 105,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerEffect(height: 105, width: 140),
                        ),
                        Container(color: Colors.black.withOpacity(0.25)),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(
                              0.4,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Episode ${episode.number}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AzyXText(
                          text: episode.title ?? 'Episode ${episode.number}',
                          fontVariant: FontVariant.bold,
                          fontSize: 14,
                          maxLines: 2,
                          color: colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.35),
                    size: 22,
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
