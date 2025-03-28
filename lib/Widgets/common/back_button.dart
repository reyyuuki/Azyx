import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Broken.arrow_left_2,
          size: 35,
          color: Theme.of(context).colorScheme.primary,
          shadows: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 10.blurMultiplier(),
                spreadRadius: 2.spreadMultiplier())
          ],
        ));
  }
}
