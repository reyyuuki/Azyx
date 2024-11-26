import 'dart:developer';

import 'package:daizy_tv/Screens/Anime/episode_src.dart';
import 'package:daizy_tv/utils/helper/jaro_winkler.dart';
import 'package:daizy_tv/utils/scraper/Anime/aniwatch_search.dart';
import 'package:daizy_tv/utils/sources/Anime/Base/base_class.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

class HttpError implements Exception {
  final int statusCode;
  final String message;

  HttpError(this.statusCode, this.message);

  @override
  String toString() => 'HttpError: $statusCode $message';
}

class HianimeScrapper implements EXtractAnimes {
  @override
  String sourceName = "Hianime (Scrapper)";

  @override
  String url = "https://hianime.to";

  @override
  Future<Map<String, dynamic>> scrapeAnimeEpisodes(String animeId) async {
    const String srcBaseUrl = 'https://hianime.to';
    const String srcAjaxUrl = 'https://hianime.to/ajax/v2/episode/list';
    const String acceptHeader =
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7';
    const String userAgentHeader =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
    const String acceptEncodingHeader = 'gzip, deflate, br';

    try {
      final response = await http.get(
        Uri.parse('$srcAjaxUrl/${animeId.split('-').last}'),
        headers: {
          'Accept': acceptHeader,
          'User-Agent': userAgentHeader,
          'X-Requested-With': 'XMLHttpRequest',
          'Accept-Encoding': acceptEncodingHeader,
          'Referer': '$srcBaseUrl/watch/$animeId',
        },
      );

      if (response.statusCode != 200) {
        throw HttpError(response.statusCode, 'Failed to fetch episodes');
      }

      final jsonResponse = json.decode(response.body);
      final document = parse(jsonResponse['html']);

      final episodeElements =
          document.querySelectorAll('.detail-infor-content .ss-list a');
      final totalEpisodes = episodeElements.length;

      final episodes = episodeElements.map((element) {
        return {
          'title': element.attributes['title']?.trim(),
          'episodeId': element.attributes['href']?.split('/').last,
          'number': int.tryParse(element.attributes['data-number'] ?? '') ?? 0,
          'isFiller': element.classes.contains('ssl-item-filler'),
        };
      }).toList();

      final scrapedData = {
        'totalEpisodes': totalEpisodes,
        'episodes': episodes,
        'name': formatAnimeTitle(animeId)
      };
      return scrapedData;
    } catch (e) {
      if (e is http.ClientException) {
        throw HttpError(500, 'Network error: ${e.message}');
      } else if (e is HttpError) {
        rethrow;
      } else {
        throw HttpError(500, 'Internal server error: ${e.toString()}');
      }
    }
  }

  String formatAnimeTitle(String animeId) {
  var arr = animeId.split('-').toList();
  arr.removeLast();
  var animeTitle =
      arr.map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  return animeTitle;
}

  @override
  Future<dynamic> scrapeEpisodesSrc(
      String id, String server, String category) async {
    try {
      final data = scrapeAnimeEpisodeSources(id, category: category);
      if (data != null) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> scrapeAnimeSearch(String query,
      {int page = 1}) async {
    const String baseUrl = 'https://hianime.to/';
    final String url =
        '${baseUrl}search?keyword=$query&page=$page&sort=default';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final animes = extractAnimes(
            document, '#main-content .tab-content .film_list-wrap .flw-item');
        return animes;
      } else {
        throw Exception(
            'Failed to load search results. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch anime search results: $e');
    }
  }

  @override
  Future<String?> mappingId(String query) async {
    try {
      final result = await scrapeAnimeSearch(query) as List<dynamic>?;
      if (result == null || result.isEmpty) {
        return null; 
      }

      String? bestMatchId;
      double highestSimilarity = 0.0;

      for (var anime in result) {
        if (anime is Map<String, dynamic> &&
            anime['name'] is String &&
            anime['id'] is String) {
          final similarity = jaroWinklerDistance(query, anime['name']);
          if (similarity > highestSimilarity) {
            highestSimilarity = similarity;
            bestMatchId = anime['id'];
          }
        }
      }
      log(bestMatchId.toString());
      return bestMatchId;
    } catch (e) {
      return null;
    }
  }
}
