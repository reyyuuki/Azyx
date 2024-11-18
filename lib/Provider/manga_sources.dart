
import 'package:daizy_tv/utils/scraper/Anime/base_class.dart';
import 'package:daizy_tv/utils/scraper/Anime/sources/hianime_api.dart';
import 'package:daizy_tv/utils/scraper/Anime/sources/hianime_scrapper.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/extract_class.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/mangaKakalot.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/manga_bat.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/manga_nato.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/mangakakalot_unofficial.dart';
import 'package:daizy_tv/utils/scraper/Novel/base/base_class.dart';
import 'package:daizy_tv/utils/scraper/Novel/novel_buddy.dart';
import 'package:daizy_tv/utils/scraper/Novel/wuxia_novel.dart';
import 'package:flutter/material.dart';

 class MangaSourcesProvider with ChangeNotifier {

  ExtractClass _instance = MangakakalotUnofficial();
  EXtractAnimes _animeInstance = HianimeApi();
  NovelSourceBase _novelInstance = NovelBuddy();
  List<ExtractClass>? _sources;
  List<EXtractAnimes>? _animeSources;
  List<NovelSourceBase>? _novelSource;

  ExtractClass get instance => _instance;
  List<ExtractClass>? get sources => _sources;
  EXtractAnimes get animeInstance => _animeInstance;
  List<EXtractAnimes>? get animeSources => _animeSources;
  NovelSourceBase get novelInstance => _novelInstance;
  List<NovelSourceBase>? get novelSource => _novelSource;
  

  Future<void> allMangaSources() async {
    _sources = [];
   _sources?.add(MangakakalotUnofficial());
   _sources?.add(MangaNato());
   _sources?.add(MangaKakalot());
   _sources?.add(MangaBat());

   _animeSources = [];
   _animeSources?.add(HianimeApi());
   _animeSources?.add(HianimeScrapper());

   _novelSource = [];
  _novelSource?.add(NovelBuddy());
  _novelSource?.add(WuxiaClick());
   notifyListeners();
  }


  void setInstance(ExtractClass instance) {
    _instance = instance;
    notifyListeners();
  }

  void setAnimeInstance(EXtractAnimes instance) {
    _animeInstance = instance;
    notifyListeners();
  }

  void setNovelInstance(NovelSourceBase instance) {
    _novelInstance = instance;
    notifyListeners();
  }

  scrapeHomePageData() {}

  // Future<void> addMangaSource(ExtractClass source) async {
  //   _sources.add(source);
  //   notifyListeners();
  // }
}
