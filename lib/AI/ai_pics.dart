import 'dart:convert';

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:http/http.dart' as http;

Future<List<Anime>> getAiRecommendations(bool isManga, int page,
    {bool isAdult = false, String? username}) async {
  final query = username?.trim().toLowerCase();

  Future<List<Anime>> fetchRecommendations() async {
    final url = isManga
        ? 'https://anibrain.ai/api/-/recommender/recs/external-list/super-media-similar?filterCountry=[]&filterFormat=["MANGA"]&filterGenre={}&filterTag={"max":{},"min":{}}&filterRelease=[1930,2025]&filterScore=0&algorithmWeights={"genre":0.3,"setting":0.15,"synopsis":0.4,"theme":0.2}&externalListProvider=AniList&externalListProfileName=$query&mediaType=MANGA&adult=$isAdult&page=$page'
        : 'https://anibrain.ai/api/-/recommender/recs/external-list/super-media-similar?filterCountry=[]&filterFormat=[]&filterGenre={}&filterTag={"max":{},"min":{}}&filterRelease=[1917,2025]&filterScore=0&algorithmWeights={"genre":0.3,"setting":0.15,"synopsis":0.4,"theme":0.2}&externalListProvider=AniList&externalListProfileName=$query&mediaType=ANIME&adult=$isAdult&page=$page';

    final resp = await http.get(Uri.parse(url));

    if (resp.statusCode == 200) {
      final document = jsonDecode(resp.body);
      final recItems = document['data'];

      return recItems.map<Anime>((item) {
        final title = item['titleEnglish'] ?? item['titleRomaji'];
        final imageUrl = item['imgURLs'][0];
        final synopsis = item['description'];
        final id = item['anilistId'];
        return Anime(
            id: id,
            title: title,
            image: imageUrl,
            description: synopsis,
            genres: (item['genres'] as List)
                .map((genre) => genre.toString().trim().toUpperCase())
                .toList());
      }).toList();
    }
    return [];
  }

  List<Anime> recommendations = await fetchRecommendations();

  if (recommendations.isEmpty) {
    azyxSnackBar("Syncing Your List...");
    recommendations = await fetchRecommendations();
  }

  if (recommendations.isEmpty) {
    azyxSnackBar('Error Occurred!');
  }

  return recommendations;
}
