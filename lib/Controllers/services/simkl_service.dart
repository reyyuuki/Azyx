// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/models/online_service.dart';
import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/params.dart';
import 'package:azyx/Models/simkl.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Screens/Anime/anime_screen.dart';
import 'package:azyx/Screens/Home/UserLists/user_lists.dart';
import 'package:azyx/Screens/search/search_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
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

final SimklService simklService = Get.find();

class SimklService extends GetxController
    implements BaseService, OnlineService {
  RxList<Anime> spotlight = RxList();
  RxList<Anime> popular = RxList();
  RxList<Anime> trendingMovies = RxList();
  RxList<Anime> trendingSeries = RxList();
  RxList<Anime> topUpcoming = RxList();
  final storage = Hive.box('auth');

  @override
  Future<AnilistMediaData> fetchDetails(FetchDetailsParams params) async {
    final id = params.id;
    final newId = id.split('*').first;
    final isSeries = id.split('*').last == "SERIES";
    Utils.log(isSeries.toString());
    final resp = await get(
      Uri.parse(
        "https://api.simkl.com/${isSeries ? 'tv' : 'movies'}/$newId?extended=full&client_id=${dotenv.env['SIMKL_CLIENT_ID']}",
      ),
    );
    Utils.log('start');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final result = AnilistMediaData.fromSimkl(data, !isSeries);
      Utils.log('namnae: ${data}');
      return result;
    } else {
      throw Exception('Failed to fetch trending movies: ${resp.statusCode}');
    }
  }

  Future<void> fetchMovies() async {
    final url =
        "https://api.simkl.com/movies/trending?extended=overview&client_id=${dotenv.env['SIMKL_CLIENT_ID']}&perPage=20";
    final resp = await get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      final list = data.map((e) {
        return Anime.fromSmallSimkl(e, true);
      }).toList();
      trendingMovies.value = list;
    } else {
      Utils.log(url);
      Utils.log("Error Ocurred: ${resp.body}");
      throw Exception('Failed to fetch trending movies: ${resp.statusCode}');
    }
  }

  Future<void> fetchSeries() async {
    final resp = await get(
      Uri.parse(
        "https://api.simkl.com/tv/trending?extended=overview&client_id=${dotenv.env['SIMKL_CLIENT_ID']}",
      ),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      Utils.log('aando: $data');
      final list = data.map((e) {
        return Anime.fromSmallSimkl(e, false);
      }).toList();
      trendingSeries.value = list;
    } else {
      throw Exception('Failed to fetch trending series: ${resp.statusCode}');
    }
  }

  @override
  Future<void> fetchhomeData() async =>
      Future.wait([fetchMovies(), fetchSeries()]);

  Future<List<Anime>> searchMovies(String query) async {
    final movieUrl = Uri.parse(
      'https://api.simkl.com/search/movie?q=$query&extended=full&client_id=${dotenv.env['SIMKL_CLIENT_ID']}',
    );
    final resp = await get(movieUrl);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      List<Anime> list = data
          .map((e) => Anime.fromSmallSimkl(e, true))
          .toList();
      return list;
    }
    return [];
  }

  Future<List<Anime>> searchSeries(String query) async {
    final movieUrl = Uri.parse(
      'https://api.simkl.com/search/tv?q=$query&extended=full&client_id=${dotenv.env['SIMKL_CLIENT_ID']}',
    );
    final resp = await get(movieUrl);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      List<Anime> list = data
          .map((e) => Anime.fromSmallSimkl(e, true))
          .toList();

      return list;
    }
    return [];
  }

  @override
  RxBool isLoggedIn = false.obs;

  @override
  Rx<User> userData = User().obs;

  Rx<UserAnime> currentMedia = UserAnime().obs;

  @override
  Future<void> updateEntry(UserAnime params, {required bool isAnime}) async {
    final listId = params.id;
    final status = params.status;
    final progress = params.progress;
    try {
      final isMovie = listId?.split('*').last == 'MOVIE';
      final id = listId?.split('*').first;

      String? newStatus = isMovie
          ? Simkl.alToSimklMovie(status ?? '')
          : Simkl.alToSimklShow(status ?? '');

      final token = await storage.get('simkl_auth_token');
      final apiKey = dotenv.env['SIMKL_CLIENT_ID'];

      if (token == null || apiKey == null) {
        Utils.log('Authentication token or API key missing');
        return;
      }

      final alrExist = (isMovie ? userAnimeList : userMangaList).any(
        (e) => e.id == listId,
      );

      final url = Uri.parse(
        alrExist
            ? 'https://api.simkl.com/sync/history'
            : 'https://api.simkl.com/sync/add-to-list',
      );

      final body = isMovie
          ? {
              'movies': [
                {
                  if (!alrExist) 'to': newStatus,
                  'ids': {'simkl': id},
                },
              ],
            }
          : {
              'shows': [
                {
                  if (!alrExist) 'to': newStatus,
                  'ids': {'simkl': id},
                  'episodes': [
                    for (int i = 1; i <= (progress ?? 1); i++) {'number': i},
                  ],
                },
              ],
            };

      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'simkl-api-key': apiKey,
        },
        body: jsonEncode(body),
      );
      Utils.log(response.body);
      if (progress != null) {
        currentMedia.value.progress = progress;
      }
      azyxSnackBar('${isMovie ? "Movie" : "Series"} Tracked Successfully');
      isMovie ? fetchUserMovieList() : fetchUserSeriesList();
    } catch (e, stack) {
      Utils.log('Exception: $e\n$stack');
      azyxSnackBar('An unexpected error occurred');
    }
  }

  @override
  Future<void> deleteEntry(String listId, {bool isAnime = true}) async {
    final isMovie = listId.split('*').last == 'MOVIE';
    final id = listId.split('*').first;
    final token = await storage.get('simkl_auth_token');
    final apiKey = dotenv.env['SIMKL_CLIENT_ID'];
    final url = Uri.parse('https://api.simkl.com/sync/history/remove');
    final response = await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'simkl-api-key': apiKey!,
      },
      body: json.encode(
        isMovie
            ? {
                'movies': [
                  {
                    'ids': {'simkl': id},
                  },
                ],
              }
            : {
                'shows': [
                  {
                    'ids': {'simkl': id},
                  },
                ],
              },
      ),
    );
    Utils.log(response.body);

    azyxSnackBar('${isMovie ? "Movie" : "Series"} Deleted Successfully');
    // currentMedia.value = TrackedMedia();
    fetchUserMovieList();
    fetchUserSeriesList();
  }

  @override
  Future<void> login() async {
    final clientId = dotenv.env['SIMKL_CLIENT_ID'];
    final redirectUri = dotenv.env['REDIRECT_URL'];

    final url =
        'https://simkl.com/oauth/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri';
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'azyx',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code != null) {
        await _exchangeCodeForToken(code);
      }
    } catch (e) {
      Utils.log(e.toString());
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final clientId = dotenv.env['SIMKL_CLIENT_ID'];
    final redirectUri = dotenv.env['REDIRECT_URL'];
    final clientSecret = dotenv.env['SIMKL_CLIENT_SECRET'];

    final url = Uri.parse('https://api.simkl.com/oauth/token');
    final req = await post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "code": code,
        "client_id": clientId,
        "client_secret": clientSecret,
        "redirect_uri": redirectUri,
        "grant_type": "authorization_code",
      }),
    );

    if (req.statusCode == 200) {
      final data = json.decode(req.body);
      final token = data['access_token'];
      await storage.put('simkl_auth_token', token);
      isLoggedIn.value = true;
      await fetchUserInfo();
      azyxSnackBar("Simkl Logined Successfully!");
    } else {
      Utils.log('${req.statusCode}: ${req.body}');
      azyxSnackBar("Yep, Failed");
    }
  }

  Future<void> fetchUserInfo() async {
    final token = await storage.get('simkl_auth_token');
    final apiKey = dotenv.env['SIMKL_CLIENT_ID'];
    final url = Uri.parse('https://api.simkl.com/users/settings');
    final response = await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'simkl-api-key': apiKey!,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final req = await post(
        Uri.parse('https://api.simkl.com/users/${data['account']['id']}/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'simkl-api-key': apiKey,
        },
      );
      final stats = jsonDecode(req.body);
      isLoggedIn.value = true;
      userData.value = User(
        id: data['account']['id'] ?? 0,
        name: data['user']['name'] ?? 'Guest',
        avatar: data['user']['avatar'],
        animeCount: stats['movies']?['completed']?['count'] ?? 0,

        mangaCount: stats['tv']?['completed']?['count'] ?? 0,
      );
      fetchUserMovieList();
      fetchUserSeriesList();
    } else {
      azyxSnackBar("User Info Fetching Failed!");
    }
  }

  @override
  RxList<UserAnime> userAnimeList = RxList();

  @override
  RxList<UserAnime> userMangaList = RxList();

  Future<void> fetchUserMovieList() async {
    final token = await storage.get('simkl_auth_token');
    final apiKey = dotenv.env['SIMKL_CLIENT_ID'];
    final url = Uri.parse('https://api.simkl.com/sync/all-items/movies');
    final response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'simkl-api-key': apiKey!,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      userAnimeList.value = (data['movies'] as List<dynamic>)
          .map((e) => UserAnime.fromSimklMovie(e))
          .toList();
      Utils.log('movies: ${data['movies']}');
    } else {
      Utils.log(response.body);
    }
  }

  Future<void> fetchUserSeriesList() async {
    final token = await storage.get('simkl_auth_token');
    final apiKey = dotenv.env['SIMKL_CLIENT_ID'];
    final url = Uri.parse('https://api.simkl.com/sync/all-items/shows');
    final response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'simkl-api-key': apiKey!,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Utils.log('shows: ${data['shows']}');
      userMangaList.value = (data['shows'] as List<dynamic>)
          .map((e) => UserAnime.fromSimklShow(e))
          .toList();
      Utils.log('stay away: ${userMangaList.first.episodes}');
    } else {
      Utils.log(response.body);
    }
  }

  @override
  Future<void> logout() async {
    await storage.delete('simkl_auth_token');
    isLoggedIn.value = false;
    userData.value = User();
  }

  @override
  Future<void> autoLogin() async {
    final token = await storage.get('simkl_auth_token');
    if (token != null) {
      await fetchUserInfo();
    }
  }

  @override
  Future<void> refresh() async => Future.wait([
    fetchUserMovieList(),
    fetchUserSeriesList(),
    fetchhomeData(),
  ]);

  @override
  Rx<Widget> animeWidgets(BuildContext context) {
    return Obx(
      () => trendingMovies.isEmpty
          ? Container(
              alignment: Alignment.center,
              height: Get.height * 0.8,
              child: const CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: buildSearchButton(
                      context,
                      () => Get.to(() => const SearchScreen(isManga: false)),
                      'movies',
                    ),
                  ),
                  const SizedBox(height: 10),
                  MainCarousale(isManga: false, data: trendingMovies),
                  const SizedBox(height: 20),
                  // AnimeScrollableList(
                  //   animeList: popular,
                  //   isManga: false,
                  //   title: "Popular Animes",
                  // ),
                  // const SizedBox(height: 10),
                  // AnimeScrollableList(
                  //   animeList: topUpcoming,
                  //   isManga: false,
                  //   title: "TopUpcoming Animes",
                  // ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: AnimeScrollableList(
                      animeList: trendingMovies,
                      isManga: false,
                      title: "Trending Movies",
                    ),
                  ),
                ],
              ),
            ),
    ).obs;
  }

  @override
  Future<List<Anime>> fetchsearchData(SearchParams query) {
    throw UnimplementedError();
  }

  @override
  Rx<Widget> homeWidgets(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: Header()),
        SliverToBoxAdapter(
          child: Obx(
            () => userData.value.name == null || userData.value.name!.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            context.theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                            context.theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const AzyXText(
                                text: "MY COLLECTIONS",
                                fontSize: 12,
                                color: Colors.white,
                                fontVariant: FontVariant.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const AzyXText(
                              text: "Your Collections",
                              fontSize: 20,
                              color: Colors.white,
                              fontVariant: FontVariant.bold,
                            ),
                            const SizedBox(height: 8),
                            const AzyXText(
                              text:
                                  "Access your personalized anime and manga lists",
                              fontSize: 14,
                              color: Colors.white,
                              fontVariant: FontVariant.regular,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: buildModernButton(
                                    context: context,
                                    title: "Movies",
                                    icon: Icons.movie_filter,
                                    subtitle: "Your movies list",
                                    onTap: () {
                                      Get.to(
                                        () => UserListPage(isManga: false),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildModernButton(
                                    context: context,
                                    title: "Series",
                                    icon: Icons.movie_filter_rounded,
                                    subtitle: "Your shows list",
                                    onTap: () {
                                      Get.to(() => UserListPage(isManga: true));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),

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
                  trendingMovies.value.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : AnimeScrollableList(
                          animeList: trendingMovies,
                          isManga: false,
                          title: "Trending Movies",
                        ),
                  trendingSeries.value.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : AnimeScrollableList(
                          animeList: trendingSeries,
                          isManga: true,
                          title: "Trending Series",
                        ),
                  100.height,
                ],
              ),
            );
          }),
        ),
      ],
    ).obs;
  }

  @override
  Rx<Widget> mangaWidgets(BuildContext context) {
    return Obx(
      () => trendingSeries.isEmpty
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
                    Get.to(() => const SearchScreen(isManga: false));
                  }, 'series'),
                  const SizedBox(height: 10),
                  MainCarousale(isManga: false, data: trendingSeries),
                  const SizedBox(height: 20),
                  const SizedBox(height: 10),
                  AnimeScrollableList(
                    animeList: trendingSeries,
                    isManga: false,
                    title: "Popular Series",
                  ),
                  // const SizedBox(height: 10),
                  // AnimeScrollableList(
                  //   animeList: topUpcomingM,
                  //   isManga: true,
                  //   title: "TopUpcoming Manga",
                  // ),
                  // const SizedBox(height: 10),
                  // AnimeScrollableList(
                  //   animeList: trendingM,
                  //   isManga: true,
                  //   title: "Completed Manga",
                  // ),
                ],
              ),
            ),
    ).obs;
  }
}
