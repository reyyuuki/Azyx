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

  static AzTones fromScheme(ColorScheme scheme) {
    return AzTones(
      accent: scheme.primary,
      onAccent: scheme.onPrimary,
      soft: scheme.primary.withValues(alpha: 0.16),
      glow: scheme.primary.withValues(alpha: 0.32),
    );
  }

  static AzTones fromHex(
    String? hex, [
    ColorScheme? fallbackScheme,
    Color? fallbackPrimary,
  ]) {
    if (fallbackScheme != null) {
      return fromScheme(fallbackScheme);
    }
    final p = fallbackPrimary ?? const Color(0xFFFFB1C1);
    return AzTones(
      accent: p,
      onAccent: Colors.white,
      soft: p.withValues(alpha: 0.16),
      glow: p.withValues(alpha: 0.32),
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
    return provider?.tones ??
        AzTones.fromScheme(Theme.of(context).colorScheme);
  }

  @override
  bool updateShouldNotify(covariant AzTonesProvider oldWidget) {
    return tones.accent != oldWidget.tones.accent ||
        tones.onAccent != oldWidget.tones.onAccent ||
        tones.soft != oldWidget.tones.soft ||
        tones.glow != oldWidget.tones.glow;
  }
}
