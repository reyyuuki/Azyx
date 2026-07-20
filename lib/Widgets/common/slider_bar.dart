import 'package:flutter/material.dart';
import 'package:azyx/Widgets/common/m3_slider.dart';

class CustomSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final double? secondaryTrackValue;
  final void Function(double) onChanged;
  final void Function(double)? onDragStart;
  final void Function(double)? onDragEnd;
  final int? divisions;
  final dynamic customValueIndicatorSize;
  final Color? inactveColor;
  final String? indiactorTime;
  final bool? isLocked;

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
    this.secondaryTrackValue,
    this.inactveColor,
    this.indiactorTime,
    this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return M3Slider(
      value: value,
      secondaryTrackValue: secondaryTrackValue,
      onChanged: onChanged,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      min: min,
      max: max,
      divisions: divisions,
      indiactorTime: indiactorTime,
      isLocked: isLocked,
      inactiveColor: inactveColor,
    );
  }
}
