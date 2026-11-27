import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/models/online_service.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Models/anilist_anime_data.dart';
import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Models/params.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Screens/Anime/anime_screen.dart';
import 'package:azyx/Screens/search/search_screen.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/main_carousale.dart';
import 'package:azyx/Widgets/common_cards.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/functions.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:azyx/utils/oauth_helper.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

final AnilistService anilistAuthController = Get.find();

class AnilistService extends GetxController
    implements BaseService, OnlineService {
  @override
  Rx<User> userData = User().obs;
  Rx<MediaData> animeData = Rx(MediaData());
  Rx<MediaData> mangaData = Rx(MediaData());
  @override
  RxList<UserMedia> userAnimeList = RxList();
  @override
  RxList<UserMedia> userMangaList = RxList();
  RxList<Media> spotlight = RxList();
  RxList<Media> popular = RxList();
  RxList<Media> trending = RxList();
  RxList<Media> topUpcoming = RxList();
  RxList<Media> spotlightM = RxList();
  RxList<Media> popularM = RxList();
  RxList<Media> trendingM = RxList();
  RxList<Media> topUpcomingM = RxList();
  @override
  Rx<UserMedia> currentMedia = UserMedia().obs;
  @override
  RxBool isLoggedIn = false.obs;
  @override
  Future<void> autoLogin() async {
    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isNotEmpty) {
      await fetchUserProfile();
      return;
    }
    log('Auth token not available!');
  }

  @override
  Future<void> login() async {
    final context = Get.context;
    if (context == null) return;
    final selectedMethod = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildLoginBottomSheet(ctx),
    );
    if (selectedMethod == null) return;

    String clientId = dotenv.get('CLIENT_ID');
    String clientSecret = dotenv.get('CLIENT_SECRET');
    String redirectUri = dotenv.get('REDIRECT_URL');

    if (selectedMethod == 'browser') {
      final url =
          'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';
      try {
        final result = await OauthHelper.authenticate(
          context: context,
          url: url,
          callbackUrlScheme: 'azyx',
        );
        if (result != null) {
          final code = Uri.parse(result).queryParameters['code'];
          if (code != null) {
            await _exchangeCodeForToken(
              code,
              clientId,
              clientSecret,
              redirectUri,
            );
          }
        }
      } catch (e) {
        log('Error during login: $e');
      }
    } else if (selectedMethod == 'token') {
      _showTokenInputDialog(context, clientId);
    }
  }

  Widget _buildLoginBottomSheet(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Login to AniList',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildLoginOptionTile(
              context,
              onPressed: () => Navigator.pop(context, 'browser'),
              icon: Icons.language_rounded,
              title: 'Login from Browser',
              subtitle: 'Authenticate securely via browser interface',
            ),
            const SizedBox(height: 12),
            _buildLoginOptionTile(
              context,
              onPressed: () => Navigator.pop(context, 'token'),
              icon: Icons.vpn_key_rounded,
              title: 'Login with Token',
              subtitle: 'Paste an existing AniList access token manually',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOptionTile(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colors.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTokenInputDialog(BuildContext context, String clientId) async {
    final TextEditingController controller = TextEditingController();
    final colors = Theme.of(context).colorScheme;

    final tokenUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=token';
    await launchUrlString(tokenUrl, mode: LaunchMode.externalApplication);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Paste AniList Token',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste the access token obtained from the AniList authorization page:',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: TextStyle(color: colors.onSurface, fontSize: 13),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'eyJhbGciOi...',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withOpacity(0.5),
                ),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colors.outline.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final token = controller.text.trim();
              if (token.isNotEmpty) {
                Navigator.pop(dialogCtx);
                AuthKeys.anilistToken.set(token);
                await fetchUserProfile();
              }
            },
            child: Text('Login', style: TextStyle(color: colors.onPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _exchangeCodeForToken(
    String code,
    String clientId,
    String clientSecret,
    String redirectUri,
  ) async {
    final response = await http.post(
      Uri.parse('https://anilist.co/api/v2/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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
      AuthKeys.anilistToken.set(token);
      log(token);
      await fetchUserProfile();
    } else {
      throw Exception('Failed to exchange code for token: ${response.body}');
    }
  }

  Future<void> fetchUserProfile() async {
    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isEmpty) {
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
      mediaListOptions {
        scoreFormat
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
      isLoggedIn.value = true;
    } else {
      throw Exception('Failed to load user profile');
    }
    await fetchUserAnimeList();
    await fetchUserMangaList();
  }

  Future<void> fetchUserAnimeList() async {
    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isEmpty) {
      return;
    }
    const query = '''
    query GetUserAnimeList(\$userId: Int) {
      MediaListCollection(userId: \$userId, type: ANIME) {
        lists {
          name
          entries {
            id
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
            repeat
            private
            startedAt {
              year
              month
              day
            }
            completedAt {
              year
              month
              day
            }
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
          'variables': {'userId': userId},
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null &&
            data['data']['MediaListCollection'] != null) {
          final lists =
              data['data']['MediaListCollection']['lists'] as List<dynamic>;
          userAnimeList.value = lists
              .expand(
                (e) => (e['entries'] as List<dynamic>).map(
                  (item) => UserMedia.fromJson(item),
                ),
              )
              .toList();
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
    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isEmpty) {
      return;
    }
    const query = '''
    query GetUserMangaList(\$userId: Int) {
      MediaListCollection(userId: \$userId, type: MANGA) {
        lists {
          name
          entries {
            id
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
            score
            repeat
            private
            startedAt {
              year
              month
              day
            }
            completedAt {
              year
              month
              day
            }
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
          'variables': {'userId': userId},
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null &&
            data['data']['MediaListCollection'] != null) {
          final lists =
              data['data']['MediaListCollection']['lists'] as List<dynamic>;
          userMangaList.assignAll(
            lists
                .expand(
                  (list) => (list['entries'] as List<dynamic>).map(
                    (item) => UserMedia.fromJson(item),
                  ),
                )
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
      log('Failed to load manga list: $e');
    }
  }

  @override
  Future<void> logout() async {
    AuthKeys.anilistToken.set('');
    userData.value = User();
    isLoggedIn.value = false;
    userAnimeList.value.clear();
    userMangaList.value.clear();
  }

  static const String _combinedHomeQuery = r'''
  query {
    animeTrending: Page {
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
    animePopular: Page {
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
    animeUpcoming: Page {
      media(type: ANIME, status: NOT_YET_RELEASED, sort: [POPULARITY_DESC, TRENDING_DESC], isAdult: false) {
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
    animeCompleted: Page {
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
    mangaTrending: Page {
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
    mangaPopular: Page {
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
    mangaUpcoming: Page {
      media(type: MANGA, status: NOT_YET_RELEASED, sort: [POPULARITY_DESC, TRENDING_DESC]) {
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
    mangaCompleted: Page {
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

  List<Media> _parseMediaList(dynamic rawList) {
    if (rawList is! List) return <Media>[];
    final items = <Media>[];
    for (final item in rawList) {
      if (item is Map) {
        try {
          items.add(Media.fromJson(Map<String, dynamic>.from(item)));
        } catch (e) {
          log('Media.fromJson skip error: $e');
        }
      }
    }
    return items;
  }

  bool _applyHomeDataMap(Map<String, dynamic> dataMap) {
    try {
      final animeTrending = dataMap['animeTrending']?['media'];
      final animePopular = dataMap['animePopular']?['media'];
      final animeUpcoming = dataMap['animeUpcoming']?['media'];
      final animeCompleted = dataMap['animeCompleted']?['media'];
      final mangaTrending = dataMap['mangaTrending']?['media'];
      final mangaPopular = dataMap['mangaPopular']?['media'];
      final mangaUpcoming = dataMap['mangaUpcoming']?['media'];
      final mangaCompleted = dataMap['mangaCompleted']?['media'];

      if (animeTrending is! List || mangaTrending is! List) {
        return false;
      }

      spotlight.value = _parseMediaList(animeTrending);
      if (animePopular is List) {
        popular.value = _parseMediaList(animePopular);
      }
      if (animeUpcoming is List) {
        topUpcoming.value = _parseMediaList(animeUpcoming);
      }
      if (animeCompleted is List) {
        trending.value = _parseMediaList(animeCompleted);
      }

      spotlightM.value = _parseMediaList(mangaTrending);
      if (mangaPopular is List) {
        popularM.value = _parseMediaList(mangaPopular);
      }
      if (mangaUpcoming is List) {
        topUpcomingM.value = _parseMediaList(mangaUpcoming);
      }
      if (mangaCompleted is List) {
        trendingM.value = _parseMediaList(mangaCompleted);
      }

      return spotlight.isNotEmpty || spotlightM.isNotEmpty;
    } catch (e) {
      log('_applyHomeDataMap error: $e');
      return false;
    }
  }

  bool _loadCachedHomeData() {
    try {
      final raw = CacheKeys.anilistHomeData.get<String>('');
      if (raw.isEmpty) return false;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _applyHomeDataMap(decoded);
      }
      if (decoded is Map) {
        return _applyHomeDataMap(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      log('_loadCachedHomeData error: $e');
    }
    return false;
  }

  Future<void> _fetchCombinedHomeData() async {
    final response = await http
        .post(
          Uri.parse('https://graphql.anilist.co/'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'query': _combinedHomeQuery}),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final dataMap = decoded is Map ? decoded['data'] : null;
      if (dataMap is Map) {
        final typedMap = Map<String, dynamic>.from(dataMap);
        final applied = _applyHomeDataMap(typedMap);
        if (applied) {
          CacheKeys.anilistHomeData.set(jsonEncode(typedMap));
        }
      }
    } else {
      throw Exception('Failed to load AniList home data (${response.statusCode})');
    }
  }

  Future<void> _refreshCombinedHomeDataSafe() async {
    try {
      await _fetchCombinedHomeData();
    } catch (e) {
      log('Background AniList home refresh error: $e');
    }
  }

  Future<void> fetchAnilistAnimes() => _fetchCombinedHomeData();

  Future<void> fetchAnilistManga() => _fetchCombinedHomeData();

  @override
  Future<void> updateEntry(
    UserMedia anime, {
    required bool isAnime,
    String? syncId,
  }) async {
    const String url = 'https://graphql.anilist.co';
    final accessToken = AuthKeys.anilistToken.get<String>('');
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    const String mutation = '''
    mutation SaveMediaListEntry(\$mediaId: Int!, \$status: MediaListStatus!, \$score: Float, \$progress: Int, \$startedAt: FuzzyDateInput, \$completedAt: FuzzyDateInput, \$private: Boolean, \$repeat: Int) {
      SaveMediaListEntry(mediaId: \$mediaId, status: \$status, score: \$score, progress: \$progress, startedAt: \$startedAt, completedAt: \$completedAt, private: \$private, repeat: \$repeat) {
        id
        status
        score
        progress
        repeat
        private
        startedAt {
          year
          month
          day
        }
        completedAt {
          year
          month
          day
        }
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
    Utils.log('hasID: ${anime.id}');
    final Map<String, dynamic> variables = {
      'mediaId': anime.id?.toInt(),
      'status': anime.status ?? "CURRENT",
      if (anime.score != null) 'score': anime.score,
      if (anime.progress != null) 'progress': anime.progress,
      if (anime.startedAt != null)
        'startedAt': {
          'year': anime.startedAt!.year,
          'month': anime.startedAt!.month,
          'day': anime.startedAt!.day,
        },
      if (anime.completedAt != null)
        'completedAt': {
          'year': anime.completedAt!.year,
          'month': anime.completedAt!.month,
          'day': anime.completedAt!.day,
        },
      if (anime.isPrivate != null) 'private': anime.isPrivate,
      if (anime.repeat != null) 'repeat': anime.repeat,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'query': mutation, 'variables': variables}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final saved = data['data']?['SaveMediaListEntry'];
      log('Successfully added to list: $saved');
      currentMedia.update((val) {
        val?.entryId = saved?['id'] as int? ?? val.entryId;
        val?.progress = anime.progress;
        val?.status = anime.status;
        val?.score = anime.score;
        val?.startedAt = anime.startedAt;
        val?.completedAt = anime.completedAt;
        val?.isPrivate = anime.isPrivate;
        val?.repeat = anime.repeat;
      });
    } else {
      final error = jsonDecode(response.body);
      log('Error adding to list: ${error['errors']}');
    }
    await fetchUserAnimeList();
    await fetchUserMangaList();
  }

  Future<bool> toggleFavourite(int mediaId, {bool isManga = false}) async {
    const String url = 'https://graphql.anilist.co';
    final accessToken = AuthKeys.anilistToken.get<String>('');
    if (accessToken.isEmpty) {
      log('toggleFavourite error: missing AniList access token');
      return false;
    }
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final String mutation = isManga
        ? '''
    mutation (\$mangaId: Int) {
      ToggleFavourite(mangaId: \$mangaId) {
        manga {
          pageInfo {
            total
          }
        }
      }
    }
    '''
        : '''
    mutation (\$animeId: Int) {
      ToggleFavourite(animeId: \$animeId) {
        anime {
          pageInfo {
            total
          }
        }
      }
    }
    ''';
    final variables = isManga ? {'mangaId': mediaId} : {'animeId': mediaId};
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'query': mutation,
          'variables': variables,
        }),
      );
      if (response.statusCode != 200) {
        log('toggleFavourite HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['errors'] != null) {
        log('toggleFavourite GraphQL error: ${decoded['errors']}');
        return false;
      }
      return true;
    } catch (e) {
      log('toggleFavourite error: $e');
      return false;
    }
  }

  Future<bool> deleteMediaListEntry(int entryId) async {
    const String url = 'https://graphql.anilist.co';
    final accessToken = AuthKeys.anilistToken.get<String>('');
    if (accessToken.isEmpty) return false;
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    const String mutation = '''
    mutation (\$id: Int) {
      DeleteMediaListEntry(id: \$id) {
        deleted
      }
    }
    ''';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'query': mutation,
          'variables': {'id': entryId},
        }),
      );
      if (response.statusCode == 200) {
        await fetchUserAnimeList();
        return true;
      }
      return false;
    } catch (e) {
      log('deleteMediaListEntry error: $e');
      return false;
    }
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
              child: const LoadingIndicatorM3E(),
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
                      'anime',
                    ),
                  ),
                  const SizedBox(height: 10),
                  MainCarousale(isManga: false, data: spotlight),
                  const SizedBox(height: 20),
                  if (userAnimeList.currentlyWatching.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: AnimeScrollableList(
                        varient: CarousaleVarient.userList,
                        isManga: false,
                        animeList: userAnimeList.currentlyWatching,
                        title: "Currently Watching",
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: AnimeScrollableList(
                      animeList: popular,
                      isManga: false,
                      title: "Popular Animes",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: AnimeScrollableList(
                      animeList: topUpcoming,
                      isManga: false,
                      title: "TopUpcoming Animes",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: AnimeScrollableList(
                      animeList: trending,
                      isManga: false,
                      title: "Completed Animes",
                    ),
                  ),
                ],
              ),
            ),
    ).obs;
  }

  @override
  Future<void> deleteEntry(String entry, {required bool isAnime}) {
    throw UnimplementedError();
  }

  @override
  Future<AnilistMediaData> fetchDetails(FetchDetailsParams params) async {
    final id = int.parse(params.id);
    final data = params.isManga
        ? await anilistDataController.fetchAnilistMangaDetails(id)
        : await anilistDataController.fetchAnilistAnimeDetails(id);
    return data;
  }

  @override
  Future<void> fetchhomeData() async {
    final hasCache = _loadCachedHomeData();
    if (hasCache) {
      unawaited(_refreshCombinedHomeDataSafe());
      return;
    }
    await _fetchCombinedHomeData();
  }

  @override
  Future<List<Media>> fetchsearchData(SearchParams query) {
    throw UnimplementedError();
  }

  @override
  Rx<Widget> homeWidgets(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      const SliverToBoxAdapter(child: Header()),
      AiSuggestionsCard(userData: userData),
      UserListsCard(userData: userData),
      CalenderCard(userData: userData),
      const RecentlyWatchedCard(),
      const RecentlyReadCard(),
      SliverToBoxAdapter(
        child: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userAnimeList.currentlyWatching.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimeScrollableList(
                      varient: CarousaleVarient.userList,
                      isManga: false,
                      animeList: userAnimeList.currentlyWatching,
                      title: "Currently Watching",
                    ),
                  ),
                if (userMangaList.currentlyReading.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimeScrollableList(
                      varient: CarousaleVarient.userList,
                      isManga: true,
                      animeList: userMangaList.currentlyReading,
                      title: "Currently Reading",
                    ),
                  ),
                topUpcoming.value.isEmpty
                    ? const Center(child: LoadingIndicatorM3E())
                    : AnimeScrollableList(
                        animeList: topUpcoming,
                        isManga: false,
                        title: "Upcoming Animes",
                      ),
                trendingM.value.isEmpty
                    ? const Center(child: LoadingIndicatorM3E())
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
  Rx<Widget> mangaWidgets(BuildContext context) => Obx(
    () =>
        spotlightM.isEmpty ||
            popularM.isEmpty ||
            trendingM.isEmpty ||
            topUpcomingM.isEmpty
        ? Container(
            alignment: Alignment.center,
            height: Get.height * 0.8,
            child: const LoadingIndicatorM3E(),
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
                if (userMangaList.currentlyReading.isNotEmpty) ...[
                  AnimeScrollableList(
                    varient: CarousaleVarient.userList,
                    isManga: true,
                    animeList: userMangaList.currentlyReading,
                    title: "Currently Reading",
                  ),
                  const SizedBox(height: 10),
                ],
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
  Future<void> refresh() async {
    Future.wait([fetchhomeData(), fetchUserAnimeList(), fetchUserMangaList()]);
  }
}
