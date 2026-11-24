import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Widgets/AzyXWidgets/m3e_progress_indicator.dart';
import 'package:flutter/material.dart';

class ScoreRing extends StatelessWidget {
  final int? score;
  final double size;
  final double strokeWidth;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 54.0,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    if (score == null || score == 0) {
      return const SizedBox.shrink();
    }

    final tones = AzTonesProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (score!.clamp(0, 100)) / 100.0;

    return Semantics(
      label: 'Average score $score out of 100',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            M3EProgressIndicator.circularWavy(
              value: progress,
              size: size,
              color: tones.accent,
              trackColor: tones.accent.withValues(alpha: 0.18),
              strokeWidth: strokeWidth,
              trackStrokeWidth: strokeWidth,
            ),
            Text(
              score.toString(),
              style: TextStyle(
                fontFamily: 'Poppins-Bold',
                fontSize: (size * 0.35).clamp(11.0, 16.0),
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
