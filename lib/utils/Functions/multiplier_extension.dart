import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:flutter/material.dart';

extension Multiplier on num {
  double glowMultiplier() {
    return uiSettingController.glowMultiplier * this;
  }

  double blurMultiplier() {
    return uiSettingController.blurMultiplier * this;
  }

  double spreadMultiplier() {
    return uiSettingController.spreadMultiplier * this;
  }
}

extension SizeExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
  SizedBox get width => SizedBox(width: toDouble());
}
