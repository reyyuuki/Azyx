// ignore_for_file: file_names

import 'dart:developer';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/extract_class.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Data extends ChangeNotifier {
  List<Map<String, dynamic>>? animeWatches = [];
  List<Map<String, dynamic>>? readsmanga = [];
  List<Map<String, dynamic>>? readsnovel = [];
  List<Map<String, dynamic>>? favoriteManga = [];
  List<Map<String, dynamic>>? favoriteAnime = [];
  List<Map<String, dynamic>>? favoriteNovel = [];

  Data() {
    loadData();
  }


void loadData() async {
  try {
    var box = Hive.box("app-data");

    favoriteManga = List<Map<String, dynamic>>.from(
      (box.get("favoriteManga", defaultValue: []) as List)
          .map((item) => Map<String, dynamic>.from(item)),
    );
    favoriteAnime = List<Map<String, dynamic>>.from(
      (box.get("favoriteAnime", defaultValue: []) as List)
          .map((item) => Map<String, dynamic>.from(item)),
    );
    favoriteNovel = List<Map<String, dynamic>>.from(
      (box.get("favoriteNovel", defaultValue: []) as List)
          .map((item) => Map<String, dynamic>.from(item)),
    );

    animeWatches = List<Map<String, dynamic>>.from(
      (box.get("currently-Watching", defaultValue: []) as List)
          .map((item) => Map<String, dynamic>.from(item)),
    );
    readsmanga = List<Map<String, dynamic>>.from(
      (box.get("currently-Reading", defaultValue: []) as List)
          .map((item) => Map<String, dynamic>.from(item)),
    );
    readsnovel = List<Map<String, dynamic>>.from(
      (box.get("readsnovel", defaultValue: []) as List)
          .map((item) => Map<String, dynamic>.from(item)),
    );

    log("Data updated from Hive box: ");
    log("favoriteManga: $favoriteManga");
    log("favoriteAnime: $favoriteAnime");
    log("favoriteNovel: $favoriteNovel");
    log("animeWatches: $animeWatches");
    log("readsmanga: $readsmanga");
    log("readsnovel: $readsnovel");

    notifyListeners();
  } catch (e) {
    log("Failed to update data: $e");
  }
}




  void setWatchedAnimes(List<Map<String, dynamic>> animes) {
    animeWatches = animes;
    var box = Hive.box("app-data");
    box.put("currently-Watching", animes);
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

  void setReadsMangas(List<Map<String, dynamic>> mangas) {
    readsmanga = mangas;
    var box = Hive.box("app-data");
    box.put("currently-Reading", mangas);
    notifyListeners();
  }

  void addReadsManga({
    required String mangaId,
    required String mangaTitle,
    required String currentChapter,
    required String mangaImage,
    required String currentChapterTitle
  }) {
    readsmanga ??= [];

    final newManga = {
      'mangaId': mangaId,
      'mangaTitle': mangaTitle,
      'currentChapter': currentChapter,
      'mangaImage': mangaImage,
      'currentChapterTitle': currentChapterTitle,
    };

    readsmanga!.removeWhere((manga) => manga['mangaId'] == mangaId);
    readsmanga!.add(newManga);

    var box = Hive.box("app-data");
    box.put("currently-Reading", readsmanga);
    log("Updated reads manga: $readsmanga");
    notifyListeners();
  }

  void setReadsNovel(List<Map<String, dynamic>> novels) {
    readsmanga = novels;
    var box = Hive.box("app-data");
    box.put("readsnovel", novels);
    notifyListeners();
  }

  void addReadsNovel({
    required String novelId,
    required String noveltitle,
    required String currentChapter,
    required String image,
  }) {
    readsmanga ??= [];

    final newNovel = {
      'novelId': novelId,
      'noveltitle': noveltitle,
      'currentChapter': currentChapter,
      'image': image,
    };

    readsnovel!.removeWhere((novel) => novel['novelId'] == novelId);
    readsnovel!.add(newNovel);

    var box = Hive.box("app-data");
    box.put("readsnovel", readsnovel);
    log("Updated reads manga: $readsnovel");
    notifyListeners();
  }

Map<String, dynamic>? getNovelById(String novelId) {
    return readsnovel?.firstWhere(
      (novel) => novel['novelId'] == novelId,
      orElse: () => {},
    );
  }

  Map<String, dynamic>? getAnimeById(String animeId) {
    return animeWatches?.firstWhere(
      (anime) => anime['animeId'] == animeId,
      orElse: () => {},
    );
  }

  Map<String, dynamic>? getMangaById(String mangaId) {
    return readsmanga?.firstWhere(
      (manga) => manga['mangaId'] == mangaId,
      orElse: () => {},
    );
  }

Map<String,dynamic>? getFavoritesAnimeById(String id){
  return favoriteAnime!.firstWhere((anime) => anime['id'] == id);
}

Map<String, dynamic>? getFavoriteMangaById(String mangaId) {
    return favoriteManga?.firstWhere(
      (manga) => manga['id'] == mangaId,
      orElse: () => {},
    );
  }  

String? getCurrentChapterForNovel(String novelId) {
    final novel = getNovelById(novelId);
    log('Novel fetched for current chapter: $novel');
    return novel?['currentChapter'];
  }

  String? getCurrentEpisodeForAnime(String animeId) {
    final anime = getAnimeById(animeId);
    log('Anime fetched for current episode: $anime');
    return anime?['currentEpisode'];
  }

  Map<String,dynamic>? getCurrentChapterForManga(String mangaId) {
    final manga = getMangaById(mangaId);
    log('Manga fetched for current chapter: $manga');
    return manga;
  }

  void addFavrouiteManga({
    required String title,
    required String id,
    required String image,
    required String currentChapter,
    required String currentLink,
    required List<Map<String, dynamic>> chapterList,
    required String description,
  }) {
    favoriteManga ??= [];

    final manga = {
      'title': title,
      'id': id,
      'image': image,
      'currentChapter': currentChapter,
      'currentLink': currentLink,
      "chapterList": chapterList,
      'description': description,
    };

    favoriteManga!.removeWhere((manga) => manga['id'] == id);
    favoriteManga!.add(manga);

    var box = Hive.box("app-data");
    box.put("favoriteManga", favoriteManga);
    // log('updates new favrouite: $favoriteManga');
    notifyListeners();
  }

  void addFavrouiteAnime({
    required String title,
    required String id,
    required String image,
    required String server,
    required String category,
    required String description,
    required List<Map<String,dynamic>> episodeList
  }) {
    favoriteAnime ??= [];

    final anime = {
      'title': title,
      'id': id,
      'image': image,
      'server': server,
      'category': category,
      'episodeList': episodeList,
      'description': description
    };

    favoriteAnime!.removeWhere((anime) => anime['id'] == id);
    favoriteAnime!.add(anime);

    var box = Hive.box("app-data");
    box.put("favoriteAnime", favoriteAnime);
    log('updates new favrouite: $favoriteAnime');
    notifyListeners();
  }

  void removefavrouiteAnime(String id) {
    favoriteAnime!.removeWhere((anime) => anime['id'] == id);
    var box = Hive.box("app-data");
    box.put("favoriteAnime", favoriteAnime);
    log("After Remove: $favoriteAnime");
    notifyListeners();
  }

  void addFavrouiteNovel({
    required String title,
    required String id,
    required String image,
  }) {
    favoriteNovel ??= [];

    final novel = {
      'title': title,
      'id': id,
      'image': image,
    };

    favoriteNovel!.removeWhere((novel) => novel['id'] == id);
    favoriteNovel!.add(novel);

    var box = Hive.box("app-data");
    box.put("favoriteNovel", favoriteNovel);
    log('updates new favrouite: $favoriteNovel');
    notifyListeners();
  }

  void removefavrouiteNovel(String id) {
    favoriteNovel!.removeWhere((novel) => novel['id'] == id);
    var box = Hive.box("app-data");
    box.put("favoriteNovel", favoriteNovel);
    log("After Remove: $favoriteNovel");
    notifyListeners();
  }

   void removefavrouite(String id) {
    favoriteManga!.removeWhere((manga) => manga['id'] == id);
    var box = Hive.box("app-data");
    box.put("favoriteManga", favoriteManga);
    log("After Remove: $favoriteManga");
    notifyListeners();
  }

  bool getFavroite(String id) {
    log(favoriteManga!.any((manga) => manga['id'] == id).toString());
    return favoriteManga!.any((manga) => manga['id'] == id);
  }


  bool getFavroiteAnime(String id) {
    log(favoriteAnime!.any((anime) => anime['id'] == id).toString());
    return favoriteAnime!.any((anime) => anime['id'] == id);
  }

  bool getFavroiteNovel(String id) {
    log(favoriteNovel!.any((novel) => novel['id'] == id).toString());
    return favoriteNovel!.any((novel) => novel['id'] == id);
  }
}
