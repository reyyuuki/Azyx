import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AzyXContainer extends StatelessWidget {
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  const AzyXContainer({
    super.key,
    this.child,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  Decoration? _processDecoration(
    Decoration? dec, {
    required double rMult,
    required double bMult,
    required double sMult,
    required double gMult,
  }) {
    if (dec == null || dec is! BoxDecoration) return dec;

    BorderRadiusGeometry? newRadius = dec.borderRadius;
    if (newRadius is BorderRadius) {
      newRadius = BorderRadius.only(
        topLeft: Radius.elliptical(
          newRadius.topLeft.x * rMult,
          newRadius.topLeft.y * rMult,
        ),
        topRight: Radius.elliptical(
          newRadius.topRight.x * rMult,
          newRadius.topRight.y * rMult,
        ),
        bottomLeft: Radius.elliptical(
          newRadius.bottomLeft.x * rMult,
          newRadius.bottomLeft.y * rMult,
        ),
        bottomRight: Radius.elliptical(
          newRadius.bottomRight.x * rMult,
          newRadius.bottomRight.y * rMult,
        ),
      );
    }

    List<BoxShadow>? newShadows = dec.boxShadow;
    if (newShadows != null) {
      newShadows = newShadows.map((shadow) {
        return BoxShadow(
          color: shadow.color.withOpacity(
            (shadow.color.opacity * gMult).clamp(0.0, 1.0),
          ),
          offset: shadow.offset,
          blurRadius: shadow.blurRadius * bMult,
          spreadRadius: shadow.spreadRadius * sMult,
          blurStyle: shadow.blurStyle,
        );
      }).toList();
    }

    return dec.copyWith(
      borderRadius: newRadius,
      boxShadow: newShadows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rMult = uiSettingController.radiusMultiplier;
      final bMult = uiSettingController.blurMultiplier;
      final sMult = uiSettingController.spreadMultiplier;
      final gMult = uiSettingController.glowMultiplier;

      final processedDecoration = _processDecoration(
        decoration,
        rMult: rMult,
        bMult: bMult,
        sMult: sMult,
        gMult: gMult,
      );

      return Container(
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: processedDecoration,
        foregroundDecoration: foregroundDecoration,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior,
        child: child,
      );
    });
  }
}
