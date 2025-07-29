import 'dart:io';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GradientTitle extends StatelessWidget {
  final String title;
  const GradientTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Platform.isAndroid || Platform.isIOS ? 18 : 25,
            fontFamily: "Poppins-Bold",
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.inverseSurface,
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
        Obx(
          () => Icon(
            Broken.star,
            shadows: [
              BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(1.glowMultiplier()),
                  blurRadius: 10.blurMultiplier(),
                  spreadRadius: 2..spreadMultiplier())
            ],
            size: Platform.isAndroid || Platform.isIOS ? 25 : 35,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
