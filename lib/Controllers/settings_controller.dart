import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/utils/utils.dart';
import 'package:get/get.dart';

final SettingsController settingsController = Get.find();

class SettingsController extends GetxController {
  final Rx<bool> isGradient = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    isGradient.value = AppKeys.gradient.get<bool>(true);
  }

  void gradientToggler(bool value) {
    isGradient.value = value;
    Utils.log(value.toString());
    AppKeys.gradient.set(value);
  }
}
