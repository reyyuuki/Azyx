import 'package:azyx/utils/helper/jaro_winkler.dart';
import 'package:azyx/utils/sources/Anime/Base/base_class.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:developer';

class AniVibe implements EXtractAnimes {

  @override
  String get sourceName => "AniVibe";

  @override
  String get url => "https://anivibe.net";

  @override
  Future<Map<String, dynamic>> scrapeAnimeEpisodes(String animeId) async {
  try {
    final url = "https://anivibe.net$animeId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = html.parse(response.body);
      final title = document.querySelector(".infox h1")?.text.trim();

      // Ensure episodes is typed as List<Map<String, dynamic>>
      final List<Map<String, dynamic>> episodes = [];
      final episodesData = document.querySelectorAll(".eplister li");

      for (var episode in episodesData) {
        final id = episode.querySelector("a")?.attributes['href'];
        final number = episode.querySelector(".epl-num")?.text.trim();
        final title = episode.querySelector('.epl-title')?.text.trim();

        if (id != null && number != null && title != null) {
          episodes.add({
            "title": title,
            "number": int.parse(number),
            "episodeId": id,
          });
        }
      }

      return {
        "episodes": episodes.reversed.toList(),
        "name": title ?? "Unknown Title",
        "totalEpisodes": episodes.length,
      };
    }
  } catch (e) {
    log("Error while scraping AniVibe: $e");
  }

  return {
    "episodes": <Map<String, dynamic>>[], 
    "name": "Unknown Title",
    "totalEpisodes": 0,
  };
}
  @override
  Future<List<Map<String,dynamic>>> scrapeAnimeSearch(String query) async {
    try {
      String formatedQuery = query.split(" ").join("+");
      final url = "https://anivibe.net/search.html?keyword=$formatedQuery";
      final response = await http.get(Uri.parse(url));
      final List<Map<String,dynamic>> searchData = [];
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final searchElements = document.querySelectorAll(".listupd .bs");

        for (var searchItem in searchElements) {
          final id = searchItem.querySelector(".bsx a")?.attributes['href'];
          final title = searchItem
              .querySelector(".bsx a .limit img")
              ?.attributes['title'];
          final image =
              searchItem.querySelector(".bsx a .limit img")?.attributes['src'];

          searchData.add({
            "id": id,
            "name": title,
            "poster": image,
          });
          log(searchData.toString());
        }

        return searchData;
      }
    } catch (e) {
      log("Error while searching data: $e");
    }
    return [];
  }
  @override
Future<dynamic> scrapeEpisodesSrc(String episodeId, String server, String category,
    {bool isDub = false}) async {
  final data = {"sources": []};
  isDub = category == "dub";

  try {
    final response = await http.get(Uri.parse("https://aniVibe.net/$episodeId"));

    if (response.statusCode == 200) {
      final document = parse(response.body);

      // Get all <script> tags from the webpage
      final scriptTags = document.getElementsByTagName('script');
      for (var script in scriptTags) {
        final scriptContent = script.text;

        // Look for scripts containing .m3u8 links
        if (scriptContent.contains('.m3u8')) {
          // Match URLs and type (SUB or DUB)
          final regex = RegExp(r'"type":"(.*?)","url":"(https.*?\.m3u8)"', dotAll: true);
          final matches = regex.allMatches(scriptContent);

          for (var match in matches) {
            final type = match.group(1); // SUB or DUB
            final m3u8Link = match.group(2)?.replaceAll(r'\/', '/'); // Decode slashes

            if (m3u8Link != null) {
              log('Found m3u8 Link: $m3u8Link (Type: $type)');

              if (isDub && type == "DUB") {
                data['sources']?.add({"url": m3u8Link});
                log("Selected Dubbed m3u8 Link: $m3u8Link");
                return data;
              } else if (!isDub && type == "SUB") {
                data['sources']?.add({"url": m3u8Link});
                log("Selected Subbed m3u8 Link: $m3u8Link");
                return data;
              }
            }
          }
        }
      }
    } else {
      log('Failed to load webpage. Status code: ${response.statusCode}');
    }
  } catch (e) {
    log('Error: $e');
  }

  return null;
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
