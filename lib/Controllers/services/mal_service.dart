// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/models/online_service.dart';
import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/params.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Screens/Anime/anime_screen.dart';
import 'package:azyx/Screens/search/search_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/main_carousale.dart';
import 'package:azyx/Widgets/common_cards.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/functions.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'dart:math' as show;

final MalService malService = Get.find<MalService>();

class MalService extends GetxController implements BaseService, OnlineService {
  final storage = Hive.box('auth');

  // Anime
  RxList<Anime> spotlight = RxList();
  RxList<Anime> popular = RxList();
  RxList<Anime> trending = RxList();
  RxList<Anime> topUpcoming = RxList();

  // Manga
  RxList<Anime> spotlightM = RxList();
  RxList<Anime> popularM = RxList();
  RxList<Anime> trendingM = RxList();
  RxList<Anime> topUpcomingM = RxList();

  @override
  Rx<UserAnime> currentMedia = UserAnime().obs;

  @override
  RxBool isLoggedIn = false.obs;

  @override
  Future<void> autoLogin() async {
    try {
      final token = await storage.get('mal_auth_token');
      final refreshToken = await storage.get('mal_refresh_token');

      if (token != null) {
        final isValid = await _validateToken(token);
        if (isValid) {
          log(
            "Auto-login successful with existing token. $token /// $refreshToken",
          );
          await fetchUserInfo(token: token);
          return;
        }
      }

      if (refreshToken != null) {
        await _refreshTokenWithMAL(refreshToken);
      } else {
        log("No valid tokens found. User needs to log in again.");
      }
    } catch (e) {
      log("Auto-login failed: $e");
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await get(
        Uri.parse('https://api.myanimelist.net/v2/users/@me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      log("Token validation failed: $e");
      return false;
    }
  }

  Future<void> _refreshTokenWithMAL(String refreshToken) async {
    final clientId = dotenv.env['MAL_CLIENT_ID'] ?? '';
    final clientSecret = dotenv.env['MAL_CLIENT_SECRET'] ?? '';

    final response = await post(
      Uri.parse('https://myanimelist.net/v1/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newToken = data['access_token'];
      final newRefreshToken = data['refresh_token'];

      await storage.put('mal_auth_token', newToken);
      if (newRefreshToken != null) {
        await storage.put('mal_refresh_token', newRefreshToken);
      }

      log("Token refreshed successfully.");
      await fetchUserInfo(token: newToken);
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  @override
  Future<void> login() async {
    String clientId = dotenv.get("MAL_CLIENT_ID");
    String secret = dotenv.get("MAL_CLIENT_SECRET");
    final secureRandom = show.Random.secure();
    final codeVerifierBytes = List<int>.generate(
      96,
      (_) => secureRandom.nextInt(256),
    );
    final codeChallenge = base64UrlEncode(
      codeVerifierBytes,
    ).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
    final url =
        'https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=$clientId&code_challenge=$codeChallenge';
    try {
      final authCode = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'azyx',
      );
      log(authCode.toString());
      final code = Uri.parse(authCode).queryParameters['code'];
      if (code != null) {
        log("Authorization code: $code");
        await _exchangeCodeForTokenMAL(code, clientId, codeChallenge, secret);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _exchangeCodeForTokenMAL(
    String code,
    String clientId,
    String codeVerifier,
    String secret,
  ) async {
    final response = await post(
      Uri.parse('https://myanimelist.net/v1/oauth2/token'),
      body: {
        'client_id': clientId,
        'code': code,
        'client_secret': secret,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      final refreshToken = data['refresh_token'];

      await storage.put('mal_auth_token', token);
      if (refreshToken != null) {
        await storage.put('mal_refresh_token', refreshToken);
      }

      log("MAL Access token: $token");
      await fetchUserInfo();
      log("Login Succesfull!");
    } else {
      throw Exception(
        'Failed to exchange code for token: ${response.body}, ${response.statusCode}',
      );
    }
  }

  Future<dynamic> fetchMAL(
    String url, {
    bool auth = false,
    bool useAuthHeader = false,
    String? token,
  }) async {
    try {
      final clientId = dotenv.env['MAL_CLIENT_ID'];
      if (clientId == null || clientId.isEmpty) {
        throw Exception('MAL_CLIENT_ID is not set in .env file.');
      }
      final tokenn = token ?? await storage.get('mal_auth_token');
      final response = await get(
        Uri.parse(url),
        headers: useAuthHeader
            ? {'Authorization': 'Bearer $tokenn'}
            : {'X-MAL-CLIENT-ID': clientId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (auth) {
          final rep = await get(
            Uri.parse('https://api.jikan.moe/v4/users/${data['name']}/full'),
          );
          return jsonDecode(rep.body)..['picture'] = data['picture'];
        }
        return data;
      } else {
        log('Failed to fetch data from $url: ${response.statusCode}');
        throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      log('Error fetching data from API: $e', error: e);
      return [];
    }
  }

  static const field = "fields=mean,status,media_type,synopsis";
  Future<List<Anime>> fetchDataFromApi(
    String url, {
    String? customFields,
  }) async {
    final newField = customFields ?? field;
    final data = await fetchMAL('$url&$newField') as Map<String, dynamic>;

    return (data['data'] as List<dynamic>)
        .map((e) => Anime.fromMAL(e))
        .toList();
  }

  Future<String?> fetchBanner(int malId) async {
    final response = await get(
      Uri.parse('https://api.jikan.moe/v4/anime/$malId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['images']['jpg']['large_image_url'];
    }
    return null;
  }

  @override
  Rx<Widget> animeWidgets(BuildContext context) {
    return Obx(
      () =>
          spotlight.isEmpty ||
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
                    'anime',
                  ),
                  const SizedBox(height: 10),
                  MainCarousale(isManga: false, data: spotlight),
                  const SizedBox(height: 20),
                  AnimeScrollableList(
                    animeList: popular,
                    isManga: false,
                    title: "Popular Animes",
                  ),
                  const SizedBox(height: 10),
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
                ],
              ),
            ),
    ).obs;
  }

  @override
  Future<AnilistMediaData> fetchDetails(FetchDetailsParams params) async {
    try {
      final animeData = await fetchWithToken(
        'https://api.myanimelist.net/v2/${params.isManga ? 'manga' : 'anime'}/${params.id}',
      );
      return animeData;
    } catch (e) {
      return AnilistMediaData();
    }
  }

  @override
  Future<void> fetchhomeData() async {
    try {
      spotlight.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/anime/ranking?ranking_type=airing&limit=15',
      );
      popular.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/anime/ranking?ranking_type=bypopularity&limit=15',
      );
      trending.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/anime/ranking?ranking_type=tv&limit=15',
      );
      topUpcoming.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/anime/ranking?ranking_type=upcoming&limit=15',
      );

      spotlightM.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/manga/ranking?ranking_type=all&limit=15',
      );
      popularM.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/manga/ranking?ranking_type=manga&limit=15',
      );
      trendingM.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/manga/ranking?ranking_type=manhwa&limit=15',
      );
      topUpcomingM.value = await fetchDataFromApi(
        'https://api.myanimelist.net/v2/manga/ranking?ranking_type=manhua&limit=15',
      );
    } catch (e) {
      log('Error fetching home page data: $e', error: e);
    }
  }

  Future<AnilistMediaData> fetchWithToken(String url) async {
    const newField =
        "fields=mean,status,media_type,synopsis,genres,type,num_episodes,num_chapters,start_date,end_date,source,rating,rank,popularity,favorites,statistics,recommendations";

    final data = await fetchMAL('$url?$newField') as Map<String, dynamic>;
    return AnilistMediaData.fromMAL(data);
  }

  @override
  Rx<Widget> homeWidgets(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      const SliverToBoxAdapter(child: Header()),
      AiSuggestionsCard(userData: userData),
      UserListsCard(userData: userData),
      CalenderCard(userData: userData),
      SliverToBoxAdapter(
        child: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userAnimeList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimeScrollableList(
                      varient: CarousaleVarient.userList,
                      isManga: false,
                      animeList: userAnimeList,
                      title: "Currently Watching",
                    ),
                  ),
                topUpcoming.value.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : AnimeScrollableList(
                        animeList: topUpcoming,
                        isManga: false,
                        title: "Upcoming Animes",
                      ),
                trendingM.value.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : AnimeScrollableList(
                        animeList: trendingM,
                        isManga: true,
                        title: "Trending Manga",
                      ),

                100.height,
              ],
            ),
          );
        }),
      ),
    ],
  ).obs;

  @override
  Future<void> logout() async {
    await storage.put("mal_auth_token", '');
    await storage.put('mal_refresh_token', '');
    userData.value = User();
    isLoggedIn.value = false;
    userAnimeList.value.clear();
    userMangaList.value.clear();
  }

  @override
  Rx<Widget> mangaWidgets(BuildContext context) => Obx(
    () =>
        spotlightM.isEmpty ||
            popularM.isEmpty ||
            trendingM.isEmpty ||
            topUpcomingM.isEmpty
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
                buildSearchButton(context, () {
                  Get.to(() => const SearchScreen(isManga: true));
                }, 'manga'),
                const SizedBox(height: 10),
                MainCarousale(isManga: true, data: spotlightM),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
                AnimeScrollableList(
                  animeList: popularM,
                  isManga: true,
                  title: "Popular Manga",
                ),
                const SizedBox(height: 10),
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
              ],
            ),
          ),
  ).obs;
  @override
  Rx<User> userData = User().obs;

  @override
  Future<List<Anime>> fetchsearchData(SearchParams query) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateEntry(
    UserAnime params, {
    required bool isAnime,
    String? syncId,
  }) async {
    final listId = params.id;
    final score = params.score;
    final status = params.status;
    final progress = params.progress;
    final token = await storage.get('mal_auth_token');
    Utils.log(status ?? '');
    final url = Uri.parse(
      'https://api.myanimelist.net/v2/${isAnime ? 'anime' : 'manga'}/$listId/my_list_status',
    );

    final body = {
      if (status != null) 'status': status,
      if (score != null) 'score': score.toString(),
      if (progress != null && isAnime)
        'num_watched_episodes': progress.toString(),
      if (progress != null && !isAnime)
        'num_chapters_read': progress.toString(),
    };

    final req = await put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (syncId != null) {
      await anilistAuthController.updateEntry(
        UserAnime(id: listId, score: score, status: status, progress: progress),
        isAnime: isAnime,
        syncId: syncId,
      );
    }

    if (req.statusCode == 200) {
      azyxSnackBar(
        "${isAnime ? 'Anime' : 'Manga'} Tracked to ${isAnime ? 'Episode' : 'Chapter'} $progress Successfully!",
      );

      final newMedia = currentMedia.value
        ..progress = progress
        ..status = status
        ..score = score;
      currentMedia.value = newMedia;
      log('$isAnime: $body');
      if (isAnime) {
        fetchUserAnimeList();
      } else {
        fetchUserMangaList();
      }
    } else {
      log('Error: ${req.body}');
      log('$isAnime: $body');
    }
  }

  @override
  Future<void> deleteEntry(String listId, {bool isAnime = true}) async {
    final token = await storage.get('mal_auth_token');

    final url = Uri.parse(
      'https://api.myanimelist.net/v2/${isAnime ? 'anime' : 'manga'}/$listId/my_list_status',
    );

    final req = await delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (req.statusCode == 200) {
      azyxSnackBar(
        "${isAnime ? "Anime" : "Manga"} successfully deleted from your list!",
      );

      currentMedia.value = UserAnime();
      if (isAnime) {
        fetchUserAnimeList();
      } else {
        fetchUserMangaList();
      }
    } else {
      log('Error deleting entry: ${req.body}');
      azyxSnackBar(
        "Failed to delete ${isAnime ? "anime" : "manga"} from your list.",
      );
    }
  }

  @override
  RxList<UserAnime> userAnimeList = RxList();

  @override
  RxList<UserAnime> userMangaList = RxList();

  Future<void> fetchUserAnimeList() async {
    final data = await fetchMAL(
      'https://api.myanimelist.net/v2/users/@me/animelist?fields=num_episodes,mean,list_status&limit=1000&sort=list_updated_at&nsfw=1',
      auth: false,
      useAuthHeader: true,
    );
    userAnimeList.value = (data['data'] as List<dynamic>)
        .map((e) => UserAnime.fromMAL(e))
        .toList();
    log("animeList: ${data['data']}");
  }

  Future<void> fetchUserMangaList() async {
    final data = await fetchMAL(
      'https://api.myanimelist.net/v2/users/@me/mangalist?fields=num_chapters,mean,list_status&limit=1000&sort=list_updated_at&nsfw=1',
      auth: false,
      useAuthHeader: true,
    );
    log("mangaList: ${data['data']}");
    userMangaList.value = (data['data'] as List<dynamic>)
        .map((e) => UserAnime.fromMAL(e))
        .toList();
    log("animeList: ${data['data']}");
  }

  Future<void> fetchUserInfo({String? token}) async {
    final tokenn = token ?? storage.get('mal_auth_token');
    final data = await fetchMAL(
      'https://api.myanimelist.net/v2/users/@me',
      auth: true,
      useAuthHeader: true,
      token: tokenn,
    );
    userData.value = User.fromMAL(data);
    log('user login: $data');
    isLoggedIn.value = true;
    Future.wait([fetchUserAnimeList(), fetchUserMangaList()]);
  }

  @override
  Future<void> refresh() async {
    Future.wait([fetchhomeData(), fetchUserAnimeList(), fetchUserMangaList()]);
  }
}
