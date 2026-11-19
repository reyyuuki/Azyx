import 'dart:math';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:azyx/Widgets/common/comments_section.dart';
import 'package:flutter/material.dart';

class CommunityCharts extends StatelessWidget {
  final AnilistMediaData media;

  const CommunityCharts({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Community', style: AzTokens.h2(context)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTwoColumn = constraints.maxWidth >= 600;

            if (isTwoColumn) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildScoreCard(context, theme, tones),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatusCard(context, theme, tones),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildScoreCard(context, theme, tones),
                const SizedBox(height: 16),
                _buildStatusCard(context, theme, tones),
              ],
            );
          },
        ),
        if (media.id != null && media.id!.isNotEmpty) ...[
          const SizedBox(height: 36),
          CommentsSection(
            mediaId: media.id!,
            mediaTitle: media.title ?? media.titleRomaji ?? '',
            mediaPoster: media.coverImage ?? media.image ?? '',
            isManga: false,
          ),
        ],
      ],
    );
  }

  Widget _buildScoreCard(
      BuildContext context, ThemeData theme, AzTones tones) {
    final scores = media.scoreDistribution ?? [];
    final maxAmount = scores.isEmpty
        ? 1
        : max(1, scores.map((e) => e.amount).reduce(max));

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AzTokens.radiusCards),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How people scored it',
            style: AzTokens.body(
              color: theme.colorScheme.onSurface,
              weight: FontWeight.w600,
              size: 15,
            ),
          ),
          const SizedBox(height: 20),
          if (scores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No score data yet.',
                  style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: scores.map((bucket) {
                  final ratio = bucket.amount / maxAmount;
                  final heightFactor = max(0.04, ratio);
                  final opacity = (0.35 + ratio * 0.65).clamp(0.0, 1.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Tooltip(
                        message: '${bucket.score}: ${bucket.amount} votes',
                        child: FractionallySizedBox(
                          heightFactor: heightFactor,
                          child: Container(
                            decoration: BoxDecoration(
                              color: tones.accent.withValues(alpha: opacity),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lowest',
                  style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  'Highest',
                  style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, ThemeData theme, AzTones tones) {
    const statusMap = {
      'CURRENT': 'Watching',
      'PLANNING': 'Planning',
      'COMPLETED': 'Completed',
      'DROPPED': 'Dropped',
      'PAUSED': 'Paused',
    };

    const opacities = [1.0, 0.75, 0.55, 0.38, 0.24];

    final rawList = media.statusDistribution ?? [];
    final statusList = rawList
        .where((b) => statusMap.containsKey(b.status.toUpperCase()))
        .toList();

    final totalAmount = statusList.fold<int>(0, (sum, b) => sum + b.amount);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AzTokens.radiusCards),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where it sits in lists',
            style: AzTokens.body(
              color: theme.colorScheme.onSurface,
              weight: FontWeight.w600,
              size: 15,
            ),
          ),
          const SizedBox(height: 20),
          if (statusList.isEmpty || totalAmount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No list data yet.',
                  style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: statusList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bucket = entry.value;
                    final opacity = opacities[index % opacities.length];

                    return Expanded(
                      flex: max(1, bucket.amount),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        color: tones.accent.withValues(alpha: opacity),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: statusList.asMap().entries.map((entry) {
                final index = entry.key;
                final bucket = entry.value;
                final label = statusMap[bucket.status.toUpperCase()] ?? bucket.status;
                final opacity = opacities[index % opacities.length];
                final formattedCount = AzFormatters.compactNumber(bucket.amount);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: tones.accent.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AzTokens.body(
                        color: theme.colorScheme.onSurface,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedCount,
                      style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
