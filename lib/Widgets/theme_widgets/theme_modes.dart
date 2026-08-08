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
  Widget _buildSurfaceStyleChip(
    BuildContext context,
    ThemeProvider provider, {
    required String id,
    required String title,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = provider.darkSurfaceStyle == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setDarkSurfaceStyle(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.12),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 6),
              AzyXText(
                text: title,
                fontSize: 11,
                fontVariant: FontVariant.bold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
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
                  text: "Theme Mode & Dark Surface Style",
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              ],
            ),
          ),
          if (provider.isDarkMode == true) ...[
            Divider(
              height: 1,
              indent: 14,
              endIndent: 14,
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: AzyXText(
                      text: "Dark Background Surface Style",
                      fontSize: 12,
                      fontVariant: FontVariant.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _buildSurfaceStyleChip(
                        context,
                        provider,
                        id: "oled",
                        title: "Pitch Black",
                        color: Colors.black,
                        icon: Icons.brightness_1,
                      ),
                      const SizedBox(width: 8),
                      _buildSurfaceStyleChip(
                        context,
                        provider,
                        id: "slate",
                        title: "Slate Dark",
                        color: const Color(0xFF121212),
                        icon: Icons.dark_mode_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildSurfaceStyleChip(
                        context,
                        provider,
                        id: "deepNavy",
                        title: "Deep Navy",
                        color: const Color(0xFF0D1117),
                        icon: Icons.nightlife_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
