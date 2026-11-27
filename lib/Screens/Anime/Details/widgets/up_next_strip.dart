import 'dart:math';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpNextStrip extends StatelessWidget {
  final AnimeDetailsController controller;
  final AnilistMediaData media;

  const UpNextStrip({
    super.key,
    required this.controller,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    return Obx(() {
      final totalEps = media.episodes ?? controller.episodesList.length;
      if (totalEps <= 0) return const SizedBox.shrink();

      final watched = controller.listProgress.value.clamp(0, totalEps);
      final remaining = max(0, totalEps - watched);
      final nextEp = min(totalEps, watched + 1);
      final durationMin = media.duration ?? 24;
      final remainingHours = ((remaining * durationMin) / 60.0);
      final hoursLabel = remainingHours >= 1
          ? '${remainingHours.round()} hour${remainingHours.round() == 1 ? '' : 's'}'
          : '${remaining * durationMin} min';

      final episodes = controller.episodesList;
      final upcoming = _resolveUpcomingEpisodes(
        episodes,
        nextEp: nextEp,
        totalEps: totalEps,
      );

      final segmentCount = min(totalEps, 25);
      final watchedSegments = totalEps > 0
          ? ((watched / totalEps) * segmentCount).round().clamp(0, segmentCount)
          : 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AzTokens.radiusCards),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$nextEp',
                  style: TextStyle(
                    fontFamily: 'Poppins-Bold',
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: tones.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remaining == 0 ? 'Completed' : 'Next episode',
                        style: AzTokens.caption(
                          theme.colorScheme.onSurfaceVariant,
                          12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        remaining == 0
                            ? 'All $totalEps episodes watched'
                            : '$remaining episode${remaining == 1 ? '' : 's'} left',
                        style: AzTokens.body(
                          color: theme.colorScheme.onSurface,
                          weight: FontWeight.w700,
                          size: 16.5,
                        ),
                      ),
                      Text(
                        remaining == 0
                            ? '$watched of $totalEps watched'
                            : 'About $hoursLabel to finish, $watched of $totalEps watched',
                        style: AzTokens.caption(
                          theme.colorScheme.onSurfaceVariant,
                          12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(segmentCount, (index) {
                final isWatched = index < watchedSegments;
                final isCurrent = index == watchedSegments && remaining > 0;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      right: index < segmentCount - 1 ? 3 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isWatched
                          ? tones.accent
                          : (isCurrent
                              ? tones.accent.withValues(alpha: 0.55)
                              : theme.colorScheme.surfaceContainerHighest),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: upcoming.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = upcoming[index];
                    return _buildEpisodeCard(
                      context,
                      theme,
                      tones,
                      epNumber: item.number,
                      title: item.title,
                      durationMin: durationMin,
                      thumbnail: item.thumbnail ??
                          media.bannerImage ??
                          media.coverImage ??
                          media.image,
                      onTap: () => controller.scrollToSection('ep'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  List<_UpcomingItem> _resolveUpcomingEpisodes(
    List<Episode> episodes, {
    required int nextEp,
    required int totalEps,
  }) {
    if (episodes.isNotEmpty) {
      final startIdx = max(0, nextEp - 1);
      final slice = episodes.skip(startIdx).take(8).toList();
      if (slice.isNotEmpty) {
        return slice.asMap().entries.map((entry) {
          final ep = entry.value;
          final numVal = int.tryParse(ep.number) ?? (nextEp + entry.key);
          return _UpcomingItem(
            number: numVal,
            title: ep.title?.isNotEmpty == true
                ? ep.title!
                : 'Episode $numVal',
            thumbnail: ep.thumbnail,
          );
        }).toList();
      }
    }

    final count = min(5, max(0, totalEps - nextEp + 1));
    return List.generate(count, (i) {
      final n = nextEp + i;
      return _UpcomingItem(
        number: n,
        title: 'Episode $n',
        thumbnail: null,
      );
    });
  }

  Widget _buildEpisodeCard(
    BuildContext context,
    ThemeData theme,
    AzTones tones, {
    required int epNumber,
    required String title,
    required int durationMin,
    required String? thumbnail,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 176,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: 0.6,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnail != null && thumbnail.isNotEmpty)
              Opacity(
                opacity: 0.22,
                child: CachedNetworkImage(
                  imageUrl: thumbnail,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$epNumber',
                    style: TextStyle(
                      fontFamily: 'Poppins-Bold',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: tones.accent,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AzTokens.body(
                          color: theme.colorScheme.onSurface,
                          weight: FontWeight.w600,
                          size: 13,
                        ),
                      ),
                      Text(
                        '$durationMin min',
                        style: AzTokens.caption(
                          theme.colorScheme.onSurfaceVariant,
                          11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingItem {
  final int number;
  final String title;
  final String? thumbnail;

  const _UpcomingItem({
    required this.number,
    required this.title,
    this.thumbnail,
  });
}
