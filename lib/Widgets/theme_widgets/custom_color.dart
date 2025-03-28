import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
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
              leading: Icon(Broken.color_swatch),
              title: AzyXText(
                text: "Custom Color",
               fontVariant: FontVariant.bold,
              ),
            ),
          ),
          AzyXContainer(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: SizedBox(
              height: 190,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          provider.updateSeedColor(colors[index]['name']);
                        });
                      },
                      child: CustomColorTemplate(
                          color: colors[index]['color'],
                          isBorder:
                              colors[index]['color'] == provider.seedColor,
                          name: colors[index]['name']));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
