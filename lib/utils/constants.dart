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

List<Map<String, dynamic>> get animeCategories {
  final list = serviceHandler.userAnimeList.value;

  return [
    {
      "name": "All",
      "data": list.allList,
      "isManga": false,
    },
    {
      "name": "Completed",
      "data": list.completed,
      "isManga": false,
    },
    {
      "name": "Planning",
      "data": list.planning,
      "isManga": false,
    },
    {
      "name": "Watching",
      "data": list.currentlyWatching,
      "isManga": false,
    },
    {
      "name": list.repeating.isEmpty ? "Dropped" : "Repeating",
      "data": list.repeating.isEmpty ? list.dropped : list.repeating,
      "isManga": false,
    },
    {
      "name": "Paused",
      "data": list.paused,
      "isManga": false,
    },
  ];
}

List<Map<String, dynamic>> get mangaCategories {
  final list = serviceHandler.userMangaList.value;

  return [
    {
      "name": "All",
      "data": list.allList,
      "isManga": true,
    },
    {
      "name": "Completed",
      "data": list.completed,
      "isManga": true,
    },
    {
      "name": "Planning",
      "data": list.planning,
      "isManga": true,
    },
    {
      "name": "Reading",
      "data": list.currentlyWatching,
      "isManga": true,
    },
    {
      "name": list.repeating.isEmpty ? "Dropped" : "Repeating",
      "data": list.repeating.isEmpty ? list.dropped : list.repeating,
      "isManga": true,
    },
    {
      "name": "Paused",
      "data": list.paused,
      "isManga": true,
    },
  ];
}

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
