import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AniListProvider with ChangeNotifier {
  dynamic _userData = {};
  dynamic _anilistData = {};
  dynamic _mangalistData = {};
  bool _isLoading = false;
  dynamic _favorites = {};

  dynamic get userData => _userData;
  dynamic get favorites => _favorites;
  dynamic get anilistData => _anilistData;
  dynamic get mangalistData => _mangalistData;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {}

  Future<void> login(BuildContext context) async {}

  Future<void> _exchangeCodeForToken(String code, String clientId,
      String clientSecret, String redirectUri, BuildContext context) async {}

  Future<void> fetchUserProfile() async {}

  Future<void> fetchUserAnimeList() async {}

  Future<void> fetchUserMangaList() async {}

  Future<void> logout(BuildContext context) async {}

  Future<Map<String, List<Map<String, dynamic>>>> fetchAnilistAnimes() async {
    String url = 'https://graphql.anilist.co/';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    String query = r'''
  query {
    trending: Page {
      media(type: ANIME, sort: TRENDING_DESC) {
        id
        title {
          english
          romaji
          native
        }
        description
        episodes
        bannerImage
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
        status
      }
    }
    popular: Page {
      media(type: ANIME, sort: POPULARITY_DESC) {
        id
        title {
          english
          romaji
          native
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
        status
      }
    }
    latestReleasing: Page {
      media(type: ANIME, status: RELEASING, sort: START_DATE_DESC, isAdult: false) {
        id
        title {
          english
          romaji
          native
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
        status
      }
    }
    recentlyCompleted: Page {
      media(type: ANIME, status: FINISHED, sort: END_DATE_DESC, isAdult: false) {
        id
        title {
          english
          romaji
          native
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
        status
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
        'trending': (data['data']['trending']['media'] as List)
            .map((anime) => {
                  'id': anime['id'].toString(),
                  'title': {
                    'english': anime['title']['english'] ?? "Unknown Title",
                    'romaji': anime['title']['romaji'] ?? "Unknown Title",
                    'native': anime['title']['native'] ?? "Unknown Title",
                  },
                  'bannerImage': anime['bannerImage'],
                  'episodes':
                      anime['episodes']?.toString() ?? 'Unknown episodes',
                  'coverImage': {'large': anime['coverImage']['large']},
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                  'description':
                      anime['description'] ?? 'No description available'
                })
            .toList(),
        'popular': (data['data']['popular']['media'] as List)
            .map((anime) => {
                  'id': anime['id'].toString(),
                  'title': {
                    'english': anime['title']['english'] ?? "Unknown Title",
                    'romaji': anime['title']['romaji'] ?? "Unknown Title",
                    'native': anime['title']['native'] ?? "Unknown Title",
                  },
                  'episodes':
                      anime['episodes']?.toString() ?? 'Unknown episodes',
                  'coverImage': {'large': anime['coverImage']['large']},
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                })
            .toList(),
        'latest': (data['data']['latestReleasing']['media'] as List)
            .map((anime) => {
                  'id': anime['id'].toString(),
                  'title': {
                    'english': anime['title']['english'] ?? "Unknown Title",
                    'romaji': anime['title']['romaji'] ?? "Unknown Title",
                    'native': anime['title']['native'] ?? "Unknown Title",
                  },
                  'episodes':
                      anime['episodes']?.toString() ?? 'Unknown episodes',
                  'coverImage': {'large': anime['coverImage']['large']},
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                })
            .toList(),
        'completed': (data['data']['recentlyCompleted']['media'] as List)
            .map((anime) => {
                  'id': anime['id'].toString(),
                  'title': {
                    'english': anime['title']['english'] ?? "Unknown Title",
                    'romaji': anime['title']['romaji'] ?? "Unknown Title",
                    'native': anime['title']['native'] ?? "Unknown Title",
                  },
                  'episodes':
                      anime['episodes']?.toString() ?? 'Unknown episodes',
                  'coverImage': {'large': anime['coverImage']['large']},
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                })
            .toList(),
      };

      notifyListeners();
      return sections;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchAnilistManga() async {
    String url = 'https://graphql.anilist.co/';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String query = r'''
  query {
    trending: Page {
      media(type: MANGA, sort: TRENDING_DESC) {
        id
        title {
          english
          romaji
          native
        }
        description
        chapters
        coverImage {
          large
        }
        staff {
          nodes {
            name {
              full
            }
          }
        }
        genres
        averageScore
        format
        status
      }
    }
    popular: Page {
      media(type: MANGA, sort: POPULARITY_DESC) {
        id
        title {
          english
          romaji
          native
        }
        chapters
        coverImage {
          large
        }
        staff {
          nodes {
            name {
              full
            }
          }
        }
        genres
        averageScore
        format
        status
      }
    }
    latest: Page {
      media(type: MANGA, status: RELEASING, sort: START_DATE_DESC) {
        id
        title {
          english
          romaji
          native
        }
        chapters
        coverImage {
          large
        }
        staff {
          nodes {
            name {
              full
            }
          }
        }
        genres
        averageScore
        format
        status
      }
    }
    completed: Page {
      media(type: MANGA, status: FINISHED, sort: END_DATE_DESC) {
        id
        title {
          english
          romaji
          native
        }
        chapters
        coverImage {
          large
        }
        staff {
          nodes {
            name {
              full
            }
          }
        }
        genres
        averageScore
        format
        status
      }
    }
  }
  ''';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      Map<String, List<Map<String, dynamic>>> sections = {
        'trending': (data['data']['trending']['media'] as List)
            .map((manga) => {
                  'id': manga['id'].toString(),
                  'title': {
                    'english': manga['title']['english'] ?? "Unknown Title",
                    'romaji': manga['title']['romaji'] ?? "Unknown Title",
                    'native': manga['title']['native'] ?? "Unknown Title",
                  },
                  'description': manga['ddescription'] ?? "N/A",
                  'chapters':
                      manga['chapters']?.toString() ?? 'Unknown chapters',
                  'coverImage': {'large': manga['coverImage']['large']},
                  'author': (manga['staff']['nodes'] as List).isNotEmpty
                      ? manga['staff']['nodes'][0]['name']['full']
                      : 'Unknown author',
                  'genres': (manga['genres'] as List).join(', '),
                  'averageScore': manga['averageScore'],
                  'type': manga['format'] ?? 'Unknown format',
                  'status': manga['status'] ?? 'Unknown status',
                })
            .toList(),
        'popular': (data['data']['popular']['media'] as List)
            .map((manga) => {
                  'id': manga['id'].toString(),
                  'title': {
                    'english': manga['title']['english'] ?? "Unknown Title",
                    'romaji': manga['title']['romaji'] ?? "Unknown Title",
                    'native': manga['title']['native'] ?? "Unknown Title",
                  },
                  'chapters':
                      manga['chapters']?.toString() ?? 'Unknown chapters',
                  'coverImage': {'large': manga['coverImage']['large']},
                  'author': (manga['staff']['nodes'] as List).isNotEmpty
                      ? manga['staff']['nodes'][0]['name']['full']
                      : 'Unknown author',
                  'genres': (manga['genres'] as List).join(', '),
                  'averageScore': manga['averageScore'],
                  'type': manga['format'] ?? 'Unknown',
                  'status': manga['status'] ?? 'Unknown',
                })
            .toList(),
        'latest': (data['data']['latest']['media'] as List)
            .map((manga) => {
                  'id': manga['id'].toString(),
                  'title': {
                    'english': manga['title']['english'] ?? "Unknown Title",
                    'romaji': manga['title']['romaji'] ?? "Unknown Title",
                    'native': manga['title']['native'] ?? "Unknown Title",
                  },
                  'chapters':
                      manga['chapters']?.toString() ?? 'Unknown chapters',
                  'coverImage': {'large': manga['coverImage']['large']},
                  'author': (manga['staff']['nodes'] as List).isNotEmpty
                      ? manga['staff']['nodes'][0]['name']['full']
                      : 'Unknown author',
                  'genres': (manga['genres'] as List).join(', '),
                  'averageScore': manga['averageScore'],
                  'type': manga['format'] ?? 'Unknown',
                  'status': manga['status'] ?? 'Unknown',
                })
            .toList(),
        'completed': (data['data']['completed']['media'] as List)
            .map((manga) => {
                  'id': manga['id'].toString(),
                  'title': {
                    'english': manga['title']['english'] ?? "Unknown Title",
                    'romaji': manga['title']['romaji'] ?? "Unknown Title",
                    'native': manga['title']['native'] ?? "Unknown Title",
                  },
                  'chapters':
                      manga['chapters']?.toString() ?? 'Unknown chapters',
                  'coverImage': {'large': manga['coverImage']['large']},
                  'author': (manga['staff']['nodes'] as List).isNotEmpty
                      ? manga['staff']['nodes'][0]['name']['full']
                      : 'Unknown author',
                  'genres': (manga['genres'] as List).join(', '),
                  'averageScore': manga['averageScore'],
                  'type': manga['format'] ?? 'Unknown',
                  'status': manga['status'] ?? 'Unknown',
                })
            .toList(),
      };
      notifyListeners();
      return sections;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> addToAniList({
    required int mediaId,
    String? status,
    double? score,
    int? progress,
  }) async {}

  Future<void> fetchAniListFavorites() async {}

  Future<bool> addFavorite(int mediaId, String type) async {
    return true;
  }

}
