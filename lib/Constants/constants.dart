import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

final RxList<double> speedList = [
  0.25,
  0.50,
  0.75,
  1.00,
  1.25,
  1.50,
  1.75,
  2.00,
  2.25,
  2.50,
  2.75,
  3.00,
  3.25,
  3.50,
  3.75,
  4.00
].obs;
final RxList<ResizeModes> resizeModes =
    [ResizeModes.contain, ResizeModes.cover, ResizeModes.fill].obs;

BoxFit getMode(Rx<ResizeModes> mode) {
  switch (mode.value) {
    case ResizeModes.contain:
      return BoxFit.contain;
    case ResizeModes.cover:
      return BoxFit.cover;
    case ResizeModes.fill:
      return BoxFit.fill;
  }
}

IconData getModeIcon(Rx<ResizeModes> mode) {
  switch (mode.value) {
    case ResizeModes.contain:
      return Icons.fullscreen;
    case ResizeModes.cover:
      return Broken.size;
    case ResizeModes.fill:
      return Iconsax.size_bold;
  }
}
