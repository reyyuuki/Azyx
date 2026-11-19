import 'package:flutter/material.dart';

class AzTones {
  final Color accent;
  final Color onAccent;
  final Color soft;
  final Color glow;

  const AzTones({
    required this.accent,
    required this.onAccent,
    required this.soft,
    required this.glow,
  });

  static AzTones fromHex(
    String? hex, [
    ColorScheme? fallbackScheme,
    Color? fallbackPrimary,
  ]) {
    double h = 346, s = 0.9;
    bool valid = false;
    if (hex != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
      final r = int.parse(hex.substring(1, 3), radix: 16) / 255.0;
      final g = int.parse(hex.substring(3, 5), radix: 16) / 255.0;
      final b = int.parse(hex.substring(5, 7), radix: 16) / 255.0;
      final mx = [r, g, b].reduce((a, c) => a > c ? a : c);
      final mn = [r, g, b].reduce((a, c) => a < c ? a : c);
      final d = mx - mn;
      if (d > 0.08) {
        if (mx == r) {
          h = ((g - b) / d + 6) % 6 * 60;
        } else if (mx == g) {
          h = ((b - r) / d + 2) * 60;
        } else {
          h = ((r - g) / d + 4) * 60;
        }
        s = (d / (1 - (mx + mn - 1).abs())).clamp(0.5, 0.85);
        valid = true;
      }
    }
    if (!valid && (fallbackScheme != null || fallbackPrimary != null)) {
      final p = fallbackScheme?.primary ?? fallbackPrimary!;
      final onP = fallbackScheme?.onPrimary ?? Colors.white;
      return AzTones(
        accent: p,
        onAccent: onP,
        soft: p.withValues(alpha: 0.16),
        glow: p.withValues(alpha: 0.32),
      );
    }
    Color c(double l, [double a = 1.0]) =>
        HSLColor.fromAHSL(a, h, s, l / 100.0).toColor();
    return AzTones(
      accent: c(78),
      onAccent: HSLColor.fromAHSL(1.0, h, 0.45, 0.13).toColor(),
      soft: c(78, 0.16),
      glow: c(60, 0.34),
    );
  }
}

class AzTonesProvider extends InheritedWidget {
  final AzTones tones;

  const AzTonesProvider({
    super.key,
    required this.tones,
    required super.child,
  });

  static AzTones of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AzTonesProvider>();
    if (provider != null) return provider.tones;
    return AzTones.fromHex(null, Theme.of(context).colorScheme);
  }

  @override
  bool updateShouldNotify(AzTonesProvider oldWidget) {
    return tones.accent != oldWidget.tones.accent ||
        tones.onAccent != oldWidget.tones.onAccent ||
        tones.soft != oldWidget.tones.soft ||
        tones.glow != oldWidget.tones.glow;
  }
}
