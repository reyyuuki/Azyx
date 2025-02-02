import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  final double height; 
  final double width;
  const ShimmerEffect({super.key,required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Theme.of(context).colorScheme.primary,
      child: AzyXContainer(
        color: Colors.grey[400],
        height: height,
        width: width,
      ),
    );
  }
}
