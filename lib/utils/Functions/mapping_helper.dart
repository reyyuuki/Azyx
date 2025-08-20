// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

double jaroWinklerDistance(String s1, String s2) {
  if (s1 == s2) return 1.0;
  final maxLength = [s1.length, s2.length].reduce((a, b) => a > b ? a : b);
  final matchWindow = (maxLength / 2).floor() - 1;
  final matches = <String>[];
  final s1Matches = List<bool>.filled(s1.length, false);
  final s2Matches = List<bool>.filled(s2.length, false);

  for (int i = 0; i < s1.length; i++) {
    final start = i - matchWindow >= 0 ? i - matchWindow : 0;
    final end =
        i + matchWindow + 1 < s2.length ? i + matchWindow + 1 : s2.length;

    for (int j = start; j < end; j++) {
      if (!s2Matches[j] && s1[i] == s2[j]) {
        s1Matches[i] = true;
        s2Matches[j] = true;
        matches.add(s1[i]);
        break;
      }
    }
  }

  if (matches.isEmpty) return 0.0;

  int t = 0;
  int k = 0;
  for (int i = 0; i < s1.length; i++) {
    if (s1Matches[i]) {
      while (!s2Matches[k]) k++;
      if (s1[i] != s2[k]) t++;
      k++;
    }
  }

  final m = matches.length.toDouble();
  final jaroSimilarity = (m / s1.length + m / s2.length + (m - t / 2) / m) / 3;
  int l = 0;
  while (l < s1.length && l < s2.length && s1[l] == s2[l] && l < 4) l++;

  return jaroSimilarity + (l * 0.1 * (1 - jaroSimilarity));
}

Future<Map<String, dynamic>?> mappingHelper(
    String query, List<DMedia> result) async {
  try {
    final animeList = result;

    if (animeList.isEmpty) {
      log('No anime data found.');
      return null;
    }

    Map<String, dynamic>? mostSimiliarAnime;
    double highestSimilarity = 0.0;

    for (var anime in animeList) {
      if (anime.title is String) {
        final name = anime.title as String;
        final link = anime.url;
        log('name: $name / link: $link');
        final similarity = jaroWinklerDistance(query, name);

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          mostSimiliarAnime = {'name': name, 'link': link};
        }
      } else {
        log("Error: Manga item does not have the expected structure or types: ${anime.toString()}");
      }
    }

    log("Most similar anime found: ${mostSimiliarAnime.toString()}");

    return mostSimiliarAnime;
  } catch (e, stackTrace) {
    log("Error in searchMostSimilarManga function: $e\n$stackTrace");
    return null;
  }
}

Future<String> searchMostSimilarNovel(
    String query, Future<dynamic> Function(String) scrapeFunction) async {
  try {
    final result = await scrapeFunction(query);
    final novelList = result as List<dynamic>?;

    if (novelList == null) {
      log('No novel data found.');
      return '';
    }

    Map<String, dynamic>? mostSimilarNovel;
    double highestSimilarity = 0.0;

    for (var novel in novelList) {
      if (novel is Map<String, dynamic> &&
          novel.containsKey('title') &&
          novel.containsKey('id') &&
          novel['title'] is String &&
          novel['id'] is String) {
        final title = novel['title'] as String;
        final id = novel['id'] as String;

        final similarity = jaroWinklerDistance(query, title);

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          mostSimilarNovel = {'title': title, 'id': id};
        }
      } else {
        log("Error: Novel item does not have the expected structure or types: ${novel.toString()}");
      }
    }

    log("Most similar novel found: ${mostSimilarNovel.toString()}");

    return mostSimilarNovel!['id'];
  } catch (e, stackTrace) {
    log("Error in searchMostSimilarManga function: $e\n$stackTrace");
    return '';
  }
}
