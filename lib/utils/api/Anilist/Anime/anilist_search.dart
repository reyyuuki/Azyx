// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

const String GRAPHQL_ENDPOINT = 'https://graphql.anilist.co';

Future<List<Map<String, dynamic>>> searchAnilistAnime(String query) async {
  const String searchQuery = '''
    query (\$search: String) {
      Page(perPage: 30) {
        media(search: \$search, type: ANIME) {
          id
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          bannerImage
          averageScore
          episodes
          season
          seasonYear
          type
          status
        }
      }
    }
  ''';

  try {
    final response = await http.post(
      Uri.parse(GRAPHQL_ENDPOINT),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "query": searchQuery,
        "variables": {"search": query},
      }),
    );

    log('Request to AniList: search=$query, statusCode=${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final animeList = data['data']['Page']['media'] as List<dynamic>;

      log(animeList.toString());
      return animeList.map<Map<String, dynamic>>((anime) {
        return {
          'id': anime['id'],
          'name': anime['title']['english'] ??
              anime['title']['romaji'] ??
              "Unkown Anime",
          'poster': anime['coverImage']['large'],
          'cover': anime['bannerImage'],
          'averageScore': anime['averageScore'],
          'episodes': anime['episodes'].toString(),
          'season': anime['season'],
          'seasonYear': anime['seasonYear'],
          'type' : anime['type'],
          'status': anime['status']
        };
      }).toList();
    } else {
      log('Error response: ${response.body}');
      throw Exception('Failed to search anime: ${response.body}');
    }
  } catch (error) {
    log('Exception: $error');
    throw Exception('Failed to search anime: $error');
  }
}
