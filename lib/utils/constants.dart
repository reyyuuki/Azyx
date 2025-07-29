import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Screens/Home/UserLists/widgets/grid_list.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';

final List<double> scoresItems = [
  0.0,
  0.5,
  1.0,
  1.5,
  2.0,
  2.5,
  3.0,
  3.5,
  4.0,
  4.5,
  5.0,
  5.5,
  6.0,
  6.5,
  7.0,
  7.5,
  8.0,
  8.5,
  9.0,
  9.5,
  10.0
];
BoxShadow glowingShadow(context) {
  return BoxShadow(
      color:
          Theme.of(context).colorScheme.primary.withOpacity(1.glowMultiplier()),
      blurRadius: 10.blurMultiplier());
}

final List<String> items = [
  "CURRENT",
  "PLANNING",
  "COMPLETED",
  "REPEATING",
  "PAUSED",
  "DROPPED"
];

final List<Map<String, dynamic>> animeCategories = [
  {
    "name": "All",
    "view": UserGridList(
      data: serviceHandler.userAnimeList.value.allList,
      isManga: false,
    )
  },
  {
    "name": "Completed",
    "view": UserGridList(
        isManga: false, data: serviceHandler.userAnimeList.value.completed)
  },
  {
    "name": "Planning",
    "view": UserGridList(
        isManga: false, data: serviceHandler.userAnimeList.value.planning)
  },
  {
    "name": "Watching",
    "view": UserGridList(
        isManga: false,
        data: serviceHandler.userAnimeList.value.currentlyWatching)
  },
  {
    "name": serviceHandler.userAnimeList.value.repeating.isEmpty
        ? "Dropped"
        : "Repeating",
    "view": UserGridList(
        isManga: false,
        data: serviceHandler.userAnimeList.value.repeating.isEmpty
            ? serviceHandler.userAnimeList.value.dropped
            : serviceHandler.userAnimeList.value.repeating)
  },
  {
    "name": "Paused",
    "view": UserGridList(
        isManga: false, data: serviceHandler.userAnimeList.value.paused)
  },
];

final List<Map<String, dynamic>> mangaCategories = [
  {
    "name": "All",
    "view": UserGridList(
      data: serviceHandler.userMangaList.value.allList,
      isManga: true,
    )
  },
  {
    "name": "Completed",
    "view": UserGridList(
        isManga: true, data: serviceHandler.userMangaList.value.completed)
  },
  {
    "name": "Planning",
    "view": UserGridList(
        isManga: true, data: serviceHandler.userMangaList.value.planning)
  },
  {
    "name": "Reading",
    "view": UserGridList(
        isManga: true,
        data: serviceHandler.userMangaList.value.currentlyWatching)
  },
  {
    "name": serviceHandler.userMangaList.value.repeating.isEmpty
        ? "Dropped"
        : "Repeating",
    "view": UserGridList(
        isManga: true,
        data: serviceHandler.userMangaList.value.repeating.isEmpty
            ? serviceHandler.userMangaList.value.dropped
            : serviceHandler.userMangaList.value.repeating)
  },
  {
    "name": "Paused",
    "view": UserGridList(
        isManga: true, data: serviceHandler.userMangaList.value.paused)
  },
];

String getAniListStatusEquivalent(String status) {
  switch (status.toLowerCase()) {
    case 'watching':
      return 'CURRENT';
    case 'completed':
      return 'COMPLETED';
    case 'on_hold':
      return 'PAUSED';
    case 'dropped':
      return 'DROPPED';
    case 'plan_to_watch':
      return 'PLANNING';
    default:
      return 'UNKNOWN';
  }
}

String returnConvertedStatus(String status) {
  switch (status) {
    case 'watching' || 'reading':
      return 'CURRENT';
    case 'completed':
      return 'COMPLETED';
    case 'on_hold':
      return 'PAUSED';
    case 'dropped':
      return 'DROPPED';
    case 'plan_to_watch' || 'plan_to_read':
      return 'PLANNING';
    default:
      return '';
  }
}

String getMALStatusEquivalent(String status, {bool isAnime = true}) {
  switch (status.toUpperCase()) {
    case 'CURRENT':
      return isAnime ? 'watching' : 'reading';
    case 'COMPLETED':
      return 'completed';
    case 'PAUSED':
      return 'on_hold';
    case 'DROPPED':
      return 'dropped';
    case 'PLANNING':
      return isAnime ? 'plan_to_watch' : 'plan_to_read';
    default:
      return 'unknown';
  }
}
