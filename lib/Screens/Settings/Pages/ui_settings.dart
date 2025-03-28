// ignore_for_file: non_constant_identifier_names
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: glow_setting(context, provider),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: blur_setting(context, provider),
            )
          ],
        ),
      ),
    );
  }

  AzyXContainer blur_setting(BuildContext context, ThemeProvider provider) {
    return AzyXContainer(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.6))
      ], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          AzyXContainer(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            child: const ListTile(
              leading: Icon(Broken.blur),
              title: AzyXText(
                text: "Color Blur",
                fontVariant: FontVariant.bold,
              ),
            ),
          ),
          AzyXContainer(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20))),
              child: Column(
                children: [
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
                                  blurRadius: 5..blurMultiplier())
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
                  )
                ],
              )),
        ],
      ),
    );
  }

  AzyXContainer glow_setting(BuildContext context, ThemeProvider provider) {
    return AzyXContainer(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.6))
      ], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          AzyXContainer(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            child: const ListTile(
              leading: Icon(Broken.colorfilter),
              title: AzyXText(
                text: "Color Glow",
                fontVariant: FontVariant.bold,
              ),
            ),
          ),
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
                  )
                ],
              )),
        ],
      ),
    );
  }
}
