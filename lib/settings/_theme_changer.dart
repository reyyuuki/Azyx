import 'package:daizy_tv/components/_colorball.dart';
import 'package:daizy_tv/settings/mode.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';

class ThemeChange extends StatefulWidget {
  const ThemeChange({super.key});

  @override
  State<ThemeChange> createState() => __ThemeChangeState();
}

class __ThemeChangeState extends State<ThemeChange> {
  String? _paletteValue = "Content";
  bool? isMaterial;

  final List<String> _items = [
    "Content",
    "Expressive",
    "Fidelity",
    "FruitSalad",
    "MonoChrome",
    "Neutral",
    "RainBow",
    "TonalSpot",
    "Vibrant"
  ];

 
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    isMaterial = themeProvider.isMaterial;
    _paletteValue = themeProvider.variant;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("App Themes",
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Mode",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Mode(themeProvider: themeProvider),
                  SizedBox(
                    height: 140,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Highlight-Color",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        themeProvider.loadDynamicColors();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: isMaterial!
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .inverseSurface
                                                    : Colors.transparent),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                          Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      themeProvider.isMaterial! ? "Custom" : "",
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  ],
                                ),
                                ColorBall(
                                  color: Colors.red,
                                  name: "Red",
                                ),
                                ColorBall(
                                  color: Colors.green,
                                  name: "Green",
                                ),
                                ColorBall(color: Colors.yellow, name: "Yellow"),
                                ColorBall(
                                  color: Colors.indigo,
                                  name: "Indigo",
                                ),
                                ColorBall(
                                  color: Colors.purple,
                                  name: "Purple",
                                ),
                                ColorBall(color: Colors.pink, name: "pink"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 65,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Palette",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        height: 50,
                        width: 135,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: DropdownButton(
                            isExpanded: true,
                            items: _items.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _paletteValue = newValue;
                              });
                              if (newValue != null) {
                                themeProvider.setPaletteColor(
                                    _paletteValue!); 
                              }
                            },
                            value: _paletteValue,
                            underline: Container(),
                            dropdownColor:
                                Theme.of(context).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(20),
                            icon: Icon(
                              Iconsax.arrow_down_1,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}