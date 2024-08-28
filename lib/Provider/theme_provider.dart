import 'package:daizy_tv/Theme/themes.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  bool isDark = false;
  bool isLight = false;
  bool isSystem = false;

  
  ThemeData get themeData => _themeData;

  Future<void> loadDynamicColors() async {
    _themeData = await buildLightMode();
    isDark = false;
    isLight = true;
    isSystem = false; 
    notifyListeners();
  }

  Future<void> setLightMode() async {
    _themeData = await buildLightMode();
    notifyListeners();
    isDark = false;
    isLight = true;
    isSystem = false;
  }

  Future<void> setDarkMode() async {
    _themeData = await buildDarkMode();
    isDark = true;
    isLight = false;
    isSystem = false;
    notifyListeners();
  }

  Future<void> useSystemTheme() async {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    isDark = false;
   isLight = false;
   isSystem = true;
     _themeData = brightness == Brightness.dark ? await buildDarkMode() : await buildLightMode();
    notifyListeners();
  }
  
}
