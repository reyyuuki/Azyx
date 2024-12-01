
import 'package:azyx/utils/sources/Anime/Base/base_class.dart';
import 'package:azyx/utils/sources/Anime/Extensions/hianime_api.dart';
import 'package:azyx/utils/sources/Anime/Extensions/hianime_scrapper.dart';
import 'package:azyx/utils/sources/Anime/SourceHandler/sourcehandler.dart';
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/mangaKakalot.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/manga_bat.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/manga_nato.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/mangakakalot_unofficial.dart';
import 'package:azyx/utils/sources/Manga/SourceHandler/sourcehandler.dart';
import 'package:azyx/utils/sources/Novel/SourceHandler/novel_sourcehandler.dart';
import 'package:azyx/utils/sources/Novel/base/base_class.dart';
import 'package:azyx/utils/sources/Novel/Extensions/novel_buddy.dart';
import 'package:azyx/utils/sources/Novel/Extensions/wuxia_novel.dart';
import 'package:flutter/material.dart';

 class SourcesProvider with ChangeNotifier {

  ExtractClass _instance = MangakakalotUnofficial();
  EXtractAnimes _animeInstance = HianimeApi();
  NovelSourceBase _novelInstance = NovelBuddy();
  List<ExtractClass>? _sources;
  List<EXtractAnimes>? _animeSources;
  List<NovelSourceBase>? _novelSource;
  AnimeSourcehandler animehandler = AnimeSourcehandler();
  MangaSourcehandler mangaSourcehandler = MangaSourcehandler();
  NovelSourcehandler novelSourcehandler = NovelSourcehandler();

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

  AnimeSourcehandler getAnimeInstace(){
    return animehandler;
  }

  MangaSourcehandler getMangaInstance(){
    return mangaSourcehandler;
  }

  NovelSourcehandler getNovelInstance(){
    return novelSourcehandler;
  }
}
