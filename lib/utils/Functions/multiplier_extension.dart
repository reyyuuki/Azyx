import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:get/get.dart';

extension Multiplier on num {
  double glowMultiplier() {
    final controller = Get.find<UiSettingController>();
    return controller.glowMultiplier * this;
  }

  double blurMultiplier() {
    final controller = Get.find<UiSettingController>();
    return controller.blurMultiplier * this;
  }

  double spreadMultiplier() {
    final controller = Get.find<UiSettingController>();
    return controller.spreadMultiplier * this;
  }
}
