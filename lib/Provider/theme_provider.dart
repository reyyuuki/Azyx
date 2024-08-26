import 'package:daizy_tv/Theme/themes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkmode;

  ThemeData get themeData => _themeData;

  Future<void> loadDynamicColors() async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    final seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35); // Fallback color

    _themeData = ThemeData(
      brightness: _themeData.brightness,
      fontFamily: 'Poppins',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: _themeData.brightness,
      ),
    );
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData.brightness == Brightness.light) {
      _themeData = ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeData.colorScheme.secondary, // Use secondary color for dark mode
          brightness: Brightness.dark,
        ),
      );
    } else {
      _themeData = ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeData.colorScheme.primary, // Use primary color for light mode
          brightness: Brightness.light,
        ),
      );
    }
    notifyListeners();
  }

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}
