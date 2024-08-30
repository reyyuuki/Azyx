import 'package:daizy_tv/Provider/themes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  String? _selectedmode = "dark";
  String? variant = "tonalSpot";
  Color? _seedColor;
  bool? _isMaterial = true;
  var palette;

  ThemeData get themeData => _themeData;
  String? get selectedmode => _selectedmode;
  Color? get seedColor => _seedColor;
  bool? get isMaterial => _isMaterial;

  Future<void> loadDynamicColors() async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    _seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35); 
    _isMaterial = true;
    updateTheme();
    notifyListeners();
  }

 void updateTheme() {
    switch (_selectedmode) {
      case "light":
        _themeData = lightmode.copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _seedColor!,
            brightness: Brightness.light,
            dynamicSchemeVariant: palette,
          ),
        );
        break;

      case "dark":
        _themeData = darkMode.copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _seedColor!,
            brightness: Brightness.dark,
            dynamicSchemeVariant: palette,
          ),
        );
        break;

      case "system":
        Brightness systemBrightness =
            WidgetsBinding.instance.window.platformBrightness;
        _themeData = (systemBrightness == Brightness.dark ? darkMode : lightmode)
            .copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _seedColor!,
            brightness: systemBrightness,
            dynamicSchemeVariant: palette,
          ),
        );
        break;
    }
  }

  Future<void> setLightMode() async {
    _selectedmode = "light";
    updateTheme(); 
    notifyListeners();
  }

  Future<void> setDarkMode() async {
    _selectedmode = "dark";
    updateTheme(); 
    notifyListeners();
  }

  Future<void> useSystemTheme() async {
    _selectedmode = 'system';
    updateTheme();
    notifyListeners();
  }

  void updateSeedColor(Color newColor) {
    _seedColor = newColor; 
    _isMaterial = false;
    updateTheme(); 
    notifyListeners();
  }

  void setPaletteColor(variant){
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
   
   updateTheme();
notifyListeners();
  }
}
