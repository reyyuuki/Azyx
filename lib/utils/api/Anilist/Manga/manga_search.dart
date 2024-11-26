// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

const String GRAPHQL_ENDPOINT = 'https://graphql.anilist.co';

Future<List<Map<String, dynamic>>> searchAnilistManga(String query) async {
  const String searchQuery = '''
    query (\$search: String) {
      Page(perPage: 30) {
        media(search: \$search, type: MANGA) {
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
          chapters
          volumes
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
      final mangaList = data['data']['Page']['media'] as List<dynamic>;

      log(mangaList.toString());
      return mangaList.map<Map<String, dynamic>>((manga) {
        return {
          'id': manga['id'],
          'name': manga['title']['english'] ??
              manga['title']['romaji'] ??
              "Unknown Manga",
          'poster': manga['coverImage']['large'],
          'cover': manga['bannerImage'],
          'averageScore': manga['averageScore'],
          'chapters': manga['chapters']?.toString() ?? 'N/A',
          'volumes': manga['volumes']?.toString() ?? 'N/A',
          'type': manga['type'],
          'status': manga['status'],
        };
      }).toList();
    } else {
      log('Error response: ${response.body}');
      throw Exception('Failed to search manga: ${response.body}');
    }
  } catch (error) {
    log('Exception: $error');
    throw Exception('Failed to search manga: $error');
  }
}
