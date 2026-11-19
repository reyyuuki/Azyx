import 'dart:developer' as developer;
import 'package:azyx/Widgets/Animation/drop_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class Utils {
  static void log(String message) {
    developer.log('[AzyX]: $message');
  }
  static void showSnackBar(String title, String message) {
    Get.snackbar(title, message);
  }
}
extension NavigatorExts on Widget {
  void navigate(BuildContext context) => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (c, _, __) => this,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, __, ___, child) => child,
    ),
  );
  void getNavigate(BuildContext context) => Get.to(
    () => this,
    transition: Transition.noTransition,
  );
}
