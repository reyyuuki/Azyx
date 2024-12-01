
import 'package:azyx/Provider/theme_provider.dart';
import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final void Function(double) onChanged;
  final void Function(double)? onDragStart;
  final void Function(double)? onDragEnd;
  final int? divisions;
  final RoundedSliderValueIndicator? customValueIndicatorSize;
  const CustomSlider({
    super.key,
    required this.onChanged,
    required this.max,
    required this.min,
    required this.value,
    this.onDragEnd,
    this.onDragStart,
    this.divisions,
    this.customValueIndicatorSize,
  });

  @override
  State<CustomSlider> createState() => CustomSliderState();
}

class CustomSliderState extends State<CustomSlider> {
  @override
  void initState() {
    super.initState();
    if (widget.customValueIndicatorSize != null) {
      valueIndicator = widget.customValueIndicatorSize!;
    } else {
      valueIndicator = RoundedSliderValueIndicator(
        ThemeProvider().themeData.colorScheme,
          width: 35,
          height: 30,
          radius: 10,
          );
    }
  }

  late RoundedSliderValueIndicator valueIndicator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderThemeData(
        thumbColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.inverseSurface,
        valueIndicatorShape: valueIndicator,
        trackShape: const MarginedTrack(),
        valueIndicatorTextStyle: TextStyle(
          color: colorScheme.surface,
          fontFamily: "Poppins",
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: colorScheme.primary,
        trackHeight: 13,
        thumbShape:
            RoundedRectangularThumbShape(width: 10, radius: 4, colorScheme),
        overlayColor: Colors.white,
        overlayShape: RoundedRectangularThumbShape(
            width: 15, radius: 5, height: 30, colorScheme),
        activeTickMarkColor: colorScheme.surface,
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        onChanged: widget.onChanged,
        onChangeStart: widget.onDragStart,
        onChangeEnd: widget.onDragEnd,
        divisions: widget.divisions,
        value: widget.value,
        label: "${widget.value}",
      ),
    );
  }
}

class RoundedSliderValueIndicator extends SliderComponentShape {
  final double width;
  final double height;
  final double radius;
  final bool onBottom;
  final ColorScheme colorScheme;

  RoundedSliderValueIndicator(this.colorScheme,
      {required this.width,
      required this.height,
      this.radius = 5,
      this.onBottom = false});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final verticalValue = onBottom ? 35 : -35;
    final centerWithVerticalOffset =
        Offset(center.dx, center.dy + verticalValue);

    final rect = Rect.fromCenter(
        center: centerWithVerticalOffset, height: height, width: width);

    final TextPainter tp = labelPainter;

    tp.layout();

    context.canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = colorScheme.primary);
    tp.paint(
        context.canvas,
        Offset(center.dx - (tp.width / 2),
            centerWithVerticalOffset.dy - (tp.height / 2)));
  }
}

class MarginedTrack extends SliderTrackShape {
  const MarginedTrack();

  @override
  Rect getPreferredRect(
      {required RenderBox parentBox,
      Offset offset = Offset.zero,
      required SliderThemeData sliderTheme,
      bool isEnabled = true,
      bool isDiscrete = true}) {
    final double overlayWidth =
        sliderTheme.overlayShape!.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight ?? 20;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isEnabled = true,
      bool isDiscrete = true,
      required TextDirection textDirection}) {
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);

    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    Paint leftTrackPaint;
    Paint rightTrackPaint;

    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left, trackRect.top, thumbCenter.dx - 12, trackRect.bottom);
    final Rect rightTrackSegment = Rect.fromLTRB(
        thumbCenter.dx + 12, trackRect.top, trackRect.right, trackRect.bottom);

    context.canvas.drawRRect(
        RRect.fromRectAndRadius(leftTrackSegment, const Radius.circular(5)),
        leftTrackPaint);
    context.canvas.drawRRect(
        RRect.fromRectAndRadius(rightTrackSegment, const Radius.circular(5)),
        rightTrackPaint);
  }
}

class RoundedRectangularThumbShape extends SliderComponentShape {
  final double width;
  final double radius;
  final double height;
  final ColorScheme colorScheme;

  RoundedRectangularThumbShape(this.colorScheme,
      {required this.width, this.radius = 4, this.height = 25});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, 10);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = colorScheme.primary,
    );

    final strokeRect =
        Rect.fromCenter(center: center, width: width, height: height);
    context.canvas.drawRRect(
        RRect.fromRectAndRadius(strokeRect, Radius.circular(radius)),
        Paint()
          ..color = colorScheme.inverseSurface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
  }
}
