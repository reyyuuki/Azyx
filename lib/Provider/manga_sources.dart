
import 'package:daizy_tv/utils/scraper/Manga/Manga_Sources/extract_class.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Sources/mangaKakalot.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Sources/manga_bat.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Sources/manga_nato.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Sources/mangakakalot_unofficial.dart';
import 'package:flutter/material.dart';

 class MangaSourcesProvider with ChangeNotifier {

  ExtractClass _instance = MangakakalotUnofficial();
  List<ExtractClass>? _sources;

  ExtractClass get instance => _instance;
  List<ExtractClass>? get sources => _sources;
  

  Future<void> allMangaSources() async {
    _sources = [];
   _sources?.add(MangakakalotUnofficial());
   _sources?.add(MangaNato());
   _sources?.add(MangaKakalot());
   _sources?.add(MangaBat());
   notifyListeners();
  }

  void setInstance(ExtractClass instance) {
    _instance = instance;
    notifyListeners();
  }

  // Future<void> addMangaSource(ExtractClass source) async {
  //   _sources.add(source);
  //   notifyListeners();
  // }
}