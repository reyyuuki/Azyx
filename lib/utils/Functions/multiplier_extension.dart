import 'package:azyx/Controllers/ui_setting_controller.dart';

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
