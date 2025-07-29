import 'dart:developer' as developer;

import 'package:get/get.dart';

class Utils {
  static void log(String message) {
    developer.log('[AzyX]: $message');
  }

  static void showSnackBar(String title, String message) {
    Get.snackbar(title, message);
  }
}
