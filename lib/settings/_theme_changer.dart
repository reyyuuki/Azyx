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
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text(
                      "Mode",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () {
                            themeProvider.setLightMode();
                          },
                          child: ThemeTemplate(
                            isBorder: themeProvider.isLight,
                            topLeft: Colors.white,
                            topRight: Colors.white,
                            bottomLeft: Colors.white,
                            bottomRight: Colors.white,
                          )),
                      GestureDetector(
                          onTap: () {
                            themeProvider.setDarkMode();
                          },
                          child: ThemeTemplate(
                            isBorder: themeProvider.isDark,
                            topLeft: Color.fromARGB(193, 0, 0, 0),
                            topRight: Color.fromARGB(193, 0, 0, 0),
                            bottomLeft: Colors.black,
                            bottomRight: Colors.black,
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
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
