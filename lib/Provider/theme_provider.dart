import 'package:daizy_tv/Provider/themes.dart'; // Assuming this is where your lightmode and darkMode are defined
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;
  bool? isLightMode;
  bool? isDarkMode;
  String? _variant;
  Color? _seedColor;
  bool? _isMaterial;
  DynamicSchemeVariant palette = DynamicSchemeVariant.tonalSpot;

  ThemeData get themeData => _themeData;
  Color? get seedColor => _seedColor;
  bool? get isMaterial => _isMaterial;
  String? get variant => _variant;

  ThemeProvider() {
    var box = Hive.box('mybox');
    _isMaterial = box.get("isMaterialColor", defaultValue: true);
    isLightMode = box.get("isLightMode", defaultValue: false);
    isDarkMode = box.get("isDarkMode", defaultValue: true);   
    _variant = box.get("palette", defaultValue: "TonalSpot");

    if (_isMaterial!) {
      loadDynamicColors();
    } else {
       int colorValue =  box.get("SeedColor", defaultValue: Colors.purple.value);
       MaterialColor newSeedColor =
          MaterialColor(colorValue, getMaterialColorSwatch(colorValue));
      updateSeedColor(newSeedColor);
    }
    updateTheme();
  }

 

  Future<void> loadDynamicColors() async {
    var box = Hive.box("mybox");
    final corePalette = await DynamicColorPlugin.getCorePalette();
    _seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);
        _isMaterial = true;
      box.put('isMaterialColor', true);
    updateTheme();
  }

  void updateTheme() {
    final color = _seedColor ?? Colors.purple;

    if (isLightMode!) {
    _themeData = lightmode.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.light,
        dynamicSchemeVariant: palette,
      ),
    );
  } else if (isDarkMode!) {
    _themeData = darkMode.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
        dynamicSchemeVariant: palette,
      ),
    );
  } else {
    _themeData = darkMode.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
        dynamicSchemeVariant: palette,
        surface: Colors.black,
      ),
    );
  }
    notifyListeners();
  }

  Future<void> setLightMode() async {
    var box = Hive.box("mybox");
    isLightMode = true;
    isDarkMode = false;
    box.put('isLightMode', true);
    box.put('isDarkMode', false);
    updateTheme();
  }

  Future<void> setDarkMode() async {
    var box = Hive.box("mybox");
    isLightMode = false;
    isDarkMode = true;
    box.put('isLightMode', false);
    box.put('isDarkMode', true);
    updateTheme();
  }

  Future<void> oledTheme() async {
    var box = Hive.box("mybox");
    isLightMode = false;
    isDarkMode = false;
      box.put('isLightMode', false);
    box.put('isDarkMode', false);
    updateTheme();
  }

  void updateSeedColor(newColor) {
    var box = Hive.box("mybox");
    _seedColor = newColor;
    _isMaterial = false;
    box.put('SeedColor', newColor.value);
    box.put('isMaterialColor', false);
    updateTheme();
  }

  void setPaletteColor(String variant) {
    switch (variant) {
      case "Content":
        palette = DynamicSchemeVariant.content;
        break;
      case "Expressive":
        palette = DynamicSchemeVariant.expressive;
        break;
      case "Fidelity":
        palette = DynamicSchemeVariant.fidelity;
        break;
      case "FruitSalad":
        palette = DynamicSchemeVariant.fruitSalad;
        break;
      case "MonoChrome":
        palette = DynamicSchemeVariant.monochrome;
        break;
      case "Neutral":
        palette = DynamicSchemeVariant.neutral;
        break;
      case "Rainbow":
        palette = DynamicSchemeVariant.rainbow;
        break;
      case "TonalSpot":
        palette = DynamicSchemeVariant.tonalSpot;
        break;
      case "Vibrant":
        palette = DynamicSchemeVariant.vibrant;
        break;
      default:
        palette = DynamicSchemeVariant.tonalSpot; // Fallback to a default
    }
    updateTheme();
    Hive.box("mybox").put("palette", variant);
  }

  Map<int, Color> getMaterialColorSwatch(int colorValue) {
    Color color = Color(colorValue);
    return {
      50: color.withOpacity(.1),
      100: color.withOpacity(.2),
      200: color.withOpacity(.3),
      300: color.withOpacity(.4),
      400: color.withOpacity(.5),
      500: color.withOpacity(.6),
      600: color.withOpacity(.7),
      700: color.withOpacity(.8),
      800: color.withOpacity(.9),
      900: color.withOpacity(1),
    };
  }
}
