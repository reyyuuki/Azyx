import 'dart:developer';

import 'package:azyx/utils/helper/jaro_winkler.dart';
import 'package:azyx/utils/scraper/Manga/Comick.dart';
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/mangaKakalot.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/manga_bat.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/manga_nato.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/mangakakalot_unofficial.dart';

class MangaSourcehandler {
  final Map<String, ExtractClass> sources = {
    "ComicK": Comick(),
    "MangaKakalot": MangaKakalot(),
    "MangaNato": MangaNato(),
    "MangaBat": MangaBat(),
    "MangaKakalot Unofficial": MangakakalotUnofficial(),
  };

  MangaSourcehandler() {
    selectedSource = sources.entries.first.key;
  }

  String selectedSource = '';

  List<Map<String, String>> getAvailableSources() {
    return sources.entries.map((entry) {
      return {"name": entry.value.sourceName};
    }).toList();
  }

  void changeSource(String newSource) {
    if (sources.entries.any((source) => source.key == newSource)) {
      selectedSource = newSource;
    }
    selectedSource = sources.entries.first.key;
  }

  String getSelectedSource() {
    if (selectedSource == "") {
      return selectedSource = sources.entries.first.key;
    }
    return selectedSource;
  }

  Future<dynamic> mappingData(String query, {int page = 1}) async {
    try {
      String? id = await searchMostSimilarManga(query, fetchSearchData);

      if (id.isNotEmpty) {
        return await sources[selectedSource]?.fetchChapters(id);
      } else {
        log('No similar manga found for query: $query');
        return null;
      }
    } catch (e, stackTrace) {
      log('Error in mappingData function: $e\n$stackTrace');
      return null;
    }
  }

  Future<dynamic> fetchSearchData(String query) async {
    final data = await sources[selectedSource]?.fetchSearchsManga(query);
    return data;
  }

  Future<dynamic> fetchChapters(String url) async {
    return await sources[selectedSource]?.fetchChapters(url);
  }

  Future<dynamic> fetchPages(String url) async {
    log('${sources[selectedSource]?.fetchPages(url)}');
    return await sources[selectedSource]?.fetchPages(url);
  }
}
