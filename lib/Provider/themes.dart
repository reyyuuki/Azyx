import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';


 MaterialColor? seedColor;

Future<ThemeData> buildLightMode(variant) async {
  final corePalette = await DynamicColorPlugin.getCorePalette();
   final colorseed = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);

      var palette = DynamicSchemeVariant.monochrome;

      switch (variant) {
    case "content":
      palette = DynamicSchemeVariant.content;
      break;
    case "expressive":
      palette = DynamicSchemeVariant.expressive;
      break;
    case "fidelity":
      palette = DynamicSchemeVariant.fidelity;
      break;
    case "fruitSalad":
      palette = DynamicSchemeVariant.fruitSalad;
      break;
    case "monochrome":
      palette = DynamicSchemeVariant.monochrome;
      break;
    case "neutral":
      palette = DynamicSchemeVariant.neutral;
      break;
    case "rainbow":
      palette = DynamicSchemeVariant.rainbow;
      break;
    case "tonalSpot":
      palette = DynamicSchemeVariant.tonalSpot;
      break;
    case "vibrant":
      palette = DynamicSchemeVariant.vibrant;
      break;
    default:
      palette = DynamicSchemeVariant.content;
  }


  return ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorseed,
      brightness: Brightness.light,
      dynamicSchemeVariant: palette,
    ),
  );
}

Future<ThemeData> buildDarkMode(variant) async {
  final corePalette = await DynamicColorPlugin.getCorePalette();
   final colorseed = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);

        var palette = DynamicSchemeVariant.monochrome;

      switch (variant) {
    case "content":
      palette = DynamicSchemeVariant.content;
      break;
    case "expressive":
      palette = DynamicSchemeVariant.expressive;
      break;
    case "fidelity":
      palette = DynamicSchemeVariant.fidelity;
      break;
    case "fruitSalad":
      palette = DynamicSchemeVariant.fruitSalad;
      break;
    case "monochrome":
      palette = DynamicSchemeVariant.monochrome;
      break;
    case "neutral":
      palette = DynamicSchemeVariant.neutral;
      break;
    case "rainbow":
      palette = DynamicSchemeVariant.rainbow;
      break;
    case "tonalSpot":
      palette = DynamicSchemeVariant.tonalSpot;
      break;
    case "vibrant":
      palette = DynamicSchemeVariant.vibrant;
      break;
    default:
      palette = DynamicSchemeVariant.content;
  }


  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorseed,
      brightness: Brightness.dark,
      dynamicSchemeVariant: palette,
    ),
  );
}

MaterialColor changeColor(MaterialColor newColor){
  return newColor;
}