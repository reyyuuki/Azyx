import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:flutter/material.dart';

class ShimmerEffect extends StatelessWidget {
  final double height;
  final double width;
  const ShimmerEffect({super.key, required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AzyXContainer(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      height: height,
      width: width,
    );
  }
}
