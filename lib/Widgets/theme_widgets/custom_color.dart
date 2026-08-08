import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/theme_widgets/custom_color_template.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class CustomColor extends StatefulWidget {
  const CustomColor({super.key});
  @override
  State<CustomColor> createState() => _ThemeModesState();
}
class _ThemeModesState extends State<CustomColor> {
  final List<Map<String, dynamic>> colors = [
    {"name": "Blue", "color": Colors.blue},
    {"name": "Red", "color": Colors.red},
    {"name": "Orange", "color": Colors.orange},
    {"name": "Pink", "color": Colors.pink},
    {"name": "Grey", "color": Colors.grey},
    {"name": "Brown", "color": Colors.brown},
    {"name": "Indigo", "color": Colors.indigo},
    {"name": "Green", "color": Colors.green},
    {"name": "Yellow", "color": Colors.yellow},
    {"name": "Purple", "color": Colors.purple},
    {"name": "Cyan", "color": Colors.cyan},
    {"name": "Teal", "color": Colors.teal},
    {"name": "Amber", "color": Colors.amber},
    {"name": "LightBlue", "color": Colors.lightBlue},
    {"name": "DeepOrange", "color": Colors.deepOrange},
    {"name": "Lime", "color": Colors.lime},
    {"name": "PinkAccent", "color": Colors.pinkAccent},
  ];
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
                    color: theme.colorScheme.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Broken.color_swatch,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                const AzyXText(
                  text: "Custom Seed Color",
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
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final isSelected = colors[index]['name'] == provider.colorName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        provider.updateSeedColor(colors[index]['name']);
                      });
                    },
                    child: CustomColorTemplate(
                      color: colors[index]['color'],
                      isBorder: isSelected,
                      name: colors[index]['name'],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
