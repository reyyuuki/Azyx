// ignore_for_file: non_constant_identifier_names
import 'dart:developer';

import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../../../Widgets/common/custom_app_bar.dart';

class UiSettings extends StatelessWidget {
  const UiSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const CustomAppBar(
              title: "UI Settings",
              icon: Broken.designtools,
            ),
            glow_setting(context, provider),
            10.height,
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  settingTitle(context, "Performance settings", Broken.moon),
                  AzyXContainer(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.6))
                        ],
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20))),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Obx(
                            () => Icon(settingsController.isGradient.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          title: const AzyXText(
                            text: "Gradeint effect",
                            fontVariant: FontVariant.bold,
                          ),
                          subtitle: const AzyXText(
                            text: "Disable gradient for better performance",
                            fontSize: 12,
                            fontVariant: FontVariant.bold,
                          ),
                          trailing: Obx(
                            () => Switch(
                                value: settingsController.isGradient.value,
                                onChanged: (value) {
                                  settingsController.gradientToggler(value);
                                }),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  AzyXContainer glow_setting(BuildContext context, ThemeProvider provider) {
    return AzyXContainer(
      margin: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.6))
      ], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          settingTitle(
              context, "Visual Effects Customization", Broken.colorfilter),
          AzyXContainer(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20))),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Ionicons.color_fill),
                    title: AzyXText(
                      text: "Glow Multiplier",
                      fontVariant: FontVariant.bold,
                    ),
                    subtitle: AzyXText(
                      text: "Adjust the glow for your vibe",
                      fontSize: 12,
                      fontVariant: FontVariant.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Obx(
                        () => AzyXText(
                          text: uiSettingController.glowMultiplier
                              .toStringAsFixed(1),
                          fontVariant: FontVariant.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Obx(
                          () => AzyXContainer(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(1.glowMultiplier()),
                                  blurRadius: 5.blurMultiplier())
                            ]),
                            child: CustomSlider(
                                onChanged: (double newValue) {
                                  uiSettingController.glowMultiplier = newValue;
                                },
                                divisions: 10,
                                max: 1.0,
                                min: 0.0,
                                value: double.parse(uiSettingController
                                    .glowMultiplier
                                    .toStringAsFixed(2))),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const AzyXText(
                        text: "1.0",
                        fontVariant: FontVariant.bold,
                      )
                    ],
                  ),
                  10.height,
                  const ListTile(
                    leading: Icon(Ionicons.color_wand),
                    title: AzyXText(
                      text: "Blur Multiplier",
                      fontVariant: FontVariant.bold,
                    ),
                    subtitle: AzyXText(
                      text: "Adjust the blur for your vibe",
                      fontSize: 12,
                      fontVariant: FontVariant.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Obx(
                        () => AzyXText(
                          text: uiSettingController.blurMultiplier
                              .toStringAsFixed(1),
                          fontVariant: FontVariant.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Obx(
                          () => AzyXContainer(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(1.glowMultiplier()),
                                  blurRadius: 5.blurMultiplier())
                            ]),
                            child: CustomSlider(
                                onChanged: (double newValue) {
                                  uiSettingController.blurMultiplier = newValue;
                                },
                                divisions: 10,
                                max: 5.0,
                                min: 1.0,
                                value: double.parse(uiSettingController
                                    .blurMultiplier
                                    .toStringAsFixed(2))),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const AzyXText(
                        text: "5.0",
                        fontVariant: FontVariant.bold,
                      )
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  AzyXContainer settingTitle(
      BuildContext context, String title, IconData icon) {
    return AzyXContainer(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: ListTile(
        leading: Icon(icon),
        title: AzyXText(
          text: title,
          fontVariant: FontVariant.bold,
        ),
      ),
    );
  }
}
