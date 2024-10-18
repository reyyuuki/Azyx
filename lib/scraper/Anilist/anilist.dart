import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

Future<Map<String, List<Map<String, dynamic>>>> fetchAnilistAnimes() async {
  String url = 'https://graphql.anilist.co/';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Define the GraphQL query to fetch all sections with rating and type
  String query = r'''
  query {
    trending: Page {
      media(type: ANIME, sort: TRENDING_DESC) {
        id
        title {
          romaji
        }
        episodes
        coverImage {
          large
        }
        studios {
          nodes {
            name
          }
        }
        genres
        averageScore
        format
      }
    }
    popular: Page {
      media(type: ANIME, sort: POPULARITY_DESC) {
        id
        title {
          romaji
        }
        episodes
        coverImage {
          large
        }
        studios {
          nodes {
            name
          }
        }
        genres
        averageScore
        format
      }
    }
    latest: Page {
      media(type: ANIME, status: RELEASING, sort: START_DATE_DESC) {
        id
        title {
          romaji
        }
        episodes
        coverImage {
          large
        }
        studios {
          nodes {
            name
          }
        }
        genres
        averageScore
        format
      }
    }
    completed: Page {
      media(type: ANIME, status: FINISHED, sort: END_DATE_DESC) {
        id
        title {
          romaji
        }
        episodes
        coverImage {
          large
        }
        studios {
          nodes {
            name
          }
        }
        genres
        averageScore
        format
      }
    }
  }
  ''';

  // Send the POST request to the AniList GraphQL API
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode({'query': query}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Extract sections into a map
    Map<String, List<Map<String, dynamic>>> sections = {
      'trending': (data['data']['trending']['media'] as List).map((anime) => {
            'id': anime['id'].toString(),
            'name': anime['title']['romaji'],
            'episodes': anime['episodes']?.toString() ?? 'Unknown episodes',
            'poster': anime['coverImage']['large'],
            'studio': (anime['studios']['nodes'] as List).isNotEmpty
                ? anime['studios']['nodes'][0]['name']
                : 'Unknown studio',
            'genres': (anime['genres'] as List).join(', '),
            'rating': anime['averageScore'],
            'type': anime['format'] ?? 'Unknown format',
          }).toList(),
      'popular': (data['data']['popular']['media'] as List).map((anime) => {
            'id': anime['id'].toString(),
            'name': anime['title']['romaji'],
            'episodes': anime['episodes']?.toString() ?? 'Unknown episodes',
            'poster': anime['coverImage']['large'],
            'studio': (anime['studios']['nodes'] as List).isNotEmpty
                ? anime['studios']['nodes'][0]['name']
                : 'Unknown studio',
            'genres': (anime['genres'] as List).join(', '),
            'rating': anime['averageScore'],
            'type': anime['format'] ?? 'Unknown format',
          }).toList(),
      'latest': (data['data']['latest']['media'] as List).map((anime) => {
            'id': anime['id'].toString(),
            'name': anime['title']['romaji'],
            'episodes': anime['episodes']?.toString() ?? 'Unknown episodes',
            'poster': anime['coverImage']['large'],
            'studio': (anime['studios']['nodes'] as List).isNotEmpty
                ? anime['studios']['nodes'][0]['name']
                : 'Unknown studio',
            'genres': (anime['genres'] as List).join(', '),
            'rating': anime['averageScore'],
            'type': anime['format'] ?? 'Unknown format',
          }).toList(),
      'completed': (data['data']['completed']['media'] as List).map((anime) => {
            'id': anime['id'].toString(),
            'name': anime['title']['romaji'],
            'episodes': anime['episodes']?.toString() ?? 'Unknown episodes',
            'poster': anime['coverImage']['large'],
            'studio': (anime['studios']['nodes'] as List).isNotEmpty
                ? anime['studios']['nodes'][0]['name']
                : 'Unknown studio',
            'genres': (anime['genres'] as List).join(', '),
            'rating': anime['averageScore'],
            'type': anime['format'] ?? 'Unknown format',
          }).toList(),
    };
log(sections.toString());
    return sections;
  } else {
    throw Exception('Failed to load data');
  }
}
