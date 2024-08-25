import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  useMaterial3: true,  // Enable Material 3
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0XFF94FB35),  // Replace with your seed color
    brightness: Brightness.light,
  ),
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  useMaterial3: true,  // Enable Material 3
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0XFF94FB35),  // Replace with your seed color
    brightness: Brightness.dark,
  ),
);
