// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/models/online_service.dart';
import 'package:azyx/Models/anilist_anime_data.dart';
import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/params.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Models/user_lists_model.dart';
import 'package:azyx/Screens/Anime/anime_screen.dart';
import 'package:azyx/Screens/search/search_screen.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/main_carousale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

final AnilistService anilistAuthController = Get.find();

class AnilistService extends GetxController
    implements BaseService, OnlineService {
  @override
  Rx<User> userData = User().obs;
  Rx<MediaData> animeData = Rx(MediaData());
  Rx<MediaData> mangaData = Rx(MediaData());
  @override
  Rx<UserListsModel> userAnimeList = UserListsModel().obs;
  @override
  Rx<UserListsModel> userMangaList = UserListsModel().obs;

  RxList<Anime> spotlight = RxList();
  RxList<Anime> popular = RxList();
  RxList<Anime> trending = RxList();
  RxList<Anime> topUpcoming = RxList();

  // Manga
  RxList<Anime> spotlightM = RxList();
  RxList<Anime> popularM = RxList();
  RxList<Anime> trendingM = RxList();
  RxList<Anime> topUpcomingM = RxList();

  // @override
  // void onInit() {
  //   super.onInit();
  //   tryAutoLogin();
  // }

  Future<void> tryAutoLogin() async {
    final token = await Hive.box("app-data").get("auth_token");
    if (token != null) {
      await fetchUserProfile();
    }

    return log('Auth token not available!');
  }

  @override
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
    await fetchUserAnimeList();
    await fetchUserMangaList();
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
            score
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
          userAnimeList.value = UserListsModel.fromJson(lists);
          // userAnimeList.assignAll(
          //   lists
          //       .expand((list) => (list['entries'] as List<dynamic>)
          //           .map((entry) => UserAnime.fromJson(entry)))
          //       .toList(),
          // );
          // log("test: ${lists.toString()}");
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
          userMangaList.value = UserListsModel.fromJson(lists);
          // userMangaList.assignAll(lists
          //     .expand((list) => (list['entries'] as List<dynamic>)
          //         .map((item) => UserAnime.fromJson(item)))
          //     .toList());
          // log("manga data: $lists");
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

  @override
  Future<void> logout() async {
    await Hive.box("app-data").put("auth_token", '');
    userData.value = User();
    userAnimeList.value.allList.clear();
    userMangaList.value.allList.clear();
  }

  Future<void> fetchAnilistAnimes() async {
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
        type
        episodes
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
      spotlight.value = (data['data']['trending']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList();
      popular.value = (data['data']['popular']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList();
      topUpcoming.value =
          (data['data']['latestReleasing']['media'] as List<dynamic>)
              .map((item) => Anime.fromJson(item))
              .toList();
      trending.value =
          (data['data']['recentlyCompleted']['media'] as List<dynamic>)
              .map((item) => Anime.fromJson(item))
              .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAnilistManga() async {
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
        type
        chapters
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
    media(type: MANGA, status: FINISHED, sort: END_DATE_DESC, isAdult: false) {
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
      spotlightM.value = (data['data']['trending']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList();
      popularM.value = (data['data']['popular']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList();
      topUpcomingM.value =
          (data['data']['latestReleasing']['media'] as List<dynamic>)
              .map((item) => Anime.fromJson(item))
              .toList();
      trendingM.value =
          (data['data']['recentlyCompleted']['media'] as List<dynamic>)
              .map((item) => Anime.fromJson(item))
              .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<void> updateEntry(UserAnime anime,
      {required bool isAnime, String? syncId}) async {
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
      'mediaId': anime.id,
      'status': anime.status ?? "CURRENT",
      if (anime.score != null) 'score': anime.score,
      if (anime.progress != null) 'progress': anime.progress,
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

  @override
  Rx<Widget> animeWidgets(BuildContext context) {
    return Obx(
      () => spotlight.isEmpty ||
              popular.isEmpty ||
              trending.isEmpty ||
              topUpcoming.isEmpty
          ? Container(
              alignment: Alignment.center,
              height: Get.height * 0.8,
              child: const CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: ListView(
                  padding: const EdgeInsets.all(10),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    buildSearchButton(
                        context,
                        () => Get.to(() => const SearchScreen(isManga: false)),
                        false),
                    const SizedBox(height: 10),
                    MainCarousale(isManga: false, data: spotlight),
                    const SizedBox(height: 20),
                    AnimeScrollableList(
                      animeList: popular,
                      isManga: false,
                      title: "Popular Animes",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AnimeScrollableList(
                      animeList: topUpcoming,
                      isManga: false,
                      title: "TopUpcoming Animes",
                    ),
                    const SizedBox(height: 10),
                    AnimeScrollableList(
                      animeList: trending,
                      isManga: false,
                      title: "Completed Animes",
                    ),
                  ]),
            ),
    ).obs;
  }

  @override
  Future<void> autoLogin() {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEntry(String entry, {required bool isAnime}) {
    throw UnimplementedError();
  }

  @override
  Future<AnilistMediaData> fetchAnimeDetails(int id) async {
    final data = await anilistDataController.fetchAnilistAnimeDetails(id);
    return data;
  }

  @override
  Future<AnilistMediaData> fetchMangaDetails(int id) async {
    final data = await anilistDataController.fetchAnilistMangaDetails(id);
    return data;
  }

  @override
  Future<void> fetchhomeData() async {
    await fetchAnilistAnimes();
    await fetchAnilistManga();
  }

  @override
  Future<List<Anime>> fetchsearchData(SearchParams query) {
    throw UnimplementedError();
  }

  @override
  RxList<Widget> homeWidgets(BuildContext context) => [
        topUpcoming.value.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : AnimeScrollableList(
                animeList: topUpcoming,
                isManga: false,
                title: "Upcoming Animes",
              ),
        trendingM.value.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : AnimeScrollableList(
                animeList: trendingM,
                isManga: true,
                title: "Trending Manga",
              ),
      ].obs;

  @override
  RxList<Widget> mangaWidgets(BuildContext context) => [
        buildSearchButton(context, () {
          Get.to(() => const SearchScreen(
                isManga: true,
              ));
        }, true),
        const SizedBox(
          height: 10,
        ),
        MainCarousale(isManga: true, data: spotlightM),
        const SizedBox(
          height: 20,
        ),
        const SizedBox(
          height: 10,
        ),
        AnimeScrollableList(
          animeList: popularM,
          isManga: true,
          title: "Popular Manga",
        ),
        const SizedBox(
          height: 10,
        ),
        AnimeScrollableList(
          animeList: topUpcomingM,
          isManga: true,
          title: "TopUpcoming Manga",
        ),
        const SizedBox(height: 10),
        AnimeScrollableList(
          animeList: trendingM,
          isManga: true,
          title: "Completed Manga",
        ),
      ].obs;

  @override
  Future<void> refresh() async {
    Future.wait([
      fetchhomeData(),
      fetchUserAnimeList(),
      fetchUserMangaList(),
    ]);
  }
}
