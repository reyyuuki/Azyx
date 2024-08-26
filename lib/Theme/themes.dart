import 'package:flutter/material.dart';



ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
);
