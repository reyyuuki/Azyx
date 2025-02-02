
import 'package:azyx/HiveClass/theme_data.dart';
import 'package:azyx/Providers/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;
  bool? _isLightMode;
  bool? _isDarkMode;
  String? _variant;
  Color? _seedColor;
  bool? _isMaterial;
  String? _colorName;
  ThemeClass theme = ThemeClass();

  DynamicSchemeVariant palette = DynamicSchemeVariant.tonalSpot;

  ThemeData get themeData => _themeData;
  Color? get seedColor => _seedColor;
  bool? get isMaterial => _isMaterial;
  String? get variant => _variant;
  String? get colorName => _colorName;
  bool? get isDarkMode => _isDarkMode;
  bool? get isLightMode => _isLightMode;

  ThemeProvider() {
    var box = Hive.box('theme-data');
    theme = box.get('themeClass',defaultValue: ThemeClass());
    _isMaterial = theme.isMaterial;
    _isLightMode = theme.isLightMode;
    _isDarkMode = theme.isDarkMode;
    _variant = theme.varient;
    _colorName = theme.seedColor;
    if (_isMaterial!) {
      loadDynamicColors();
    } else {
      _seedColor = getSeedColor(_colorName ?? "Red");
    }
    updateTheme();
  }

  void updateBox() {
    theme.isDarkMode = _isDarkMode;
    theme.seedColor = _colorName;
    theme.varient = _variant;
    theme.isLightMode = _isLightMode;
    theme.isMaterial = _isMaterial;
    Hive.box('theme-data').put("themeClass", theme);
  }

  Future<void> loadDynamicColors() async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    _seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);
    _isMaterial = true;
    updateTheme();
  }

  void updateTheme() {
    final color = _seedColor ?? Colors.purple;
    if (_isLightMode!) {
      _themeData = lightmode.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.light,
          dynamicSchemeVariant: palette,
        ),
      );
    } else if (_isDarkMode!) {
      _themeData = darkMode.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
          dynamicSchemeVariant: palette,
        ),
      );
    } else {
      _themeData = darkMode.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
          dynamicSchemeVariant: palette,
          surface: Colors.black,
        ),
      );
    }
    updateBox();
    notifyListeners();
  }

  void setLightMode() {
    _isLightMode = true;
    _isDarkMode = false;
    updateTheme();
  }

  void setDarkMode() {
    _isLightMode = false;
    _isDarkMode = true;
    updateTheme();
  }

  void oledTheme() {
    _isLightMode = false;
    _isDarkMode = false;
    updateTheme();
  }

  void updateSeedColor(String newColor) {
    _colorName = newColor;
    _seedColor = getSeedColor(newColor);
    _isMaterial = false;
    updateTheme();
  }

  void setPaletteColor(String newVariant) {
    switch (newVariant) {
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
        palette = DynamicSchemeVariant.tonalSpot;
    }
    _variant = newVariant;
    updateTheme();
  }

  Color getSeedColor(String color) {
    Color newColor;
    switch (color) {
      case "Blue":
        newColor = Colors.blue;
        break;
      case "Red":
        newColor = Colors.red;
        break;
      case "Orange":
        newColor = Colors.orange;
        break;
      case "Pink":
        newColor = Colors.pink;
        break;
      case "Grey":
        newColor = Colors.grey;
        break;
      case "Brown":
        newColor = Colors.brown;
        break;
      case "Indigo":
        newColor = Colors.indigo;
        break;
      case "Green":
        newColor = Colors.green;
        break;
      case "Yellow":
        newColor = Colors.yellow;
        break;
      case "Purple":
        newColor = Colors.purple;
        break;
      case "Cyan":
        newColor = Colors.cyan;
        break;
      case "Teal":
        newColor = Colors.teal;
        break;
      case "Amber":
        newColor = Colors.amber;
        break;
      case "LightBlue":
        newColor = Colors.lightBlue;
        break;
      case "DeepOrange":
        newColor = Colors.deepOrange;
        break;
      case "Lime":
        newColor = Colors.lime;
        break;
      case "PinkAccent":
        newColor = Colors.pinkAccent;
        break;
      default:
        newColor = Colors.purple;
        break;
    }
    return newColor;
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
