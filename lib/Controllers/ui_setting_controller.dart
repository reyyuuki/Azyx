import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:get/get.dart';

final UiSettingController uiSettingController = Get.find();

class UiSettingController extends GetxController {
  final _glowMultiplier = 0.6.obs;
  final _blurMultiplier = 1.0.obs;
  final _radiusMultiplier = 1.0.obs;
  final _spreadMultiplier = 1.0.obs;
  @override
  void onInit() {
    super.onInit();
    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    _glowMultiplier.value = UiKeys.glowMultiplier.get<double>(0.6);
    _blurMultiplier.value = UiKeys.blurMultiplier.get<double>(1.0);
    _radiusMultiplier.value = UiKeys.radiusMultiplier.get<double>(1.0);
    _spreadMultiplier.value = UiKeys.spreadMultiplier.get<double>(1.0);
  }

  double get glowMultiplier => _glowMultiplier.value;
  set glowMultiplier(double value) {
    _glowMultiplier.value = value;
    UiKeys.glowMultiplier.set(value);
  }

  double get radiusMultiplier => _radiusMultiplier.value;
  set radiusMultiplier(double value) {
    _radiusMultiplier.value = value;
    UiKeys.radiusMultiplier.set(value);
  }

  double get blurMultiplier => _blurMultiplier.value;
  set blurMultiplier(double value) {
    _blurMultiplier.value = value;
    UiKeys.blurMultiplier.set(value);
  }

  double get spreadMultiplier => _spreadMultiplier.value;
  set spreadMultiplier(double value) {
    _spreadMultiplier.value = value;
    UiKeys.spreadMultiplier.set(value);
  }
}
