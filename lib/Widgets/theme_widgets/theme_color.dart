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
    final theme = Theme.of(context);
    seedColor = provider.colorName;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Broken.designtools,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                const AzyXText(
                  text: "Color Customization",
                  fontVariant: FontVariant.bold,
                  fontSize: 14,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 48,
            endIndent: 14,
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          _buildColorTile(
            context,
            title: "Dynamic Coloring",
            subtitle: "Automatically pick colors from current wallpaper",
            icon: Broken.colorfilter,
            iconColor: theme.colorScheme.primary,
            trailing: Switch(
              value: provider.isMaterial!,
              onChanged: (bool isTrue) {
                isTrue
                    ? provider.loadDynamicColors()
                    : provider.updateSeedColor(seedColor!);
              },
            ),
          ),
          Divider(
            height: 1,
            indent: 48,
            endIndent: 14,
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          _buildColorTile(
            context,
            title: "Custom Seed Coloring",
            subtitle: "Use custom seed color to change your vibe",
            icon: Broken.brush_1,
            iconColor: theme.colorScheme.secondary,
            trailing: Switch(
              value: !provider.isMaterial!,
              onChanged: (bool isTrue) {
                isTrue
                    ? provider.updateSeedColor(seedColor!)
                    : provider.loadDynamicColors();
              },
            ),
          ),
          Divider(
            height: 1,
            indent: 48,
            endIndent: 14,
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          _buildColorTile(
            context,
            title: "Palette Mode",
            subtitle: "Select custom color palette profile (${provider.variant ?? "Vibrant"})",
            icon: Broken.paintbucket,
            iconColor: theme.colorScheme.tertiary,
            onTap: () {
              paletteBox(context);
            },
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AzyXText(
                    text: title,
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 2),
                  AzyXText(
                    text: subtitle,
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
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
                                        () {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
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
