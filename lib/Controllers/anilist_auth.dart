import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Classes/anilist_anime_data.dart';
import 'package:azyx/Classes/anilist_user_data.dart';
import 'package:azyx/Classes/user_anime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

final AnilistAuth anilistAuthController = Get.find();

class AnilistAuth extends GetxController {
  Rx<User> userData = User().obs;
  RxList<UserAnime> userAnimeList = RxList<UserAnime>();
  RxList<UserAnime> userMangaList = RxList<UserAnime>();

  Future<void> tryAutoLogin() async {
    final token = await Hive.box("app-data").get("auth_token");
    if (token != null) {
      await fetchUserProfile();
      await fetchUserAnimeList();
      await fetchUserMangaList();
    }

    return log('Auth token not available!');
  }

  Future<void> login() async {
    String clientId = dotenv.get('CLIENT_ID');
    String clientSecret = dotenv.get('CLIENT_SECRET');
    String redirectUri = dotenv.get('REDIRECT_URL');

    final url =
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'azyx',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code != null) {
        await _exchangeCodeForToken(code, clientId, clientSecret, redirectUri);
      }
    } catch (e) {
      log('Error during login: $e');
    }
  }

  Future<void> _exchangeCodeForToken(String code, String clientId,
      String clientSecret, String redirectUri) async {
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
      Hive.box('app-data').put("auth_token", token);
      log(token);
      await fetchUserProfile();
    } else {
      throw Exception('Failed to exchange code for token: ${response.body}');
    }
  }

  Future<void> fetchUserProfile() async {
    final token = await Hive.box("app-data").get("auth_token");
    if (token == null) {
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
      userData.value = User.fromJson(data['data']['Viewer']);
      log('User profile fetched ${data['data']['Viewer']}');
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> fetchUserAnimeList() async {
    final token = await Hive.box("app-data").get("auth_token");
    if (token == null) {
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
      if (userData.value.id == null) {
        log('User ID is not available. Fetching user profile first.');
        await fetchUserProfile();
      }

      final userId = userData.value.id;
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
          userAnimeList.assignAll(
            lists
                .expand((list) => (list['entries'] as List<dynamic>)
                    .map((entry) => UserAnime.fromJson(entry)))
                .toList(),
          );
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
  }

  Future<void> fetchUserMangaList() async {
    final token = await Hive.box("app-data").get("auth_token");
    if (token == null) {
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
      if (userData.value.id == null) {
        log('User ID is not available. Fetching user profile first.');
        await fetchUserProfile();
      }

      final userId = userData.value.id;
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
          userMangaList.assignAll(lists
              .expand((list) => (list['entries'] as List<dynamic>)
                  .map((item) => UserAnime.fromJson(item)))
              .toList());
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
  }

  Future<void> logout() async {
    await Hive.box("app-data").put("auth_token", '');
    userData.value = User();
    userAnimeList.clear();
    userMangaList.clear();
  }

  Future<AnilistAnimeData> fetchAnilistAnimes() async {
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
        bannerImage
        coverImage {
          large
        }
        averageScore
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
        coverImage {
          large
        }
        averageScore
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
        coverImage {
          large
        }
        averageScore
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
        coverImage {
          large
        }
        averageScore
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
      return AnilistAnimeData.fromJson(data['data']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<AnilistAnimeData> fetchAnilistManga() async {
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
        coverImage {
          large
        }
        averageScore
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
        coverImage {
          large
        }
        averageScore
        status
      }
    }
    latestReleasing: Page {
      media(type: MANGA, status: RELEASING, sort: START_DATE_DESC) {
        id
        title {
          english
          romaji
          native
        }
        coverImage {
          large
        }
        averageScore
        status
      }
    }
    recentlyCompleted: Page {
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
        averageScore
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

      return AnilistAnimeData.fromJson(data['data']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> addToAniList({
    required int mediaId,
    String? status,
    double? score,
    int? progress,
  }) async {
    const String url = 'https://graphql.anilist.co';
    final accessToken = await Hive.box("app-data").get("auth_token");
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
      'status': status ?? "CURRENT",
      'score': score ?? 5.0,
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
