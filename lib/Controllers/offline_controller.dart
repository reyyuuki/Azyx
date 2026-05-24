import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/main.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';

final OfflineController offlineController = Get.find();

class OfflineController extends GetxController {
  // @override
  // void onInit() {
  //   super.onInit();
  //   loadOfflineData();
  // }

  Stream<List<Category>> getAnimeCategories() {
    return isar.categorys
        .filter()
        .isMangaEqualTo(false)
        .watch(fireImmediately: true);
  }

  Stream<List<OfflineItem>> getOfflineAnimeStream() {
    return isar.offlineItems
        .filter()
        .mediaTypeEqualTo(1)
        .watch(fireImmediately: true);
  }

  Stream<List<OfflineItem>> getOfflineMangaStream() {
    return isar.offlineItems
        .filter()
        .mediaTypeEqualTo(0)
        .watch(fireImmediately: true);
  }

  Stream<List<Category>> getMangaCategoriesStream() {
    return isar.categorys
        .filter()
        .isMangaEqualTo(true)
        .watch(fireImmediately: true);
  }

  Future<List<OfflineItem>> getOfflineAnimeList() async {
    return await isar.offlineItems.filter().mediaTypeEqualTo(1).findAll();
  }

  Future<List<OfflineItem>> getOfflineMangaList() async {
    return await isar.offlineItems.filter().mediaTypeEqualTo(0).findAll();
  }

  Future<List<Category>> getAnimeCategoriesList() async {
    return await isar.categorys.filter().isMangaEqualTo(false).findAll();
  }

  Future<List<Category>> getMangaCategoriesList() async {
    return await isar.categorys.filter().isMangaEqualTo(true).findAll();
  }

  void addOfflineItem(OfflineItem data, Category category) async {
    final offlineAnimeList = await getOfflineAnimeList();
    final index = offlineAnimeList.indexWhere(
      (i) => i.mediaData?.id == data.mediaData?.id,
    );
    if (index != -1) {
      data.id = offlineAnimeList[index].id;
      offlineAnimeList[index] = data;
    } else {
      offlineAnimeList.add(data);
    }

    await isar.writeTxn(() async {
      await isar.offlineItems.put(data);
    });
    addToCategory(category, data.mediaData!.id!.toString());
  }

  void addMangaOfflineItem(OfflineItem data, Category category) async {
    final offlineMangaList = await getOfflineMangaList();
    final index = offlineMangaList.indexWhere(
      (i) => i.mediaData?.id == data.mediaData?.id,
    );
    if (index != -1) {
      data.id = offlineMangaList[index].id;
      offlineMangaList[index] = data;
    } else {
      offlineMangaList.add(data);
    }

    await isar.writeTxn(() async {
      await isar.offlineItems.put(data);
    });
    addToMangaCategory(category, data.mediaData!.id!.toString());
  }

  // void persistOfflineData() async {
  //   final box = Hive.box('offline-data');
  //   await box.put(
  //     'animeList',
  //     offlineAnimeList.map((e) => e.toJson()).toList(),
  //   );
  //   await box.put(
  //     'categories',
  //     offlineAnimeCategories.map((e) => e.toJson()).toList(),
  //   );
  //   await box.put(
  //     "mangaList",
  //     offlineMangaList.map((e) => e.toJson()).toList(),
  //   );
  //   await box.put(
  //     'mangaCategories',
  //     offlineMangaCategories.map((e) => e.toJson()).toList(),
  //   );
  // }

  // void loadOfflineData() {
  //   final box = Hive.box('offline-data');
  //   final storedAnimeList = box.get('animeList', defaultValue: []);
  //   final storedCategories = box.get('categories', defaultValue: []);
  //   final storedMangaCategories = box.get('mangaCategories', defaultValue: []);
  //   final storedMangaList = box.get('mangaList', defaultValue: []);

  //   if (storedAnimeList != null) {
  //     offlineAnimeList.assignAll(
  //       (storedAnimeList as List).map((e) => OfflineItem.fromJson(e)).toList(),
  //     );
  //   }

  //   if (storedCategories != null) {
  //     offlineAnimeCategories.assignAll(
  //       (storedCategories as List).map((e) => Category.fromJson(e)).toList(),
  //     );
  //   }

  //   if (storedMangaList != null) {
  //     offlineMangaList.assignAll(
  //       (storedMangaList as List).map((e) => OfflineItem.fromJson(e)).toList(),
  //     );
  //   }

  //   if (storedMangaCategories != null) {
  //     offlineMangaCategories.assignAll(
  //       (storedMangaCategories as List)
  //           .map((e) => Category.fromJson(e))
  //           .toList(),
  //     );
  //   }
  //   log(offlineMangaList.length.toString());
  // }

  void removeOfflineItem(OfflineItem data, Category categoryName) async {
    await isar.writeTxn(() async => await isar.offlineItems.delete(data.id));
    removeFromCategory(categoryName, data.mediaData!.id!.toString());
  }

  void removeMangaOfflineItem(OfflineItem data, Category categoryName) async {
    await isar.writeTxn(() async => await isar.offlineItems.delete(data.id));
    removeFromCategory(categoryName, data.mediaData!.id!.toString());
  }

  void createCategory(String categoryName) async {
    await isar.writeTxn(
      () async => await isar.categorys.put(
        Category(name: categoryName, anilistIds: [], isManga: false),
      ),
    );
  }

  void createMangaCategory(String categoryName) async {
    await isar.writeTxn(
      () async => await isar.categorys.put(
        Category(name: categoryName, anilistIds: [], isManga: true),
      ),
    );
  }

  void deleteCategory(Category cat) async {
    final idsToCheck = List<String>.from(cat.anilistIds ?? []);

    await isar.writeTxn(() async {
      await isar.categorys
          .filter()
          .idEqualTo(cat.id)
          .isMangaEqualTo(cat.isManga)
          .deleteFirst();
    });

    // Clean up items that are now orphaned because their last category was deleted
    for (var mediaId in idsToCheck) {
      final allCats = await isar.categorys.filter().isMangaEqualTo(cat.isManga).findAll();
      bool isOrphaned = true;
      for (var c in allCats) {
        if (c.anilistIds?.contains(mediaId) ?? false) {
          isOrphaned = false;
          break;
        }
      }

      if (isOrphaned) {
        final mediaType = cat.isManga ? 0 : 1;
        final allItems = await isar.offlineItems.filter().mediaTypeEqualTo(mediaType).findAll();
        for (var item in allItems) {
          if (item.mediaData?.id?.toString() == mediaId) {
            await isar.writeTxn(() async => await isar.offlineItems.delete(item.id));
            log("Deleted orphaned offline item after category delete: $mediaId");
          }
        }
      }
    }
  }

  void addToCategory(Category category, String mediaId) async {
    final cat = await isar.categorys
        .filter()
        .idEqualTo(category.id)
        .and()
        .isMangaEqualTo(category.isManga)
        .findFirst();
    if (cat != null) {
      final ids = List<String>.from(cat.anilistIds ?? []);
      if (!ids.contains(mediaId)) {
        ids.add(mediaId);
        cat.anilistIds = ids;
        await isar.writeTxn(() async => await isar.categorys.put(cat));
        log("Added to category '${cat.name}': $mediaId");
      }
    } else {
      log("Error: Category '${category.name}' not found.");
    }
  }

  void addToMangaCategory(Category category, String mediaId) async {
    final cat = await isar.categorys
        .filter()
        .idEqualTo(category.id)
        .and()
        .isMangaEqualTo(true)
        .findFirst();
    if (cat != null) {
      final ids = List<String>.from(cat.anilistIds ?? []);
      if (!ids.contains(mediaId)) {
        ids.add(mediaId);
        cat.anilistIds = ids;
        await isar.writeTxn(() async => await isar.categorys.put(cat));
        log("Added to category '${cat.name}': $mediaId");
      }
    } else {
      log("Error: Category '${category.name}' not found.");
    }
  }

  void removeFromCategory(Category category, String mediaId) async {
    final cat = await isar.categorys
        .filter()
        .idEqualTo(category.id)
        .and()
        .isMangaEqualTo(category.isManga)
        .findFirst();
    if (cat != null) {
      final ids = List<String>.from(cat.anilistIds ?? []);
      if (ids.remove(mediaId)) {
        cat.anilistIds = ids;
        await isar.writeTxn(() async => await isar.categorys.put(cat));
        log("Removed from category '${cat.name}': $mediaId");
        
        // Check if the item is now orphaned (not in any category of this type)
        final allCats = await isar.categorys.filter().isMangaEqualTo(category.isManga).findAll();
        bool isOrphaned = true;
        for (var c in allCats) {
          if (c.anilistIds?.contains(mediaId) ?? false) {
            isOrphaned = false;
            break;
          }
        }
        
        if (isOrphaned) {
          final mediaType = category.isManga ? 0 : 1;
          final allItems = await isar.offlineItems.filter().mediaTypeEqualTo(mediaType).findAll();
          for (var item in allItems) {
            if (item.mediaData?.id?.toString() == mediaId) {
              await isar.writeTxn(() async => await isar.offlineItems.delete(item.id));
              log("Deleted orphaned offline item completely from library: $mediaId");
            }
          }
        }
      }
    } else {
      log("Error: Category '${category.name}' not found.");
    }
  }

  void renameCategory(Category cat, String newName) async {
    cat.name = newName;
    await isar.writeTxn(() async => await isar.categorys.put(cat));
  }

  void saveCategoryOrder(List<int> orderedIds, bool isManga) async {
    final key = isManga ? 'manga_category_order' : 'anime_category_order';
    final value = jsonEncode(orderedIds);
    await isar.writeTxn(() async {
      await isar.keyValues.put(KeyValue()..key = key..value = value);
    });
  }

  List<int> getCategoryOrder(bool isManga) {
    final key = isManga ? 'manga_category_order' : 'anime_category_order';
    final kv = isar.keyValues.filter().keyEqualTo(key).findFirstSync();
    if (kv != null && kv.value != null) {
      try {
        final List<dynamic> decoded = jsonDecode(kv.value!);
        return decoded.map((e) => e as int).toList();
      } catch (e) {
        log('Error decoding category order: $e');
      }
    }
    return <int>[];
  }

  void reorderItemsInCategory(Category category, int oldIndex, int newIndex) async {
    final ids = List<String>.from(category.anilistIds ?? []);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);
    category.anilistIds = ids;
    await isar.writeTxn(() async => await isar.categorys.put(category));
  }
}
