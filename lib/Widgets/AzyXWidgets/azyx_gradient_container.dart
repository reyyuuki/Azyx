import 'dart:io';

import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:provider/provider.dart';

class AzyXGradientContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  const AzyXGradientContainer({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Platform.isAndroid || Platform.isIOS
        ? child
        : Column(
            children: [
              10.height,
              Expanded(child: child),
            ],
          );
    final bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode!;
    return Obx(() {
      if (settingsController.isGradient.value) {
        return Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Theme.of(context).colorScheme.surface,
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Theme.of(context).colorScheme.surface.withAlpha(20),
                      Theme.of(context).colorScheme.primary.withAlpha(90),
                    ]
                  : [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget,
        );
      } else {
        return Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: widget,
        );
      }
    });
  }
}
