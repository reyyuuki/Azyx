import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

class AniListProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  dynamic _userData = {};
  dynamic _anilistData = {};
  dynamic _mangalistData = {};
  bool _isLoading = false;

  dynamic get userData => _userData;
  dynamic get anilistData => _anilistData;
  dynamic get mangalistData => _mangalistData;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {
    _anilistData = await fetchAnilistAnimes();
    _mangalistData = await fetchAnilistManga();
    final token = await storage.read(key: 'auth_token');
    log('auto login $token');
    if (token != null) {
      await fetchUserProfile();
      await fetchUserAnimeList();
      await fetchUserMangaList();
    }

    return log('Auth token not available!');
  }

  Future<void> login(BuildContext context) async {
    String clientId = dotenv.get('CLIENT_ID');
    String clientSecret = dotenv.get('CLIENT_SECRET');
    String redirectUri = dotenv.get('REDIRECT_URL');

    final url =
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';

    try {
      final result = await FlutterWebAuth.authenticate(
        url: url,
        callbackUrlScheme: 'azyx',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code != null) {
        await _exchangeCodeForToken(
            code, clientId, clientSecret, redirectUri, context);
      }
    } catch (e) {
      log('Error during login: $e');
    }
  }

  Future<void> _exchangeCodeForToken(String code, String clientId,
      String clientSecret, String redirectUri, BuildContext context) async {
    final response = await http.post(
      Uri.parse('https://anilist.co/api/v2/oauth/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      await storage.write(key: 'auth_token', value: token);
      log(token);
      await fetchUserProfile();
    } else {
      throw Exception('Failed to exchange code for token: ${response.body}');
    }
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();

    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    const query = '''
  query {
    Viewer {
      id
      name
      avatar {
        large
      }
      statistics {
        anime {
          count
          minutesWatched
          episodesWatched
        }
        manga {
          count
          chaptersRead
        }
      }
    }
  }
  ''';

    final response = await http.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _userData = data['data']['Viewer'];
      log('User profile fetched');
    } else {
      throw Exception('Failed to load user profile');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserAnimeList() async {
    _isLoading = true;
    notifyListeners();

    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    const query = '''
    query GetUserAnimeList(\$userId: Int) {
      MediaListCollection(userId: \$userId, type: ANIME) {
        lists {
          name
          entries {
            media {
              id
              title {
                romaji
                english
                native
              }
              episodes
              format
              genres
              status
              averageScore
              coverImage {
                large
              }
            }
            progress
            status
          }
        }
      }
    }
    ''';

    try {
      if (_userData['id'] == null) {
        log('User ID is not available. Fetching user profile first.');
        await fetchUserProfile();
      }

      final userId = _userData['id'];
      if (userId == null) {
        throw Exception('Failed to get user ID');
      }

      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': query,
          'variables': {
            'userId': userId,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null &&
            data['data']['MediaListCollection'] != null) {
          final lists =
              data['data']['MediaListCollection']['lists'] as List<dynamic>;
          _userData['animeList'] =
              lists.expand((list) => list['entries'] as List<dynamic>).toList();
          log('User anime list fetched successfully');
          log('Fetched ${_userData['animeList'].length} anime entries');
          log(data['data']['MediaListCollection']['lists']);
        } else {
          log('Unexpected response structure: ${response.body}');
        }
      } else {
        log('Fetch failed with status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (e) {
      log('Failed to load anime list: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserMangaList() async {
    _isLoading = true;
    notifyListeners();

    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    const query = '''
    query GetUserMangaList(\$userId: Int) {
      MediaListCollection(userId: \$userId, type: MANGA) {
        lists {
          name
          entries {
            media {
              id
              title {
                romaji
                english
                native
              }
              chapters
              volumes
              format
              genres
              status
              averageScore
              coverImage {
                large
              }
            }
            progress
            status
          }
        }
      }
    }
    ''';

    try {
      if (_userData['id'] == null) {
        log('User ID is not available. Fetching user profile first.');
        await fetchUserProfile();
      }

      final userId = _userData['id'];
      if (userId == null) {
        throw Exception('Failed to get user ID');
      }

      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': query,
          'variables': {
            'userId': userId,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null &&
            data['data']['MediaListCollection'] != null) {
          final lists =
              data['data']['MediaListCollection']['lists'] as List<dynamic>;
          _userData['mangaList'] =
              lists.expand((list) => list['entries'] as List<dynamic>).toList();
          log('User manga list fetched successfully');
          log('Fetched ${_userData['mangaList'].length} manga entries');
        } else {
          log('Unexpected response structure: ${response.body}');
        }
      } else {
        log('Fetch failed with status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (e) {
      log('Failed to load manga list: $e');
    }
    log(userData['mangaList'].toString());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await storage.delete(key: 'auth_token');
    _userData = {};
    notifyListeners();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchAnilistAnimes() async {
    String url = 'https://graphql.anilist.co/';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Define the GraphQL query to fetch all sections with rating, type, and status
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
    latest: Page {
      media(type: ANIME, status: RELEASING, sort: START_DATE_DESC) {
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
    completed: Page {
      media(type: ANIME, status: FINISHED, sort: END_DATE_DESC) {
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
                  'coverImage':{
                    'large': anime['coverImage']['large']
                  },
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                  'description': anime['description'] ?? 'No description available'
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
                  'coverImage':{
                    'large': anime['coverImage']['large']
                  },
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                })
            .toList(),
        'latest': (data['data']['latest']['media'] as List)
            .map((anime) => {
                  'id': anime['id'].toString(),
                  'title': {
                    'english': anime['title']['english'] ?? "Unknown Title",
                    'romaji': anime['title']['romaji'] ?? "Unknown Title",
                    'native': anime['title']['native'] ?? "Unknown Title",
                  },
                  'episodes':
                      anime['episodes']?.toString() ?? 'Unknown episodes',
                  'coverImage':{
                    'large': anime['coverImage']['large']
                  },
                  'studio': (anime['studios']['nodes'] as List).isNotEmpty
                      ? anime['studios']['nodes'][0]['name']
                      : 'Unknown studio',
                  'genres': (anime['genres'] as List).join(', '),
                  'averageScore': anime['averageScore'],
                  'type': anime['format'] ?? 'Unknown format',
                  'status': anime['status'] ?? 'Unknown status',
                })
            .toList(),
        'completed': (data['data']['completed']['media'] as List)
            .map((anime) => {
                  'id': anime['id'].toString(),
                  'title': {
                    'english': anime['title']['english'] ?? "Unknown Title",
                    'romaji': anime['title']['romaji'] ?? "Unknown Title",
                    'native': anime['title']['native'] ?? "Unknown Title",
                  },
                  'episodes':
                      anime['episodes']?.toString() ?? 'Unknown episodes',
                  'coverImage':{
                    'large': anime['coverImage']['large']
                  },
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
      log(sections['popular'].toString());
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
                  'chapters':
                      manga['chapters']?.toString() ?? 'Unknown chapters',
                  'coverImage':{
                    'large': manga['coverImage']['large']
                  },
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
                  'coverImage':{
                    'large': manga['coverImage']['large']
                  },
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
                  'coverImage':{
                    'large': manga['coverImage']['large']
                  },
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
                  'coverImage':{
                    'large': manga['coverImage']['large']
                  },
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
    required String status,
    double? score,
    int? progress,
  }) async {
    const String url = 'https://graphql.anilist.co';
    const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'auth_token');
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    const String mutation = '''
    mutation SaveMediaListEntry(\$mediaId: Int!, \$status: MediaListStatus!, \$score: Float, \$progress: Int) {
      SaveMediaListEntry(mediaId: \$mediaId, status: \$status, score: \$score, progress: \$progress) {
        id
        status
        score
        progress
        media {
          id
          title {
            romaji
            english
          }
        }
      }
    }
  ''';

    final Map<String, dynamic> variables = {
      'mediaId': mediaId,
      'status': status,
      'score': score,
      'progress': progress,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'query': mutation, 'variables': variables}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Successfully added to list: ${data['data']['SaveMediaListEntry']}');
    } else {
      final error = jsonDecode(response.body);
      log('Error adding to list: ${error['errors']}');
    }
    await fetchUserAnimeList();
    await fetchUserMangaList();
  }
}
