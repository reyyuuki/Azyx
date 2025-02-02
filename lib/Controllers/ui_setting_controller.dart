import 'package:azyx/HiveClass/ui_setting_class.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UiSettingController extends GetxController {
  Rx<UiSettingClass> uiSettings = UiSettingClass().obs;
  @override
  void onInit() {
    super.onInit();
    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    final box = Hive.box('ui-settings');
    uiSettings.value = box.get("settings", defaultValue: UiSettingClass());
  }

  double get glowMultiplier => uiSettings.value.glowMultiplier!;
  set glowMultiplier(double value) {
    uiSettings.update((settings) {
      settings?.glowMultiplier = value;
    });
    updateBox();
  }

  double get radiusMultiplier => uiSettings.value.radiusMultiplier!;
  set radiusMultiplier(double value) {
    uiSettings.update((settings) {
      settings?.radiusMultiplier = value;
    });
    updateBox();
  }

  double get blurMultiplier => uiSettings.value.blurMultiplier!;
  set blurMultiplier(double value) {
    uiSettings.update((settings) {
      settings?.blurMultiplier = value;
    });
    updateBox();
  }

  double get spreadMultiplier => uiSettings.value.spreadMultiplier!;
  set spreadMultiplier(double value) {
    uiSettings.update((settings) {
      settings?.spreadMultiplier = value;
    });
    updateBox();
  }

  void updateBox() {
    final box = Hive.box('ui-settings');
    box.put("settings", uiSettings.value);
  }
}
