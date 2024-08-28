import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

Future<ThemeData> buildLightMode() async {
  final corePalette = await DynamicColorPlugin.getCorePalette();
  final seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);

  return ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
  );
}

Future<ThemeData> buildDarkMode() async {
  final corePalette = await DynamicColorPlugin.getCorePalette();
  final seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);

  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
  );
}
