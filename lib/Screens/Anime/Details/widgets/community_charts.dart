import 'dart:math';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:azyx/Widgets/common/comments_section.dart';
import 'package:flutter/material.dart';

class CommunityCharts extends StatelessWidget {
  final AnilistMediaData media;
  final bool showHeading;
  final bool showComments;

  const CommunityCharts({
    super.key,
    required this.media,
    this.showHeading = true,
    this.showComments = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    final hasScores =
        media.scoreDistribution != null && media.scoreDistribution!.isNotEmpty;
    const statusKeys = {'COMPLETED', 'PLANNING', 'CURRENT', 'DROPPED', 'PAUSED'};
    final statusItems = (media.statusDistribution ?? [])
        .where((b) => statusKeys.contains(b.status.toUpperCase()))
        .toList();
    final hasStatuses =
        statusItems.fold<int>(0, (sum, b) => sum + b.amount) > 0;

    if (!hasScores && !hasStatuses && !showComments) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeading && (hasScores || hasStatuses)) ...[
          Text('Community', style: AzTokens.h2(context)),
          const SizedBox(height: 18),
        ],
        if (hasScores || hasStatuses)
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn =
                  constraints.maxWidth >= 600 && hasScores && hasStatuses;

              if (isTwoColumn) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildScoreCard(context, theme, tones),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildStatusCard(context, theme, tones),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  if (hasScores) _buildScoreCard(context, theme, tones),
                  if (hasScores && hasStatuses) const SizedBox(height: 16),
                  if (hasStatuses) _buildStatusCard(context, theme, tones),
                ],
              );
            },
          ),
        if (showComments && media.id != null && media.id!.isNotEmpty) ...[
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
    final rawScores = media.scoreDistribution ?? [];
    final sorted = List<AzScoreBucket>.from(rawScores)
      ..sort((a, b) => a.score.compareTo(b.score));
    final maxAmount = sorted.isEmpty
        ? 1
        : max(1, sorted.map((e) => e.amount).reduce(max));

    String insight = 'Voter score distribution.';
    if (sorted.isNotEmpty) {
      final byAmount = List<AzScoreBucket>.from(sorted)
        ..sort((a, b) => b.amount.compareTo(a.amount));
      final top1 = (byAmount.first.score / 10).round().clamp(1, 10);
      if (byAmount.length > 1) {
        final top2 = (byAmount[1].score / 10).round().clamp(1, 10);
        final lo = min(top1, top2);
        final hi = max(top1, top2);
        insight = lo == hi
            ? 'Most voters gave it a $hi.'
            : 'Most voters gave it a $lo or a $hi.';
      } else {
        insight = 'Most voters gave it a $top1.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(22),
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
          Text(
            'How people scored it',
            style: AzTokens.body(
              color: theme.colorScheme.onSurface,
              weight: FontWeight.w600,
              size: 16,
            ),
          ),
          const SizedBox(height: 18),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No score data yet.',
                  style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: _ScoreCurvePainter(
                  buckets: sorted,
                  maxAmount: maxAmount,
                  accent: tones.accent,
                  surface: theme.colorScheme.surfaceContainer,
                  gridColor:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: sorted.map((b) {
                final label = (b.score / 10).round().clamp(1, 10);
                return Text(
                  '$label',
                  style: AzTokens.caption(
                    theme.colorScheme.onSurfaceVariant,
                    11.5,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text(
              insight,
              style: AzTokens.caption(
                theme.colorScheme.onSurfaceVariant,
                12.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, ThemeData theme, AzTones tones) {
    const statusMap = {
      'COMPLETED': 'Completed',
      'PLANNING': 'Planning',
      'CURRENT': 'Watching',
      'DROPPED': 'Dropped',
      'PAUSED': 'Paused',
    };

    const opacities = [1.0, 0.72, 0.50, 0.34, 0.22];

    final rawList = media.statusDistribution ?? [];
    final statusList = rawList
        .where((b) => statusMap.containsKey(b.status.toUpperCase()))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final totalAmount = statusList.fold<int>(0, (sum, b) => sum + b.amount);
    final totalCompact = AzFormatters.compactNumber(totalAmount);

    return Container(
      padding: const EdgeInsets.all(22),
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
          Text(
            'Where it sits in lists',
            style: AzTokens.body(
              color: theme.colorScheme.onSurface,
              weight: FontWeight.w600,
              size: 16,
            ),
          ),
          const SizedBox(height: 18),
          if (statusList.isEmpty || totalAmount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No list data yet.',
                  style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 126,
                  height: 126,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(126, 126),
                        painter: _StatusDonutPainter(
                          buckets: statusList,
                          total: totalAmount,
                          accent: tones.accent,
                          opacities: opacities,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            totalCompact,
                            style: AzTokens.body(
                              color: theme.colorScheme.onSurface,
                              weight: FontWeight.w700,
                              size: 18,
                            ),
                          ),
                          Text(
                            'in lists',
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
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: statusList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bucket = entry.value;
                      final label =
                          statusMap[bucket.status.toUpperCase()] ??
                              bucket.status;
                      final opacity = opacities[index % opacities.length];
                      final formattedCount =
                          AzFormatters.compactNumber(bucket.amount);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: tones.accent.withValues(alpha: opacity),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                label,
                                overflow: TextOverflow.ellipsis,
                                style: AzTokens.body(
                                  color: theme.colorScheme.onSurface,
                                  size: 13,
                                ),
                              ),
                            ),
                            Text(
                              formattedCount,
                              style: AzTokens.caption(
                                theme.colorScheme.onSurfaceVariant,
                                12.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ScoreCurvePainter extends CustomPainter {
  final List<AzScoreBucket> buckets;
  final int maxAmount;
  final Color accent;
  final Color surface;
  final Color gridColor;

  _ScoreCurvePainter({
    required this.buckets,
    required this.maxAmount,
    required this.accent,
    required this.surface,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;

    final basePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      basePaint,
    );

    final points = <Offset>[];
    final count = buckets.length;
    int peakIndex = 0;
    int peakAmount = -1;

    for (int i = 0; i < count; i++) {
      final x = count == 1 ? size.width / 2 : (i / (count - 1)) * size.width;
      final ratio = (buckets[i].amount / maxAmount).clamp(0.0, 1.0);
      final y = size.height - 12 - ratio * (size.height - 24);
      points.add(Offset(x, y));
      if (buckets[i].amount > peakAmount) {
        peakAmount = buckets[i].amount;
        peakIndex = i;
      }
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.28),
          accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = accent
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, strokePaint);

    final peak = points[peakIndex];
    canvas.drawCircle(
      peak,
      6.5,
      Paint()..color = accent.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      peak,
      4.2,
      Paint()..color = accent,
    );
    canvas.drawCircle(
      peak,
      2.0,
      Paint()..color = surface,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCurvePainter oldDelegate) {
    return oldDelegate.buckets != buckets || oldDelegate.accent != accent;
  }
}

class _StatusDonutPainter extends CustomPainter {
  final List<AzStatusBucket> buckets;
  final int total;
  final Color accent;
  final List<double> opacities;

  _StatusDonutPainter({
    required this.buckets,
    required this.total,
    required this.accent,
    required this.opacities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || buckets.isEmpty) return;

    const strokeWidth = 14.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    double startAngle = -pi / 2;
    const gap = 0.04;

    for (int i = 0; i < buckets.length; i++) {
      final sweep = (buckets[i].amount / total) * (2 * pi);
      if (sweep <= 0) continue;
      final drawSweep = max(0.02, sweep - (buckets.length > 1 ? gap : 0));
      final paint = Paint()
        ..color = accent.withValues(alpha: opacities[i % opacities.length])
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, drawSweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _StatusDonutPainter oldDelegate) {
    return oldDelegate.buckets != buckets || oldDelegate.accent != accent;
  }
}
