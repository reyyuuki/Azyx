import 'package:daizy_tv/Provider/themes.dart';
import 'package:daizy_tv/components/_colorball.dart';
import 'package:daizy_tv/components/_theme_template.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';

class ThemeChange extends StatefulWidget {
  const ThemeChange({super.key});

  @override
  State<ThemeChange> createState() => __ThemeChangeState();
}

class __ThemeChangeState extends State<ThemeChange> {
  String? _paletteValue = "TonalSpot";

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
    themeProvider.selectedmode == 'system'
        ? themeProvider.useSystemTheme()
        : () {};
    return Scaffold(
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
                  Mode(themeProvider),
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
                                                color: themeProvider.isMaterial!
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
                                                    Colors.purple,
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
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
                                      style: TextStyle(fontSize: 12),
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
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Theme Variant",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        height: 50,
                        width: 150,
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
                                    newValue); // Call your function with the new value
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

  Padding Mode(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 210,
        decoration: const BoxDecoration(
            border: BorderDirectional(
                bottom: BorderSide(
                    width: 1, color: Color.fromARGB(188, 158, 158, 158)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: () {
                  themeProvider.setLightMode();
                },
                child: ThemeTemplate(
                  isBorder: themeProvider.selectedmode == 'light',
                  topLeft: Colors.white,
                  topRight: Colors.white,
                  bottomLeft: Colors.white,
                  bottomRight: Colors.white,
                  name: "Light",
                )),
            GestureDetector(
                onTap: () {
                  themeProvider.setDarkMode();
                },
                child: ThemeTemplate(
                  isBorder: themeProvider.selectedmode == 'dark',
                  topLeft: Color.fromARGB(193, 0, 0, 0),
                  topRight: Color.fromARGB(193, 0, 0, 0),
                  bottomLeft: Colors.black,
                  bottomRight: Colors.black,
                  name: "Dark",
                )),
            GestureDetector(
                onTap: () {
                  themeProvider.useSystemTheme();
                },
                child: ThemeTemplate(
                  isBorder: themeProvider.selectedmode == 'system',
                  topLeft: Colors.white,
                  topRight: Color.fromARGB(193, 0, 0, 0),
                  bottomLeft: Colors.white,
                  bottomRight: Colors.black,
                  name: "System",
                )),
          ],
        ),
      ),
    );
  }
}
