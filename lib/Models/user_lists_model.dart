import 'dart:developer';

import 'package:azyx/Models/user_media.dart';
import 'package:get/get.dart';

class UserListsModel {
  RxList<UserMedia> currentlyWatching = <UserMedia>[].obs;
  RxList<UserMedia> planning = <UserMedia>[].obs;
  RxList<UserMedia> completed = <UserMedia>[].obs;
  RxList<UserMedia> repeating = <UserMedia>[].obs;
  RxList<UserMedia> paused = <UserMedia>[].obs;
  RxList<UserMedia> dropped = <UserMedia>[].obs;
  RxList<UserMedia> allList = RxList<UserMedia>();

  UserListsModel();

  factory UserListsModel.fromJson(List<dynamic> jsonList) {
    final model = UserListsModel();

    for (var item in jsonList) {
      final entries = item['entries'] as List<dynamic>?;
      if (entries == null) continue;
      for (var entry in entries) {
        final anime = UserMedia.fromJson(entry);
        model.allList.add(anime);
        final status = entry['status'];
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
    return model;
  }

  factory UserListsModel.fromMAl(List<dynamic> jsonList) {
    final model = UserListsModel();

    for (var item in jsonList) {
      final entry = item['node'];
      log("check => ${entry.toString()}");
      if (entry == null) continue;
      final anime = UserMedia.fromMAL(item);
      model.allList.add(anime);
      final status = item['list_status']['status']
          .toString()
          .replaceAll("_", '')
          .toUpperCase();
      switch (status) {
        case 'WATCHING':
        case 'READING':
          model.currentlyWatching.add(anime);
          break;
        case 'PLANTOREAD':
        case 'PLANTOWATCH':
          model.planning.add(anime);
          break;
        case 'COMPLETED':
          model.completed.add(anime);
          break;
        case 'ONHOLD':
          model.paused.add(anime);
          break;
        case 'DROPPED':
          model.dropped.add(anime);
          break;
      }
    }
    return model;
  }
}
