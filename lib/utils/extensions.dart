import 'package:anymex_extension_runtime_bridge/Models/Source.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:get/get.dart';

class Extensions {
  final sourceController = Get.put(SourceController());
  Future<void> addRepo(String url, ItemType type, String managerId) async {
    sourceController.addRepo(url, type, managerId);
    await sourceController.fetchRepos();
  }
}
