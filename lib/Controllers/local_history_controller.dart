import 'dart:developer';

import 'package:azyx/Models/local_history.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

final localHistoryController = Get.find<LocalHistoryController>();

class LocalHistoryController extends GetxController {
  final RxList<LocalHistory> animeWatchingHistory = RxList();
  final RxList<LocalHistory> mangaReadingHistory = RxList();

  @override
  void onInit() {
    super.onInit();
    loadfromHive();
  }

  void addToWatchingHistory(LocalHistory data) {
    final index =
        animeWatchingHistory.indexWhere((i) => i.mediaId == data.mediaId);
    if (index != -1) {
      animeWatchingHistory[index] = data;
    } else {
      animeWatchingHistory.add(data);
    }
    persistOfflineData();
    log("Succesfully added: ${animeWatchingHistory.length}");
    log("Succesfully added: ${animeWatchingHistory.first.lastTime}");
  }

  void persistOfflineData() async {
    final box = Hive.box('offline-data');
    await box.put('animeWatchingHistory',
        animeWatchingHistory.map((e) => e.toJson()).toList());
  }

  void loadfromHive() {
    final box = Hive.box('offline-data');
    final storedAnimeWatchingHistory =
        box.get('animeWatchingHistory', defaultValue: []);

    if (storedAnimeWatchingHistory != null) {
      animeWatchingHistory.assignAll((storedAnimeWatchingHistory as List)
          .map((i) => LocalHistory.fromJson(i))
          .toList());
    }
    log(storedAnimeWatchingHistory.toString());
  }

  void removeFromWatchingHistory(int mediaId) {
    animeWatchingHistory.removeWhere((history) => history.mediaId == mediaId);
  }

  void addToReadingHistory(LocalHistory data) {
    final index =
        mangaReadingHistory.indexWhere((i) => i.mediaId == data.mediaId);
    if (index != -1) {
      mangaReadingHistory[index] = data;
    } else {
      mangaReadingHistory.add(data);
    }
    log("Succesfully added: ${animeWatchingHistory.length}");
  }

  void removeFromReadingHistory(int mediaId) {
    mangaReadingHistory.removeWhere((history) => history.mediaId == mediaId);
  }
}
