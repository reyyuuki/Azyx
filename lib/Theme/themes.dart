import 'package:flutter/material.dart';


ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFEEEEEE),
    primary: Color.fromARGB(207, 0, 0, 0),
    secondary: Color(0xFFE0E0E0),
    tertiary: Color(0xFFEAEAEA),
    inverseSurface: Color.fromARGB(255, 42, 42, 42),
    inversePrimary: Colors.white
  ),

);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme.dark(
    surface: Colors.black26,
    primary: Color.fromARGB(255, 253, 89, 144),
    secondary: Color(0xFF222222),
    tertiary: Color(0xFF141414),
    inversePrimary: Colors.black,
    inverseSurface: Colors.white
  ),

);
