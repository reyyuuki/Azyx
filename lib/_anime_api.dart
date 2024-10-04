import 'dart:convert';
import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

var box = Hive.box("app-data");
bool isConsumet = box.get("isConsumet", defaultValue: false);
const String proxy = "https://goodproxy.goodproxy.workers.dev/fetch?url=";
const aniwatchUrl = "https://aniwatch-ryan.vercel.app/anime";
const consumetUrl = "https://consumet-api-two-nu.vercel.app/meta/anilist/";

Future<dynamic> fetchHomePageData() async {
  try {
    final response = await http.get(Uri.parse('$proxy$aniwatchUrl/home'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  } catch (error) {
    log('$error');
    return;
  }
}

Future<dynamic> consumetHomePageData() async {
  dynamic data = {};

  try {
    final spotlightAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/trending'));
    final trendingAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/trending?page=2'));
    final latestEpisodesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/advanced-search?sort=["EPISODES"]'));
    final topUpcomingAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/advanced-search?status=NOT_YET_RELEASED'));
    final topAiringAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/trending?page=3'));
    final mostPopularAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/popular'));
    final mostFavouriteAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/popular?page=2'));
    final latestCompletedAnimesResponse = await http.get(Uri.parse(
        '${proxy}https://consumet-api-two-nu.vercel.app/meta/anilist/advanced-search?year=2024&status=FINISHED'));

    if (spotlightAnimesResponse.statusCode == 200) {
      data['spotlightAnimes'] =
          jsonDecode(spotlightAnimesResponse.body)['results'];
    }
    if (trendingAnimesResponse.statusCode == 200) {
      data['trendingAnimes'] =
          jsonDecode(trendingAnimesResponse.body)['results'];
    }
    if (latestEpisodesResponse.statusCode == 200) {
      data['latestEpisodesAnimes'] =
          jsonDecode(latestEpisodesResponse.body)['results'];
    }
    if (topUpcomingAnimesResponse.statusCode == 200) {
      data['topUpcomingAnimes'] =
          jsonDecode(topUpcomingAnimesResponse.body)['results'];
    }
    if (topAiringAnimesResponse.statusCode == 200) {
      data['topAiringAnimes'] =
          jsonDecode(topAiringAnimesResponse.body)['results'];
    }
    if (mostPopularAnimesResponse.statusCode == 200) {
      data['mostPopularAnimes'] =
          jsonDecode(mostPopularAnimesResponse.body)['results'];
    }
    if (mostFavouriteAnimesResponse.statusCode == 200) {
      data['mostFavouriteAnimes'] =
          jsonDecode(mostFavouriteAnimesResponse.body)['results'];
    }
    if (latestCompletedAnimesResponse.statusCode == 200) {
      data['latestCompletedAnimes'] =
          jsonDecode(latestCompletedAnimesResponse.body)['results'];
    }
    if (spotlightAnimesResponse.statusCode == 200 &&
        topAiringAnimesResponse.statusCode == 200 &&
        trendingAnimesResponse.statusCode == 200) {
      final today = jsonDecode(spotlightAnimesResponse.body);
      final week = jsonDecode(trendingAnimesResponse.body);
      final month = jsonDecode(topAiringAnimesResponse.body);
      data['top10Animes'] = {
        // 'today': extractData(today['results']),
        // 'week': extractData(week['results']),
        // 'month': extractData(month['results']),
      };
    }
  } catch (e) {
    log('Error fetching data from Consumet API: $e');
  }

  return data;
}

Future<dynamic>? fetchAnimeDetailsConsumet(String id) async {
  try {
    final resp = await http.get(Uri.parse('$proxy${consumetUrl}info/$id'));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data;
    } else {
      log('Failed to fetch data: ${resp.statusCode}');
      return null;
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<dynamic> fetchAnimeDetailsAniwatch(String id) async {
  try {
    final resp = await http.get(Uri.parse('$proxy${aniwatchUrl}info?id=$id'));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data;
    } else {
      log('Failed to fetch data: ${resp.statusCode}');
      return null;
    }
  } catch (e) {
    log('Error fetching anime details: $e');
    return null;
  }
}

Future<dynamic>? fetchSearchesAniwatch(String id) async {}
Future<dynamic>? fetchSearchesConsumet(String id) async {}
Future<dynamic>? fetchStreamingDataConsumet(String id) async {
  final resp = await http.get(Uri.parse('$proxy${consumetUrl}episodes/$id'));
  if (resp.statusCode == 200) {
    final tempData = jsonDecode(resp.body);
    return tempData;
  }
}

Future<dynamic>? fetchStreamingDataAniwatch(String id) async {
  final resp = await http.get(Uri.parse('$proxy${aniwatchUrl}episodes/$id'));
  if (resp.statusCode == 200) {
    final tempData = jsonDecode(resp.body);
    return tempData;
  }
}

Future<dynamic> fetchStreamingLinksAniwatch(String id) async {
  try {
    final url = '${aniwatchUrl}episode-srcs?id=$id';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final tempData = jsonDecode(resp.body);
      return tempData;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<dynamic>? fetchStreamingLinksConsumet(String id) async {
  final resp = await http.get(Uri.parse('$proxy${consumetUrl}watch/$id'));
  if (resp.statusCode == 200) {
    final tempData = jsonDecode(resp.body);
    return tempData;
  }
}



// dynamic extractData(dynamic results) {
//   // bool isConsumet = Hive.box("app-data").get("isConsumet");
//   bool isConsumet = true;
//   if (results != null) {
//     dynamic items = [];
//     for (var result in results) {
//       String id = "";
//       String name = "Unknown";
//       String poster = "";
//       String description = "";
//       dynamic otherInfo = [];
//       String coverImage = "";
//       String type = "";
//       List<dynamic> genres = [];
//       dynamic totalEpisodes = "";

//       if (isConsumet) {
//         id = result["id"] ?? "";
//         name = result["title"]["english"] ??
//             result["title"]["romaji"] ??
//             result["title"]["native"] ??
//             "Unknown";
//         poster = result["image"] ?? "";
//         otherInfo = [
//           result["type"],
//           result["releaseDate"],
//           "HD",
//           result["rating"]
//         ];
//         genres = result["genres"];
//         description = result["description"] ?? "??";
//         coverImage = result["cover"] ?? "";
//         totalEpisodes = result["totalEpisodes"] ?? "??";
//       } else {
//         id = result["id"];
//         name = result["name"] ?? result["jname"] ?? "Unknown";
//         poster = result["poster"];
//         otherInfo = result["otherInfo"] ?? ["??", "??", "??", "??"];
//         description = result["description"] ?? "??";
//         totalEpisodes = result["episodes"];
//       }
//       items.add({
//         'id': id,
//         'name': name,
//         'poster': poster,
//         'otherInfo': otherInfo,
//         'description': description,
//         'cover': coverImage,
//         'type': type,
//       });
      
//     }
//     return items;
//   }
//   else{
//     return;
//   }
// }


Future extractLinks(imageClass, titleClass, idClass) async {
  const url = 'https://hianime.to/home'; 

  final response = await http.Client().get(Uri.parse(url));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);

    try {
      dynamic items = [];

      var imageElements = document.getElementsByClassName(imageClass);
      var titleElements = document.getElementsByClassName(titleClass);
      var idElements = document.getElementsByClassName(idClass);
    
       int itemCount = imageElements.length < titleElements.length
          ? imageElements.length
          : titleElements.length;
      
      for (var i = 0; i < itemCount; i++) {
        String? imagelink = imageElements[i].children[0].attributes['data-src']; 
        String title = titleElements[i].children[1].text.trim();
        String? id = idElements[i].attributes['href'];

        if (imagelink != null && id != null) {
          items.add({
            'name': title,
            'poster': imagelink,
            'id': id,
            'rank': i + 1,
          });
        }
      }

      return items;
    } catch (e) {
      log('Error: $e');
    }
  } else {
    log('Failed to load website: Status code ${response.statusCode}');
    return [{'error': 'ERROR: ${response.statusCode}.'}];
  }
}


Future<Map<String, dynamic>?> scrapDetail(String id) async {
  String url = "https://hianime.to/$id";

  final response = await http.Client().get(Uri.parse(url));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);

    try {
      var imageElement = document.getElementsByClassName('film-poster')[0].children[0].attributes['src'];
      var details = document.getElementsByClassName("anisc-info")[0];
      var info = document.getElementsByClassName("tick")[0];

      String jname = details.children[1].children[1].text.trim();
      String name = document.getElementsByClassName("film-name")[0].text.trim();
      String aired = details.children[3].children[1].text.trim();
      String premeired = details.children[4].children[1].text.trim();
      String duration = details.children[5].children[1].text.trim();
      String status = details.children[6].children[1].text.trim();
      String malScore = details.children[7].children[1].text.trim();
      String studio = details.children[9].children[1].text.trim();
      String producers = details.children[10].children[1].text.trim();
      String description = document.getElementsByClassName("film-description")[0].children[0].text.trim();
      String rating = info.children[0].text.trim();
      String quality = info.children[1].text.trim();
      String sub = info.children[2].text.trim();
      String dub = info.children[3].text.trim();

      List<String> genres = [];
      var genreElements = document.getElementsByClassName('item-list')[0].getElementsByTagName('a');
      for (var genre in genreElements) {
        String? title = genre.text.trim();
        if (title.isNotEmpty) {
          genres.add(title);
        }
      }

      var item = {
        'poster': imageElement,
        'jname': jname,
        'name': name,
        'aired': aired,
        'premiered': premeired,
        'duration': duration,
        'status': status,
        'malscore': malScore,
        'genres': genres,
        'description': description,
        'producer': producers,
        'studio': studio,
        'rating': rating,
        'quality': quality,
        'sub': sub.toString(),
        'dub': dub.toString(),
      };

      log("Scraped: $item");
      return item;
    } catch (e) {
      print('Error scraping details: $e');
      return null; 
    }
  } else {
    print('Request failed with status: ${response.statusCode}');
    return null; 
  }
}