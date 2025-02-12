import 'dart:developer';

import 'package:azyx/Classes/category_class.dart';
import 'package:azyx/Classes/offline_item.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

final OfflineController offlineController = Get.find();

class OfflineController extends GetxController {
  final RxList<OfflineItem> allOfflineAnime = RxList();
  final RxList<OfflineItem> allOfflineManga = RxList();
  final RxList<CategoryClass> categories = RxList();

  @override
  void onInit() {
    super.onInit();
    loadFromHive();
  }

  void addItem(OfflineItem data, String name) {
    final index =
        allOfflineAnime.indexWhere((i) => i.mediaData.id == data.mediaData.id);
    if (index != -1) {
      allOfflineAnime[index] = data;
    } else {
      allOfflineAnime.add(data);
    }
    addTocategory(name, data.mediaData.id!);
  }

  void saveToHive() async {
    final box = Hive.box('offline-data');
    await box.put('animeList', allOfflineAnime.map((e) => e.toJson()).toList());
    await box.put('categories', categories.map((e) => e.toJson()).toList());
  }

  void loadFromHive() {
    final box = Hive.box('offline-data');
    final storedAnimeList = box.get('animeList', defaultValue: []);
    final storedCategories = box.get('categories', defaultValue: []);

    if (storedAnimeList != null) {
      allOfflineAnime.assignAll(
        (storedAnimeList as List).map((e) => OfflineItem.fromJson(e)).toList(),
      );
    }

    if (storedCategories != null) {
      categories.assignAll((storedCategories as List)
          .map((e) => CategoryClass.fromJson(e))
          .toList());
    }
  }

  void removeItem(OfflineItem data, String name) {
    final index =
        allOfflineAnime.indexWhere((i) => i.mediaData.id == data.mediaData.id);
    allOfflineAnime.removeAt(index);
    removeFromCategory(name, data.mediaData.id!);
  }

  void addNewCategory(String name) {
    categories.add(CategoryClass(name: name, anilistIds: []));
    saveToHive();
  }

  void removeCategory(String name) {
    final index = categories.indexWhere((i) => i.name == name);
    categories.removeAt(index);
    saveToHive();
  }

  void addTocategory(
    String name,
    int id,
  ) {
    final index = categories.indexWhere((i) => i.name == name);
    if (index != -1) {
      categories[index].anilistIds.add(id);
      log("category; ${categories[index].anilistIds.first}");
    } else {
      log("error when adding to library");
    }
    saveToHive();
  }

  void removeFromCategory(
    String name,
    int id,
  ) {
    final index = categories.indexWhere((i) => i.name == name);
    categories[index].anilistIds.remove(id);
    log("Removed: $id from ${categories[index].name}");
    saveToHive();
  }
}
