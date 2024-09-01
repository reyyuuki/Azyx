import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Data extends ChangeNotifier {
  List<Map<String, dynamic>>? animeWatches = [];
  List<Map<String, dynamic>>? readsmanga = [];

  Data() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      var box = Hive.box("app-data");
      animeWatches = List<Map<String, dynamic>>.from(
          box.get("currently-Watching", defaultValue: []));
      readsmanga = List<Map<String, dynamic>>.from(
          box.get("currently-Reading", defaultValue: []));
      log("Loaded data: $readsmanga");
    } catch (e) {
      log("Failed to load data: $e");
    }
  }

  void setWatchedAnimes(List<Map<String, dynamic>> anime) {
    animeWatches = anime;
    var box = Hive.box("app-data");
    box.put("currently-Watching", anime);
    notifyListeners();
  }

  void addWatchedAnimes({
    required String animeId,
    required String animeTitle,
    required String currentEpisode,
    required String posterImage,
  }) {
    animeWatches ??= [];

    final newAnime = {
      'animeId': animeId,
      'animeTitle': animeTitle,
      'currentEpisode': currentEpisode,
      'posterImage': posterImage,
    };

    animeWatches!.removeWhere((anime) => anime['animeId'] == animeId);
    animeWatches!.add(newAnime);

    var box = Hive.box("app-data");
    box.put("currently-Watching", animeWatches);
    log("Updated anime watches: $animeWatches");
    notifyListeners();
  }

  void setReadsMangas(List<Map<String, dynamic>> manga) {
    readsmanga = manga;
    var box = Hive.box("app-data");
    box.put("currently-Reading", manga);
    notifyListeners();
  }

  void addReadsManga({
    required String mangaId,
    required String mangaTitle,
    required String currentChapter,
    required String mangaImage,
  }) {
    readsmanga ??= [];

    final newManga = {
      'mangaId': mangaId,
      'mangaTitle': mangaTitle,
      'currentChapter': currentChapter,
      'posterImage': mangaImage,
    };

    readsmanga!.removeWhere((manga) => manga['mangaId'] == mangaId);
    readsmanga!.add(newManga);

    var box = Hive.box("app-data");
    box.put("currently-Reading", readsmanga);
    log("Updated reads manga: $readsmanga");
    notifyListeners();
  }

  Map<String, dynamic>? getAnimeById(String animeId) {
    final anime = animeWatches?.firstWhere(
      (anime) => anime['animeId'] == animeId,
      orElse: () => {},
    );
    log("Fetched anime by ID ($animeId): $anime");
    return anime;
  }

  Map<String, dynamic>? getMangaById(String mangaId) {
    final manga = readsmanga?.firstWhere(
      (manga) => manga['mangaId'] == mangaId,
      orElse: () => {},
    );
    log("Fetched manga by ID ($mangaId): $manga");
    return manga;
  }

  String? getCurrentEpisodeForAnime(String animeId) {
    final anime = getAnimeById(animeId);
    log('Anime fetched for current episode: $anime');
    return anime?['currentEpisode'] ?? '1';
  }

  String? getCurrentChapterForManga(String mangaId) {
    final manga = getMangaById(mangaId);
    log('Manga fetched for current chapter: $manga');
    return manga?['currentChapter'] ?? '1';
  }
}