import 'package:azyx/Providers/theme_provider.dart';
import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final double? secondaryTrackValue;
  final void Function(double) onChanged;
  final void Function(double)? onDragStart;
  final void Function(double)? onDragEnd;
  final int? divisions;
  final RoundedSliderValueIndicator? customValueIndicatorSize;
  final Color? inactveColor;
  final String? indiactorTime;
  final bool? isLocked;
  const CustomSlider(
      {super.key,
      required this.onChanged,
      required this.max,
      required this.min,
      required this.value,
      this.onDragEnd,
      this.onDragStart,
      this.divisions,
      this.customValueIndicatorSize,
      this.secondaryTrackValue,
      this.inactveColor,
      this.indiactorTime,
      this.isLocked});

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
        radius: 50,
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
        inactiveTrackColor:
            widget.inactveColor ?? colorScheme.secondaryContainer,
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
        trackHeight: 12,
        tickMarkShape: SmallTickMarkShape(division: widget.divisions),
        thumbShape: RoundedRectangularThumbShape(
            width: 2, radius: 40, height: 35, colorScheme),
        overlayColor: Colors.white,
        overlayShape: RoundedRectangularThumbShape(
            width: 0, radius: 0, height: 30, colorScheme),
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        onChanged: widget.isLocked! ? null : widget.onChanged,
        onChangeStart: widget.isLocked! ? null : widget.onDragStart,
        onChangeEnd: widget.isLocked! ? null : widget.onDragEnd,
        divisions: widget.divisions,
        value: widget.value,
        secondaryTrackValue: widget.secondaryTrackValue,
        label: "${widget.indiactorTime ?? widget.value}",
      ),
    );
  }
}

class SmallTickMarkShape extends SliderTickMarkShape {
  final double maxSize;
  final int? division;

  const SmallTickMarkShape({this.maxSize = 4, this.division});

  @override
  Size getPreferredSize({
    required bool isEnabled,
    required SliderThemeData sliderTheme,
  }) {
    final int divisions = division ?? 1;
    final double dynamicSize = maxSize / (divisions > 1 ? divisions : 1);
    return Size(dynamicSize, dynamicSize);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    required bool isEnabled,
  }) {
    final int divisions = division ?? 1;
    final double dynamicSize = maxSize / (divisions > 1 ? divisions : 1);
    final bool isActive = center.dx <= thumbCenter.dx;

    final Paint paint = Paint()
      ..color = isActive
          ? sliderTheme.activeTickMarkColor ?? Colors.purple
          : sliderTheme.inactiveTickMarkColor ?? Colors.grey.shade600
      ..style = PaintingStyle.fill;

    context.canvas.drawCircle(center, dynamicSize / 2, paint);
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
    if (sliderTheme.trackHeight == 0) {
      return;
    }
    final verticalValue = onBottom ? 35 : -45;
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
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = true,
    bool isDiscrete = true,
    required TextDirection textDirection,
  }) {
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
        trackRect.left, trackRect.top, thumbCenter.dx - 7, trackRect.bottom);
    final Rect rightTrackSegment = Rect.fromLTRB(
        thumbCenter.dx + 7, trackRect.top, trackRect.right, trackRect.bottom);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(leftTrackSegment, const Radius.circular(50)),
      leftTrackPaint,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rightTrackSegment, const Radius.circular(50)),
      rightTrackPaint,
    );

    if (secondaryOffset != null) {
      final Rect leftSecondaryTrackSegment = Rect.fromLTRB(
          trackRect.left, trackRect.top, thumbCenter.dx - 7, trackRect.bottom);

      final Rect rightSecondaryTrackSegment = Rect.fromLTRB(thumbCenter.dx + 7,
          trackRect.top, secondaryOffset.dx, trackRect.bottom);

      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            leftSecondaryTrackSegment, const Radius.circular(50)),
        Paint()..color = sliderTheme.activeTrackColor!,
      );

      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            rightSecondaryTrackSegment, const Radius.circular(50)),
        Paint()..color = Colors.grey.shade500.withOpacity(0.7),
      );
    }
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
          ..strokeWidth = 2);
  }
}
