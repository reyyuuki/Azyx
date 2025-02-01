import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SourcesController extends GetxController {
  final Rx<String> animeRepo = ''.obs;
  final Rx<String> mangaRepo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('app-data');
    animeRepo.value = box.get("animeRepo", defaultValue: '');
    mangaRepo.value = box.get("mangaRepo", defaultValue: '');
  }

  void updateAnimeRepo(String link) {
    animeRepo.value = link;
    final box = Hive.box('app-data');
    box.put("animeRepo", link);
  }

  void updateMangaRepo(String link) {
    mangaRepo.value = link;
    final box = Hive.box('app-data');
    box.put("mangaRepo", link);
  }
}
