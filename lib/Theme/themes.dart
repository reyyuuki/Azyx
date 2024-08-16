import 'package:flutter/material.dart';

Color color1 = const Color.fromRGBO(10, 233, 20, 1.0);
Color color2 = const Color.fromARGB(237, 247, 146, 14);
Color color3 = const Color.fromARGB(255, 82, 35, 252);
Color color4 = const Color.fromARGB(255, 233, 10, 222);

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(
    surface: Color(0xFFEEEEEE),
    primary: Colors.deepPurple.shade400,
    secondary: Color.fromARGB(255, 92, 81, 81),
    tertiary: Color(0xFFEAEAEA),
  ),

);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.dark(
    surface: Color(0xFFE000000),
    primary: Colors.deepPurple.shade400,
    secondary: Color.fromARGB(155, 248, 220, 220),
    tertiary: Color.fromARGB(255, 90, 88, 88),
  ),

);
