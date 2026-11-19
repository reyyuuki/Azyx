import 'dart:ui';
import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.blurSigma = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceTransparency = MediaQuery.of(context).accessibleNavigation;

    final effectiveFill = fillColor ??
        colorScheme.surfaceContainer.withValues(alpha: reduceTransparency ? 0.98 : 0.64);
    final effectiveBorder = borderColor ??
        colorScheme.onSurface.withValues(alpha: 0.16);

    final decoration = BoxDecoration(
      color: effectiveFill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: effectiveBorder,
        width: borderWidth,
      ),
    );

    if (reduceTransparency) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: child,
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: Container(
            padding: padding,
            decoration: decoration,
            child: child,
          ),
        ),
      ),
    );
  }
}
