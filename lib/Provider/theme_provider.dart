import 'package:daizy_tv/Theme/themes.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  bool isDark = false;
  bool isLight = false;
  bool isSystem = false;
  String? variant = "neutral";

  
  ThemeData get themeData => _themeData;

  Future<void> loadDynamicColors() async {
    _themeData = await buildDarkMode(variant);
    isDark = true;
    isLight = false;
    isSystem = false; 
    notifyListeners();
  }

  Future<void> setLightMode(variant) async {
    _themeData = await buildLightMode(variant);
    notifyListeners();
    isDark = false;
    isLight = true;
    isSystem = false;
  }

  Future<void> setDarkMode(variant) async {
    _themeData = await buildDarkMode(variant);
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
     _themeData = brightness == Brightness.dark ? await buildDarkMode(variant) : await buildLightMode(variant);
    notifyListeners();
  }
  void updateSeedColor(MaterialColor newColor) {
    changeColor(newColor);
    if (isLight) {
    setLightMode(variant);
  } else if (isDark) {
    setDarkMode(variant);
  } else {
    useSystemTheme();
  }
    notifyListeners();
  }
}
