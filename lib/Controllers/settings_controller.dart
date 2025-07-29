import 'package:azyx/utils/utils.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

final SettingsController settingsController = Get.find();

class SettingsController extends GetxController {
  final Rx<bool> isGradient = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final box = Hive.box("app-data");
    isGradient.value = box.get("gradient", defaultValue: true);
  }

  void gradientToggler(bool value) {
    isGradient.value = value;
    Utils.log(value.toString());
    Hive.box('app-data').put("gradient", isGradient.value);
  }
}
