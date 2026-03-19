import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/episodes_list.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  final Rx<String> episodeTitle = ''.obs;
  final Rx<bool> hasError = false.obs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: anifyEpisodes.map((entry) {
        return GestureDetector(
          onTap: () {
            if (entry.url == null || entry.url!.isEmpty) {
              hasError.value = true;
              return;
            }

            episodeTitle.value = entry.title ?? '';
            hasError.value = false;

            final stream = sourceController.activeSource.value!.methods
                .getVideoListStream(
                  DEpisode(episodeNumber: entry.number, url: entry.url),
                );

            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              isScrollControlled: true,
              enableDrag: true,
              elevation: 5,
              barrierColor: Colors.black87.withOpacity(0.5),
              builder: (_) {
                return StreamEpisodeSheet(
                  stream: stream,
                  number: entry.number,
                  title: title,
                  image: image,
                  id: id,
                  episodeList: anifyEpisodes,
                  episodeTitle: episodeTitle,
                  hasError: hasError,
                );
              },
            );
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
