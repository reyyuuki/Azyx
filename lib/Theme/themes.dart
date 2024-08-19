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
    primary: Colors.black,
    secondary: Color(0xFFE0E0E0),
    tertiary: Color(0xFFEAEAEA),
    inverseSurface: const Color.fromARGB(255, 42, 42, 42),
    inversePrimary: Colors.white
  ),

);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.dark(
    surface: Colors.black26 ,
    primary: Colors.indigo.shade400,
    secondary: Color(0xFF222222),
    tertiary: Color(0xFF141414),
    inversePrimary: Colors.black,
    inverseSurface: Colors.white
  ),

);
