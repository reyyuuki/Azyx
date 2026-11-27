import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final SettingsController settingsController = Get.find();

class SettingsController extends GetxController {
  final Rx<bool> isGradient = true.obs;
  final RxDouble subtitleFontSize = 18.0.obs;
  final RxString subtitleTextColor = 'White'.obs;
  final RxString subtitleBgColor = 'Black'.obs;
  final RxDouble subtitleBgOpacity = 0.55.obs;
  final RxDouble subtitleOutlineWidth = 1.5.obs;
  final RxString subtitleOutlineColor = 'Black'.obs;
  final RxDouble subtitleBottomMargin = 28.0.obs;
  final RxDouble subtitleOpacity = 1.0.obs;

  static const Map<String, Color> subtitleColorOptions = {
    'White': Colors.white,
    'Yellow': Color(0xFFFFE066),
    'Cyan': Color(0xFF4DD0E1),
    'Green': Color(0xFF81C784),
    'Pink': Color(0xFFF48FB1),
    'Black': Colors.black,
    'Transparent': Colors.transparent,
  };

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    isGradient.value = AppKeys.gradient.get<bool>(false);
    subtitleFontSize.value = SubtitleKeys.fontSize.get<double>(18.0);
    subtitleTextColor.value = SubtitleKeys.textColor.get<String>('White');
    subtitleBgColor.value = SubtitleKeys.backgroundColor.get<String>('Black');
    subtitleBgOpacity.value = SubtitleKeys.backgroundOpacity.get<double>(0.55);
    subtitleOutlineWidth.value = SubtitleKeys.outlineWidth.get<double>(1.5);
    subtitleOutlineColor.value =
        SubtitleKeys.outlineColor.get<String>('Black');
    subtitleBottomMargin.value = SubtitleKeys.bottomMargin.get<double>(28.0);
    subtitleOpacity.value = SubtitleKeys.opacity.get<double>(1.0);
  }

  Color resolveSubtitleTextColor() {
    return subtitleColorOptions[subtitleTextColor.value] ?? Colors.white;
  }

  Color resolveSubtitleBgColor() {
    final base = subtitleColorOptions[subtitleBgColor.value] ?? Colors.black;
    if (base == Colors.transparent) return Colors.transparent;
    return base.withValues(alpha: subtitleBgOpacity.value.clamp(0.0, 1.0));
  }

  Color resolveSubtitleOutlineColor() {
    return subtitleColorOptions[subtitleOutlineColor.value] ?? Colors.black;
  }

  void setSubtitleFontSize(double v) {
    subtitleFontSize.value = v;
    SubtitleKeys.fontSize.set(v);
  }

  void setSubtitleTextColor(String v) {
    subtitleTextColor.value = v;
    SubtitleKeys.textColor.set(v);
  }

  void setSubtitleBgColor(String v) {
    subtitleBgColor.value = v;
    SubtitleKeys.backgroundColor.set(v);
  }

  void setSubtitleBgOpacity(double v) {
    subtitleBgOpacity.value = v;
    SubtitleKeys.backgroundOpacity.set(v);
  }

  void setSubtitleOutlineWidth(double v) {
    subtitleOutlineWidth.value = v;
    SubtitleKeys.outlineWidth.set(v);
  }

  void setSubtitleOutlineColor(String v) {
    subtitleOutlineColor.value = v;
    SubtitleKeys.outlineColor.set(v);
  }

  void setSubtitleBottomMargin(double v) {
    subtitleBottomMargin.value = v;
    SubtitleKeys.bottomMargin.set(v);
  }

  void setSubtitleOpacity(double v) {
    subtitleOpacity.value = v;
    SubtitleKeys.opacity.set(v);
  }

  void resetSubtitleSettings() {
    setSubtitleFontSize(18.0);
    setSubtitleTextColor('White');
    setSubtitleBgColor('Black');
    setSubtitleBgOpacity(0.55);
    setSubtitleOutlineWidth(1.5);
    setSubtitleOutlineColor('Black');
    setSubtitleBottomMargin(28.0);
    setSubtitleOpacity(1.0);
  }

  void gradientToggler(bool value) {
    isGradient.value = value;
    Utils.log(value.toString());
    AppKeys.gradient.set(value);
  }
}
