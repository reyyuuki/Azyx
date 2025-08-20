import 'dart:developer' as developer;

import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
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
  void navigate(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (c) => this));
  void getNavigate(BuildContext context) => Get.to(() => this);
}
