import 'package:flutter/material.dart';

const Color seedColor = Colors.purple;

ThemeData lightmode = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor:
        ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light)
            .surface);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor:
        ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark)
            .surface);
