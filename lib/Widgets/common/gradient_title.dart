import 'dart:io';

import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GradientTitle extends StatelessWidget {
  final String title;
  GradientTitle({super.key, required this.title});

  final UiSettingController settings = Get.put(UiSettingController());
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => AzyXText(
            title,
            style: TextStyle(
              fontSize: Platform.isAndroid || Platform.isIOS ? 18 : 25,
              fontFamily: "Poppins-Bold",
              shadows: [
                BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(settings.glowMultiplier),
                    blurRadius: 10 * settings.blurMultiplier,
                    spreadRadius: settings.spreadMultiplier)
              ],
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
        ),
        Obx(
          () => Icon(
            Broken.star,
            shadows: [
              BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(settings.glowMultiplier),
                  blurRadius: 10 * settings.blurMultiplier,
                  spreadRadius: settings.spreadMultiplier)
            ],
            size: Platform.isAndroid || Platform.isIOS ? 25 : 35,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
