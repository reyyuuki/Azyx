import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:get/get.dart';

class Extensions {
  final sourceController = Get.put(SourceController());
  Future<void> addRepo(ExtensionType extType, String url, ItemType type) async {
    if (type == ItemType.anime) {
      sourceController.setAnimeRepo(url, extType);
    } else if (type == ItemType.manga) {
      sourceController.setMangaRepo(url, extType);
    }

    await sourceController.fetchRepos();
  }
}
