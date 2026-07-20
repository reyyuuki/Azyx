import 'dart:developer';

import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/main.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';

final localHistoryController = Get.find<LocalHistoryController>();

class LocalHistoryController extends GetxController {
  final RxList<LocalHistoryItem> animeWatchingHistory = RxList();
  final RxList<LocalHistoryItem> mangaReadingHistory = RxList();

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  void _loadHistory() {
    final all = isar.localHistoryItems.where().findAllSync();
    animeWatchingHistory.assignAll(
      all.where((e) => e.mediaType == HistoryMediaType.anime).toList()..sort(
        (a, b) => (b.lastWatched ?? DateTime(0)).compareTo(
          a.lastWatched ?? DateTime(0),
        ),
      ),
    );
    mangaReadingHistory.assignAll(
      all.where((e) => e.mediaType == HistoryMediaType.manga).toList()..sort(
        (a, b) => (b.lastWatched ?? DateTime(0)).compareTo(
          a.lastWatched ?? DateTime(0),
        ),
      ),
    );
    log(
      'History loaded — anime: ${animeWatchingHistory.length}, manga: ${mangaReadingHistory.length}',
    );
  }

  int _generateStableId(String title, HistoryMediaType type) {
    final key = '${type.name}_$title';
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = (31 * hash + key.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  void addToWatchingHistory(LocalHistoryItem data) {
    data.mediaType = HistoryMediaType.anime;
    data.lastWatched = DateTime.now();
    if (data.mediaId == null && data.title != null) {
      data.mediaId = _generateStableId(data.title!, HistoryMediaType.anime);
    }
    isar.writeTxnSync(() {
      final existing = isar.localHistoryItems
          .where()
          .mediaIdEqualTo(data.mediaId)
          .findFirstSync();
      if (existing != null) {
        data.id = existing.id;
      }
      isar.localHistoryItems.putSync(data);
    });
    final index = animeWatchingHistory.indexWhere(
      (i) => i.mediaId == data.mediaId,
    );
    if (index != -1) {
      animeWatchingHistory.removeAt(index);
    }
    animeWatchingHistory.insert(0, data);
    log('Added to anime history: ${data.title}');
  }

  void removeFromWatchingHistory(int mediaId) {
    isar.writeTxnSync(() {
      final item = isar.localHistoryItems
          .where()
          .mediaIdEqualTo(mediaId)
          .findFirstSync();
      if (item != null) isar.localHistoryItems.deleteSync(item.id);
    });
    animeWatchingHistory.removeWhere((h) => h.mediaId == mediaId);
  }

  void addToReadingHistory(LocalHistoryItem data) {
    data.mediaType = HistoryMediaType.manga;
    data.lastWatched = DateTime.now();
    if (data.mediaId == null && data.title != null) {
      data.mediaId = _generateStableId(data.title!, HistoryMediaType.manga);
    }
    isar.writeTxnSync(() {
      final existing = isar.localHistoryItems
          .where()
          .mediaIdEqualTo(data.mediaId)
          .findFirstSync();
      if (existing != null) {
        data.id = existing.id;
      }
      isar.localHistoryItems.putSync(data);
    });
    final index = mangaReadingHistory.indexWhere(
      (i) => i.mediaId == data.mediaId,
    );
    if (index != -1) {
      mangaReadingHistory.removeAt(index);
    }
    mangaReadingHistory.insert(0, data);
    log('Added to manga history: ${data.title}');
  }

  void removeFromReadingHistory(int mediaId) {
    isar.writeTxnSync(() {
      final item = isar.localHistoryItems
          .where()
          .mediaIdEqualTo(mediaId)
          .findFirstSync();
      if (item != null) isar.localHistoryItems.deleteSync(item.id);
    });
    mangaReadingHistory.removeWhere((h) => h.mediaId == mediaId);
  }

  void clearAnimeHistory() {
    isar.writeTxnSync(() {
      final ids = animeWatchingHistory.map((e) => e.id).toList();
      isar.localHistoryItems.deleteAllSync(ids);
    });
    animeWatchingHistory.clear();
  }

  void clearMangaHistory() {
    isar.writeTxnSync(() {
      final ids = mangaReadingHistory.map((e) => e.id).toList();
      isar.localHistoryItems.deleteAllSync(ids);
    });
    mangaReadingHistory.clear();
  }
}
