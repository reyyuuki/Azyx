import 'dart:math' as math;
import 'package:flutter/material.dart';

class M3EProgressIndicator extends StatefulWidget {
  final double? value;
  final double size;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;
  final double trackStrokeWidth;
  final double gapSize;
  final double? amplitude;
  final double wavelength;
  final bool showTrack;
  final String? semanticsLabel;
  final String? semanticsValue;

  const M3EProgressIndicator.circularWavy({
    super.key,
    this.value,
    this.size = 54.0,
    this.color,
    this.trackColor,
    this.strokeWidth = 3.5,
    this.trackStrokeWidth = 3.5,
    this.gapSize = 2.0,
    this.amplitude,
    this.wavelength = 15.0,
    this.showTrack = true,
    this.semanticsLabel,
    this.semanticsValue,
  });

  @override
  State<M3EProgressIndicator> createState() => _M3EProgressIndicatorState();
}

class _M3EProgressIndicatorState extends State<M3EProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void didUpdateWidget(M3EProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_spinController.isAnimating) {
      _spinController.repeat();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.color ?? theme.colorScheme.primary;
    final trackColor = widget.trackColor ?? activeColor.withValues(alpha: 0.18);
    final amp = widget.amplitude ?? 2.2;

    return Semantics(
      label: widget.semanticsLabel,
      value: widget.semanticsValue,
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _spinController,
            builder: (context, _) {
              return CustomPaint(
                painter: _M3ECircularWavyProgressPainter(
                  progress: widget.value,
                  activeColor: activeColor,
                  trackColor: trackColor,
                  strokeWidth: widget.strokeWidth,
                  trackStrokeWidth: widget.trackStrokeWidth,
                  gapSize: widget.gapSize,
                  amplitude: amp,
                  wavelength: widget.wavelength,
                  rotationFraction: _spinController.value,
                  showTrack: widget.showTrack,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _M3ECircularWavyProgressPainter extends CustomPainter {
  final double? progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;
  final double trackStrokeWidth;
  final double gapSize;
  final double amplitude;
  final double wavelength;
  final double rotationFraction;
  final bool showTrack;

  const _M3ECircularWavyProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
    required this.trackStrokeWidth,
    required this.gapSize,
    required this.amplitude,
    required this.wavelength,
    required this.rotationFraction,
    required this.showTrack,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxStroke = math.max(strokeWidth, trackStrokeWidth);
    final radius = (size.shortestSide - maxStroke) / 2.0 - amplitude;
    if (radius <= 0) return;

    const tau = 2.0 * math.pi;
    final waveCount = math.max(1, ((tau * radius) / wavelength).round());
    final waveK = waveCount / radius;
    final phase = -rotationFraction * tau * waveCount;
    final gapAngle =
        (gapSize + (strokeWidth + trackStrokeWidth) / 2.0) / radius;
    const startAngle = -math.pi / 2.0;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor
      ..isAntiAlias = true;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = activeColor
      ..isAntiAlias = true;

    if (progress == null) {
      final rotAngle = rotationFraction * tau;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotAngle);
      canvas.translate(-center.dx, -center.dy);
      _drawWavy(
        canvas: canvas,
        center: center,
        radius: radius,
        startAngle: startAngle,
        sweepAngle: tau * 0.75,
        amplitude: amplitude,
        waveK: waveK,
        phase: phase,
        paint: activePaint,
      );
      canvas.restore();
      return;
    }

    final p = progress!.clamp(0.0, 1.0);
    final activeSweep = p * tau;

    if (p >= 1.0) {
      _drawWavy(
        canvas: canvas,
        center: center,
        radius: radius,
        startAngle: startAngle,
        sweepAngle: tau,
        amplitude: amplitude,
        waveK: waveK,
        phase: phase,
        paint: activePaint,
      );
      return;
    }

    final appliedGap = math.min(activeSweep, gapAngle);
    final trackSweep = tau - activeSweep - appliedGap * 2.0;

    if (showTrack && trackSweep > 0) {
      _drawWavy(
        canvas: canvas,
        center: center,
        radius: radius,
        startAngle: startAngle + activeSweep + appliedGap,
        sweepAngle: trackSweep,
        amplitude: 0,
        waveK: waveK,
        phase: 0,
        paint: trackPaint,
      );
    }

    if (activeSweep > 0) {
      _drawWavy(
        canvas: canvas,
        center: center,
        radius: radius,
        startAngle: startAngle,
        sweepAngle: activeSweep,
        amplitude: amplitude,
        waveK: waveK,
        phase: phase,
        paint: activePaint,
      );
    }
  }

  void _drawWavy({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required double amplitude,
    required double waveK,
    required double phase,
    required Paint paint,
  }) {
    final path = Path();
    const steps = 140;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = startAngle + sweepAngle * t;
      final arcLength = radius * (angle - startAngle).abs();
      final r = radius + amplitude * math.sin(phase + arcLength * waveK);
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    if (sweepAngle >= 2.0 * math.pi) {
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _M3ECircularWavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotationFraction != rotationFraction ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackStrokeWidth != trackStrokeWidth ||
        oldDelegate.gapSize != gapSize ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.wavelength != wavelength ||
        oldDelegate.showTrack != showTrack;
  }
}
