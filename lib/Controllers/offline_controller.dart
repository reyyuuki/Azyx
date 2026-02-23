import 'dart:developer';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../Models/category_class.dart';

final OfflineController offlineController = Get.find();

class OfflineController extends GetxController {
  final RxList<OfflineItem> offlineAnimeList = RxList();
  final RxList<OfflineItem> offlineMangaList = RxList();
  final RxList<Category> offlineAnimeCategories = RxList();
  final RxList<Category> offlineMangaCategories = RxList();

  @override
  void onInit() {
    super.onInit();
    loadOfflineData();
  }

  void addOfflineItem(OfflineItem data, String categoryName) {
    final index = offlineAnimeList.indexWhere(
      (i) => i.mediaData.id == data.mediaData.id,
    );
    if (index != -1) {
      offlineAnimeList[index] = data;
    } else {
      offlineAnimeList.add(data);
    }
    addToCategory(categoryName, data.mediaData.id!);
  }

  void addMangaOfflineItem(OfflineItem data, String categoryName) {
    final index = offlineMangaList.indexWhere(
      (i) => i.mediaData.id == data.mediaData.id,
    );
    if (index != -1) {
      offlineMangaList[index] = data;
    } else {
      offlineMangaList.add(data);
    }
    addToMangaCategory(categoryName, data.mediaData.id!);
  }

  void persistOfflineData() async {
    final box = Hive.box('offline-data');
    await box.put(
      'animeList',
      offlineAnimeList.map((e) => e.toJson()).toList(),
    );
    await box.put(
      'categories',
      offlineAnimeCategories.map((e) => e.toJson()).toList(),
    );
    await box.put(
      "mangaList",
      offlineMangaList.map((e) => e.toJson()).toList(),
    );
    await box.put(
      'mangaCategories',
      offlineMangaCategories.map((e) => e.toJson()).toList(),
    );
  }

  void loadOfflineData() {
    final box = Hive.box('offline-data');
    final storedAnimeList = box.get('animeList', defaultValue: []);
    final storedCategories = box.get('categories', defaultValue: []);
    final storedMangaCategories = box.get('mangaCategories', defaultValue: []);
    final storedMangaList = box.get('mangaList', defaultValue: []);

    if (storedAnimeList != null) {
      offlineAnimeList.assignAll(
        (storedAnimeList as List)
            .map((e) => OfflineItem.fromJson(e, false))
            .toList(),
      );
    }

    if (storedCategories != null) {
      offlineAnimeCategories.assignAll(
        (storedCategories as List).map((e) => Category.fromJson(e)).toList(),
      );
    }

    if (storedMangaList != null) {
      offlineMangaList.assignAll(
        (storedMangaList as List)
            .map((e) => OfflineItem.fromJson(e, true))
            .toList(),
      );
    }

    if (storedMangaCategories != null) {
      offlineMangaCategories.assignAll(
        (storedMangaCategories as List)
            .map((e) => Category.fromJson(e))
            .toList(),
      );
    }
    log(offlineMangaList.length.toString());
  }

  void removeOfflineItem(OfflineItem data, String categoryName) {
    final index = offlineAnimeList.indexWhere(
      (i) => i.mediaData.id == data.mediaData.id,
    );
    offlineAnimeList.removeAt(index);
    removeFromCategory(categoryName, data.mediaData.id!.toInt());
  }

  void removeMangaOfflineItem(OfflineItem data, String categoryName) {
    final index = offlineMangaList.indexWhere(
      (i) => i.mediaData.id == data.mediaData.id,
    );
    offlineMangaList.removeAt(index);
    removeFromMangaCategory(categoryName, data.mediaData.id!.toInt());
  }

  void createCategory(String categoryName) {
    offlineAnimeCategories.add(Category(name: categoryName, anilistIds: []));
    persistOfflineData();
  }

  void createMangaCategory(String categoryName) {
    offlineMangaCategories.add(Category(name: categoryName, anilistIds: []));
    persistOfflineData();
  }

  void deleteCategory(String categoryName) {
    final index = offlineAnimeCategories.indexWhere(
      (i) => i.name == categoryName,
    );
    offlineAnimeCategories.removeAt(index);
    persistOfflineData();
  }

  void deleteMangaCategory(String categoryName) {
    final index = offlineMangaCategories.indexWhere(
      (i) => i.name == categoryName,
    );
    offlineMangaCategories.removeAt(index);
    persistOfflineData();
  }

  void addToCategory(String categoryName, String mediaId) {
    final index = offlineAnimeCategories.indexWhere(
      (i) => i.name == categoryName,
    );
    if (index != -1) {
      offlineAnimeCategories[index].anilistIds.add(mediaId);
      log(
        "Added to category '${offlineAnimeCategories[index].name}': $mediaId",
      );
    } else {
      log("Error: Category '$categoryName' not found.");
    }
    persistOfflineData();
  }

  void addToMangaCategory(String categoryName, String mediaId) {
    final index = offlineMangaCategories.indexWhere(
      (i) => i.name == categoryName,
    );
    if (index != -1) {
      offlineMangaCategories[index].anilistIds.add(mediaId);
      log(
        "Added to category '${offlineMangaCategories[index].name}': $mediaId",
      );
    } else {
      log("Error: Category '$categoryName' not found.");
    }
    persistOfflineData();
  }

  void removeFromCategory(String categoryName, int mediaId) {
    final index = offlineAnimeCategories.indexWhere(
      (i) => i.name == categoryName,
    );
    if (index != -1) {
      offlineAnimeCategories[index].anilistIds.remove(mediaId);
      log(
        "Removed from category '${offlineAnimeCategories[index].name}': $mediaId",
      );
    } else {
      log("Error: Category '$categoryName' not found.");
    }
    persistOfflineData();
  }

  void removeFromMangaCategory(String categoryName, int mediaId) {
    final index = offlineMangaCategories.indexWhere(
      (i) => i.name == categoryName,
    );
    if (index != -1) {
      offlineMangaCategories[index].anilistIds.remove(mediaId);
      log(
        "Removed from category '${offlineMangaCategories[index].name}': $mediaId",
      );
    } else {
      log("Error: Category '$categoryName' not found.");
    }
    persistOfflineData();
  }
}
