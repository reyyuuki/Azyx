import 'dart:io';
import 'package:flutter/material.dart';

class PlatformWidget extends StatelessWidget {
  final Widget androidWidget;
  final Widget windowsWidget;

  const PlatformWidget({
    super.key,
    required this.androidWidget,
    required this.windowsWidget,
  });

  @override
  Widget build(BuildContext context) {
    
    if (Platform.isAndroid) {
      return androidWidget; 
    } else if (Platform.isWindows || Platform.isLinux) {
      return windowsWidget; 
    } else {
      return androidWidget;
    }
  }
}
