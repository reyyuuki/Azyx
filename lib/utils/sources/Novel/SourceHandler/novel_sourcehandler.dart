import 'dart:developer';

import 'package:daizy_tv/utils/helper/jaro_winkler.dart';
import 'package:daizy_tv/utils/sources/Novel/Extensions/novel_buddy.dart';
import 'package:daizy_tv/utils/sources/Novel/Extensions/wuxia_novel.dart';
import 'package:daizy_tv/utils/sources/Novel/base/base_class.dart';

class NovelSourcehandler {
  final Map<String, NovelSourceBase> sources = {
    "NovelBuddy": NovelBuddy(),
    "WuxiaClick": WuxiaClick()
  };

  NovelSourcehandler() {
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

  Future<dynamic> mappingData(String query) async {
    try {
      String? id = await searchMostSimilarNovel(query, fetchSearchData);

      if (id.isNotEmpty) {
        return await sources[selectedSource]?.scrapeNovelDetails(id);
      } else {
        log('No similar novel found for query: $query');
        return null;
      }
    } catch (e, stackTrace) {
      log('Error in mappingData function: $e\n$stackTrace');
      return null;
    }
  }

  Future<dynamic> fetchSearchData(String query) async {
    final data = await sources[selectedSource]?.scrapeNovelSearchData(query);
    return data;
  }

  Future<dynamic> fetchChapters(String url) async {
    return await sources[selectedSource]?.scrapeNovelDetails(url);
  }

  Future<dynamic> fetchWords(String url) async {
    return await sources[selectedSource]?.scrapeNovelWords(url);
  }
}
