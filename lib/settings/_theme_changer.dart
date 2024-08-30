import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/components/_theme_template.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';

class ThemeChange extends StatefulWidget {
  const ThemeChange({super.key});

  @override
  State<ThemeChange> createState() => __ThemeChangeState();
}

class __ThemeChangeState extends State<ThemeChange> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeProvider.isSystem == true ? themeProvider.useSystemTheme() : () {};
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
            const Text("Theme"),
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
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Mode(themeProvider),
                  Container(
                    height: 130,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "Highlight-Color",
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                colorBall(Colors.red),
                                colorBall(Colors.blue),
                                colorBall(Colors.green),
                                colorBall(Colors.yellow),
                                colorBall(Colors.indigo),
                                colorBall(Colors.purple),
                                colorBall(Colors.pink),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  GestureDetector colorBall(MaterialColor color){
    return GestureDetector(
      onTap: () { 
        Provider.of<ThemeProvider>(context, listen: false).updateSeedColor(color);
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 2, color: color), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color,
            ),
          ),
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
                  themeProvider.setLightMode("rainbow");
                },
                child: ThemeTemplate(
                  isBorder: themeProvider.isLight,
                  topLeft: Colors.white,
                  topRight: Colors.white,
                  bottomLeft: Colors.white,
                  bottomRight: Colors.white,
                  name: "Light",
                )),
            GestureDetector(
                onTap: () {
                  themeProvider.setDarkMode("expressive");
                },
                child: ThemeTemplate(
                  isBorder: themeProvider.isDark,
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
                  isBorder: themeProvider.isSystem,
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
