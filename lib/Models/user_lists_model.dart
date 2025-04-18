import 'dart:developer';

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:get/get.dart';

class UserListsModel {
  RxList<UserAnime> currentlyWatching = <UserAnime>[].obs;
  RxList<UserAnime> planning = <UserAnime>[].obs;
  RxList<UserAnime> completed = <UserAnime>[].obs;
  RxList<UserAnime> repeating = <UserAnime>[].obs;
  RxList<UserAnime> paused = <UserAnime>[].obs;
  RxList<UserAnime> dropped = <UserAnime>[].obs;

  UserListsModel();

  factory UserListsModel.fromJson(List<dynamic> jsonList) {
    final model = UserListsModel();

    for (var item in jsonList) {
      final status = item['status'];
      final entries = item['entries'] as List<dynamic>?;

      if (entries == null) continue;
      for (var entry in entries) {
        final anime = UserAnime.fromJson(entry);
        log("check: $entry");
        switch (status) {
          case 'CURRENT':
            model.currentlyWatching.add(anime);
            break;
          case 'PLANNING':
            model.planning.add(anime);
            break;
          case 'COMPLETED':
            model.completed.add(anime);
            break;
          case 'REPEATING':
            model.repeating.add(anime);
            break;
          case 'PAUSED':
            model.paused.add(anime);
            break;
          case 'DROPPED':
            model.dropped.add(anime);
            break;
        }
      }
    }
    log("list: ${model.completed.length.toString()}");
    return model;
  }
}
