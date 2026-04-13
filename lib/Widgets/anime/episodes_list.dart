// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/episode_bottom_sheet.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  final Rx<String> episodeTitle = ''.obs;
  final Rx<bool> hasError = false.obs;
  final RxList<Video> episodeUrls = <Video>[].obs;

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
        log('response: ${response.first.quality}');

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
        log("Selected URL: $url");
        await Navigator.push(
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
                episodeUrls: episodeUrls,
                episodeList: episodeList,
              ),
            ),
          ),
        );
        serviceHandler.currentMedia.value.status =
            serviceHandler.currentMedia.value.status;
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
            episodeTitle.value = episode.title ?? '';
            hasError.value = false;

            // final stream = sourceController.activeSource.value!.methods
            //     .getVideoListStream(
            //       DEpisode(episodeNumber: episode.number, url: episode.url),
            //     );

            // showModalBottomSheet(
            //   context: context,
            //   shape: const RoundedRectangleBorder(
            //     borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            //   ),
            //   isScrollControlled: true,
            //   enableDrag: true,
            //   elevation: 5,
            //   barrierColor: Colors.black87.withOpacity(0.5),
            //   builder: (_) {
            //     return StreamEpisodeSheet(
            //       stream: stream,
            //       number: episode.number,
            //       title: title,
            //       image: image,
            //       id: id,
            //       episodeList: episodeList,
            //       episodeTitle: episodeTitle,
            //       hasError: hasError,
            //     );
            //   },
            // );

            showEpisodeBottomSheet(
              context,
              episode.number,
              episodeUrls,
              hasError,
              (context, name, url, number) =>
                  serverAzyXContainer(context, name, url, number),
            );
            fetchEpisodeLink(episode.url!, episode.number, title, context);
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

class StreamEpisodeSheet extends StatelessWidget {
  final Stream<Video>? stream;
  final String number;
  final String title;
  final String image;
  final String id;
  final List<Episode> episodeList;
  final Rx<String> episodeTitle;
  final Rx<bool> hasError;

  const StreamEpisodeSheet({
    super.key,
    required this.stream,
    required this.number,
    required this.title,
    required this.image,
    required this.id,
    required this.episodeList,
    required this.episodeTitle,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final RxList<Video> videos = <Video>[].obs;
    final seenUrls = <String>{};
    final colorScheme = Theme.of(context).colorScheme;

    return AzyXGradientContainer(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      height: MediaQuery.of(context).size.height * 0.72,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: StreamBuilder<Video>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                seenUrls.add(
                  '${snapshot.data!.quality}_${snapshot.data!.url}',
                )) {
              videos.add(snapshot.data!);
            }

            if (snapshot.hasError) {
              hasError.value = true;
            }

            return Obx(() {
              final isFetching =
                  snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.active;

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  10.height,
                  AzyXText(
                    text: "Choose Stream",
                    fontSize: 25,
                    fontVariant: FontVariant.bold,
                    color: colorScheme.primary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  AzyXText(
                    text: episodeTitle.value.isEmpty
                        ? 'Episode $number'
                        : 'Episode $number • ${episodeTitle.value}',
                    fontSize: 13,
                    maxLines: 2,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  if (hasError.value && videos.isEmpty)
                    _StreamSheetMessage(
                      icon: Icons.error_outline_rounded,
                      title: 'Unable to load stream links',
                      subtitle:
                          'This source did not return any playable links for this episode.',
                      color: colorScheme.error,
                    )
                  else if (videos.isEmpty && isFetching)
                    const _StreamSheetLoading(
                      title: 'Fetching stream links',
                      subtitle:
                          'Servers and qualities are loading for this episode. This can take a moment.',
                    )
                  else ...[
                    ...videos.map((video) {
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WatchScreen(
                                playerData: AnimeAllData(
                                  url: video.url,
                                  episodeTitle: episodeTitle.value,
                                  title: title,
                                  number: number,
                                  image: image,
                                  id: id,
                                  episodeUrls: videos,
                                  episodeList: episodeList,
                                ),
                              ),
                            ),
                          );
                          serviceHandler.currentMedia.value.status =
                              serviceHandler.currentMedia.value.status;
                        },
                        child: AzyXContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer.withOpacity(
                              0.65,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withOpacity(
                                0.14,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AzyXText(
                                      text: video.quality,
                                      fontSize: 16,
                                      fontVariant: FontVariant.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    const SizedBox(height: 2),
                                    AzyXText(
                                      text: 'Tap to start watching instantly',
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.72),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (isFetching)
                      const _StreamSheetLoading(
                        title: 'Fetching more links',
                        subtitle:
                            'More servers and qualities are still being discovered.',
                        compact: true,
                      ),
                  ],
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

class _StreamSheetLoading extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;

  const _StreamSheetLoading({
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 0 : 12),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  text: title,
                  fontSize: 14,
                  fontVariant: FontVariant.bold,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(height: 2),
                AzyXText(
                  text: subtitle,
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamSheetMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _StreamSheetMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          AzyXText(
            text: title,
            fontSize: 15,
            fontVariant: FontVariant.bold,
            color: colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          AzyXText(
            text: subtitle,
            fontSize: 12,
            color: colorScheme.onSurfaceVariant.withOpacity(0.75),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
