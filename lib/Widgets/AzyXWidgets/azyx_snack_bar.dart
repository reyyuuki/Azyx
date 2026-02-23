import 'dart:io';

import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void azyxSnackBar(
  String title, {
  double? width,
  Icon? icon,
  Duration? duration,
}) {
  Get.snackbar(
    '',
    '',
    maxWidth: width ?? (Platform.isAndroid || Platform.isIOS ? 200 : 400),
    duration: duration ?? const Duration(milliseconds: 2000),
    animationDuration: const Duration(milliseconds: 2000),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    margin: const EdgeInsets.only(bottom: 20),
    messageText: Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: "Poppins-Bold"),
    ),
    titleText: icon ??
        AzyXContainer(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/icon.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
    snackPosition: SnackPosition.BOTTOM,
  );
}
