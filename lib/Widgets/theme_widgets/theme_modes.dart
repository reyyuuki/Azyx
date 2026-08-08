import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/theme_widgets/theme_template.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ThemeModes extends StatefulWidget {
  const ThemeModes({super.key});
  @override
  State<ThemeModes> createState() => _ThemeModesState();
}

class _ThemeModesState extends State<ThemeModes> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
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
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Broken.brush_2,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const AzyXText(
                  text: "Theme Mode",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    provider.setLightMode();
                  },
                  child: ThemeTemplate(
                    color: Colors.white,
                    isBorder: provider.isLightMode,
                    name: "Light Mode",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    provider.setDarkMode();
                  },
                  child: ThemeTemplate(
                    color: const Color.fromARGB(255, 31, 31, 31),
                    isBorder: provider.isDarkMode,
                    name: "Dark Mode",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    provider.oledTheme();
                  },
                  child: ThemeTemplate(
                    color: Colors.black,
                    isBorder: !provider.isDarkMode! && !provider.isLightMode!,
                    name: "OLED Mode",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
