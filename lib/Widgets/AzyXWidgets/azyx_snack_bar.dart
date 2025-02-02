import 'dart:io';

import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void azyxSnackBar(String title, String message) {
  Get.snackbar(title, message,
      maxWidth: Platform.isAndroid || Platform.isIOS ? 200 : 400,
      duration: const Duration(milliseconds: 1500),
      animationDuration: const Duration(milliseconds: 1500),
      padding: const EdgeInsets.all(12),
      icon: AzyXContainer(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            'assets/images/icon.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
      snackPosition: SnackPosition.BOTTOM);
}
