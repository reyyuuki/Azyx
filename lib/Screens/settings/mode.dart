import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/components/Common/_theme_template.dart';
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
              color:Colors.white,
              name: "Light",
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.themeProvider.setDarkMode();
            },
            child: ThemeTemplate(
              isBorder: widget.themeProvider.isDarkMode,
              color: const Color.fromARGB(255, 31, 31, 31),
              name: "Dark",
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.themeProvider.oledTheme();
            },
            child: ThemeTemplate(
              isBorder: widget.themeProvider.isDarkMode == false && widget.themeProvider.isLightMode == false,
              color: Colors.black,
              name: "Oled",
            ),
          ),
        ],
      ),
    ),
  );
}
}