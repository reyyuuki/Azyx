import 'dart:io';

import 'package:flutter/material.dart';

void showSnackBar(String message, BuildContext context) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    width: Platform.isAndroid || Platform.isIOS ? MediaQuery.of(context).size.width : 500,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    duration: const Duration(seconds: 2),
    content: Text(
      message,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.inverseSurface,
      ),
      textAlign: TextAlign.center, // Center the text
    ),
  );

  // Show the SnackBar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

