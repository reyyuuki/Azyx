import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Providers/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;
  bool? _isLightMode;
  bool? _isDarkMode;
  String? _variant;
  Color? _seedColor;
  bool? _isMaterial;
  String? _colorName;
  String _customHexColor = "#6C5CE7";
  String _darkSurfaceStyle = "oled";
  DynamicSchemeVariant palette = DynamicSchemeVariant.tonalSpot;

  ThemeData get themeData => _themeData;
  Color? get seedColor => _seedColor;
  bool? get isMaterial => _isMaterial;
  String? get variant => _variant;
  String? get colorName => _colorName;
  bool? get isDarkMode => _isDarkMode;
  bool? get isLightMode => _isLightMode;
  String get customHexColor => _customHexColor;
  String get darkSurfaceStyle => _darkSurfaceStyle;

  static const Map<String, Color> presetThemes = {
    "Catppuccin Mocha": Color(0xFFCBA6F7),
    "Nordic Ice": Color(0xFF88C0D0),
    "Cyberpunk Neon": Color(0xFFFF007F),
    "Sakura Rose": Color(0xFFF38BA8),
    "Emerald Forest": Color(0xFFA6E3A1),
    "Midnight Espresso": Color(0xFFFAB387),
    "Cyan Vivid": Color(0xFF00E5FF),
  };

  ThemeProvider() {
    reloadSettings();
  }

  void reloadSettings() {
    _isMaterial = ThemeKeys.isMaterial.get<bool>(true);
    _isLightMode = ThemeKeys.isLightMode.get<bool>(false);
    _isDarkMode = ThemeKeys.isDarkMode.get<bool>(true);
    _variant = ThemeKeys.varient.get<String>("TonalSpot");
    _colorName = ThemeKeys.seedColor.get<String>("Purple");
    _customHexColor = ThemeKeys.customHexColor.get<String>("#6C5CE7");
    _darkSurfaceStyle = ThemeKeys.darkSurfaceStyle.get<String>("oled");
    setPaletteColor(_variant!);

    if (_isMaterial!) {
      loadDynamicColors();
    } else {
      if (_colorName != null && _colorName!.startsWith("#")) {
        _seedColor = colorFromHex(_colorName!);
      } else if (presetThemes.containsKey(_colorName)) {
        _seedColor = presetThemes[_colorName];
      } else {
        _seedColor = getSeedColor(_colorName ?? "Purple");
      }
    }
    updateTheme();
  }

  void updateBox() {
    ThemeKeys.isDarkMode.set(_isDarkMode);
    ThemeKeys.seedColor.set(_colorName);
    ThemeKeys.varient.set(_variant);
    ThemeKeys.isLightMode.set(_isLightMode);
    ThemeKeys.isMaterial.set(_isMaterial);
    ThemeKeys.customHexColor.set(_customHexColor);
    ThemeKeys.darkSurfaceStyle.set(_darkSurfaceStyle);
  }

  Future<void> loadDynamicColors() async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    _seedColor = corePalette != null
        ? Color(corePalette.primary.get(40))
        : const Color(0xFF94FB35);
    _isMaterial = true;
    updateTheme();
  }

  Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.purple;
    }
  }

  void setCustomHexColor(String hexCode) {
    _customHexColor = hexCode;
    _colorName = hexCode;
    _seedColor = colorFromHex(hexCode);
    _isMaterial = false;
    updateTheme();
  }

  void setPresetTheme(String presetName) {
    if (presetThemes.containsKey(presetName)) {
      _colorName = presetName;
      _seedColor = presetThemes[presetName];
      _isMaterial = false;
      updateTheme();
    }
  }

  void setDarkSurfaceStyle(String style) {
    _darkSurfaceStyle = style;
    updateTheme();
  }

  Color get surfaceColorForDarkStyle {
    switch (_darkSurfaceStyle) {
      case "slate":
        return const Color(0xFF121212);
      case "deepNavy":
        return const Color(0xFF0D1117);
      case "oled":
      default:
        return Colors.black;
    }
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
      final darkSurface = surfaceColorForDarkStyle;
      _themeData = darkMode.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
          dynamicSchemeVariant: palette,
          surface: darkSurface,
        ),
        scaffoldBackgroundColor: darkSurface,
      );
    } else {
      _themeData = darkMode.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
          dynamicSchemeVariant: palette,
          surface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
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
