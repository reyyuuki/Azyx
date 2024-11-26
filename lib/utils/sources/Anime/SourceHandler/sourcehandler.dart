import 'dart:developer';

import 'package:daizy_tv/utils/sources/Anime/Extensions/anivibe_scrapper.dart';
import 'package:daizy_tv/utils/sources/Anime/Extensions/gogoanime.dart';
import 'package:daizy_tv/utils/sources/Anime/Base/base_class.dart';
import 'package:daizy_tv/utils/sources/Anime/Extensions/hianime_api.dart';
import 'package:daizy_tv/utils/sources/Anime/Extensions/hianime_scrapper.dart';

class AnimeSourcehandler {
  final Map<String, EXtractAnimes> animeSources = {
    "Hianime": HianimeApi(),
    "Hianime (Scrapper)": HianimeScrapper(),
    "GogoAnime": GogoAnime(),
    "AniVibe": AniVibe()
  };

  AnimeSourcehandler() {
    selectedSource = animeSources.entries.first.key;
  }
  
  String selectedSource = "";

  String getSelectedSource() {
    if (selectedSource == "") {
      return selectedSource = animeSources.entries.first.key;
    }
    return selectedSource;
  }

  void changeSource(String sourceName) {
    if (animeSources.entries.any((source) => source.key == sourceName)) {
      selectedSource = sourceName;
    }
    selectedSource = animeSources.entries.first.key;
  }

  List<Map<String,String>> getAvailableSources() {
    return animeSources.entries.map((entry) {
      return {"name": entry.value.sourceName};
    }).toList();
  }

  Future<dynamic> mappedSourceId(String query) async {
    try {
      final String? id = await animeSources[selectedSource]?.mappingId(query);
      if (id != null && id.isNotEmpty) {
        return await fetchEpisodes(id);
      }
    } catch (e) {
      log("Error in mappedSourceId: $e");
      return null;
    }
  }

  Future<dynamic> fetchEpisodes(String url) async {
    final data = await animeSources[selectedSource]?.scrapeAnimeEpisodes(url);
    return data;
  }

  Future<dynamic> fetchSearchResults(String query) async {
    final data = await animeSources[selectedSource]?.scrapeAnimeSearch(query);
    return data;
  }

  Future<dynamic> fetchEpisodesSrcs(
      String id, String server, String category) async {
    final data = await animeSources[selectedSource]
        ?.scrapeEpisodesSrc(id, server, category);
    return data;
  }
}
