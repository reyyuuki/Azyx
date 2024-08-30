import 'package:daizy_tv/Provider/themes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  String? _selectedmode;
  String? variant = "neutral";
  Color? _seedColor;

  ThemeData get themeData => _themeData;
  String? get selectedmode => _selectedmode;

  Future<void> loadDynamicColors() async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    _seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);
    _selectedmode = "dark"; 
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
          ),
        );
        break;

      case "dark":
        _themeData = darkMode.copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _seedColor!,
            brightness: Brightness.dark,
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
          ),
        );
        break;
    }
    notifyListeners(); // Notify listeners after updating the theme
  }

  Future<void> setLightMode() async {
    _selectedmode = "light";
    updateTheme(); 
  }

  Future<void> setDarkMode() async {
    _selectedmode = "dark";
    updateTheme(); 
  }

  Future<void> useSystemTheme() async {
    _selectedmode = 'system';
    updateTheme();
  }

  void updateSeedColor(Color newColor) {
    _seedColor = newColor; 
    updateTheme(); 
  }
}
