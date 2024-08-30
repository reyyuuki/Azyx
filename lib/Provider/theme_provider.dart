import 'package:daizy_tv/Provider/themes.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  String? _selectedmode;
  String? variant = "neutral";

  ThemeData get themeData => _themeData;
  String? get selectedmode => _selectedmode;

  Future<void> loadDynamicColors() async {
    _themeData = await buildDarkMode(variant);
    _selectedmode = 'dark';
    notifyListeners();
  }

  Future<void> setLightMode(variant) async {
    _themeData = await buildLightMode(variant);
    _selectedmode = 'light';
    notifyListeners();

  }

  Future<void> setDarkMode(variant) async {
    _themeData = await buildDarkMode(variant);
    _selectedmode = 'dark';
    notifyListeners();
  }

  Future<void> useSystemTheme() async {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    _selectedmode = 'system';
    _themeData = brightness == Brightness.dark
        ? await buildDarkMode(variant)
        : await buildLightMode(variant);
    notifyListeners();
  }

  // void updateSeedColor(MaterialColor newColor) {
  //   changeColor(newColor);
  //   if (isLight) {
  //   setLightMode(variant);
  // } else if (isDark) {
  //   setDarkMode(variant);
  // } else {
  //   useSystemTheme();
  // }
  //   notifyListeners();
  // }
  void updateSeedColor(variant, newcolor)  {
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

       ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: newcolor,
          brightness: Brightness.dark,
          dynamicSchemeVariant: palette,
        ),
      );
    
    
    notifyListeners();
  }
}
