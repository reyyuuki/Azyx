import 'package:azyx/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final double? height;
  const GradientBackground({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode!;
    return Container(
      height: height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Theme.of(context).colorScheme.surface.withAlpha(20),
                      Theme.of(context).colorScheme.primary.withAlpha(90),
                    ]
                  : [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: child,
    );
  }
}
