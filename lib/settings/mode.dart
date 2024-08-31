import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/components/_theme_template.dart';
import 'package:flutter/material.dart';

class Mode extends StatefulWidget {
  const Mode({
    super.key,
    required this.themeProvider,
  });

  final ThemeProvider themeProvider;

  @override
  State<Mode> createState() => _ModeState();
}

class _ModeState extends State<Mode> {

  @override
  Widget build(BuildContext context) {
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
              widget.themeProvider.setLightMode();
            },
            child: ThemeTemplate(
              isBorder: widget.themeProvider.isLightMode,
              topLeft: Colors.white,
              topRight: Colors.white,
              bottomLeft: Colors.white,
              bottomRight: Colors.white,
              name: "Light",
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.themeProvider.setDarkMode();
            },
            child: ThemeTemplate(
              isBorder: widget.themeProvider.isDarkMode,
              topLeft: const Color.fromARGB(193, 0, 0, 0),
              topRight: const Color.fromARGB(193, 0, 0, 0),
              bottomLeft: Colors.black,
              bottomRight: Colors.black,
              name: "Dark",
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.themeProvider.oledTheme();
            },
            child: ThemeTemplate(
              isBorder: widget.themeProvider.isDarkMode == false && widget.themeProvider.isLightMode == false,
              topLeft: Colors.white,
              topRight: const Color.fromARGB(193, 0, 0, 0),
              bottomLeft: Colors.white,
              bottomRight: Colors.black,
              name: "Oled",
            ),
          ),
        ],
      ),
    ),
  );
}
}