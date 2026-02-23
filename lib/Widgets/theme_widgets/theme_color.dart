import 'dart:developer';
import 'dart:ui';

import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeColor extends StatefulWidget {
  const ThemeColor({super.key});

  @override
  State<ThemeColor> createState() => _ThemeModesState();
}

class _ThemeModesState extends State<ThemeColor> {
  String? seedColor;
  List<String> paletteList = [
    "Content",
    "Expressive",
    "Fidelity",
    "FruitSalad",
    "MonoChrome",
    "Neutral",
    "RainBow",
    "TonalSpot",
    "Vibrant",
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    seedColor = provider.colorName;
    return AzyXContainer(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.6)),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          AzyXContainer(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const ListTile(
              leading: Icon(Broken.designtools),
              title: AzyXText(
                text: "Customization",
                fontVariant: FontVariant.bold,
              ),
            ),
          ),
          AzyXContainer(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Broken.colorfilter, size: 28),
                  title: const AzyXText(
                    text: "Dynamic Coloring",
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                  subtitle: const AzyXText(
                    text: "Automatically pick colors from current wallpaper",
                    fontSize: 12,
                  ),
                  trailing: Switch(
                    value: Provider.of<ThemeProvider>(context).isMaterial!,
                    onChanged: (bool isTrue) {
                      isTrue
                          ? provider.loadDynamicColors()
                          : provider.updateSeedColor(seedColor!);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Broken.brush_1, size: 28),
                  title: const AzyXText(
                    text: "Custom Coloring",
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                  subtitle: const AzyXText(
                    text: "Use custom color to change your vibe",
                    fontSize: 12,
                  ),
                  trailing: Switch(
                    value: !Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).isMaterial!,
                    onChanged: (bool isTrue) {
                      log(isTrue.toString());
                      isTrue
                          ? provider.updateSeedColor(seedColor!)
                          : provider.loadDynamicColors();
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Broken.paintbucket, size: 28),
                  title: const AzyXText(
                    text: "Palette Color",
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                  subtitle: const AzyXText(
                    text: "Use custom color to change your vibe",
                    fontSize: 12,
                  ),
                  onTap: () {
                    paletteBox(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void paletteBox(BuildContext context) {
    String selectedPalette = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).variant!;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter dialogState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AzyXContainer(color: Colors.black.withOpacity(0.0)),
                  ),
                  AzyXContainer(
                    margin: const EdgeInsets.all(20),
                    child: Dialog(
                      elevation: 20,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AzyXText(
                              text: "Palette Mode",
                              fontSize: 16,
                              fontVariant: FontVariant.bold,
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: paletteList.length,
                                itemBuilder: (context, index) {
                                  bool isSelected =
                                      paletteList[index] == selectedPalette;
                                  return GestureDetector(
                                    onTap: () {
                                      dialogState(() {
                                        selectedPalette = paletteList[index];
                                      });
                                      Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).setPaletteColor(selectedPalette);
                                      Future.delayed(
                                        const Duration(milliseconds: 600),
                                        () => Navigator.pop(context),
                                      );
                                    },
                                    child: AzyXContainer(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceBright,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Broken.main_component,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AzyXText(
                                              text: paletteList[index],
                                              fontVariant: FontVariant.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CheckMark(
                                              strokeWidth: 2,
                                              activeColor: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              inactiveColor: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              duration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              active: isSelected,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
