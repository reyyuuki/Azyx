import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RecommendationCache {
  static final Map<String, List<Media>> _cache = {};
  static final Map<String, int> _pageCache = {};

  static List<Media>? get(String key, int page) {
    final cacheKey = '$key:$page';
    return _cache[cacheKey];
  }

  static void set(String key, int page, List<Media> items) {
    final cacheKey = '$key:$page';
    _cache[cacheKey] = items;
    _pageCache[key] = page;
  }

  static void clear() {
    _cache.clear();
    _pageCache.clear();
  }
}

Future<List<Media>> getAiRecommendations(
  bool isManga,
  int page, {
  bool isAdult = false,
  String? username,
  bool refresh = false,
}) async {
  try {
    final service = Get.isRegistered<ServiceHandler>()
        ? Get.find<ServiceHandler>()
        : null;
    final isAL = service?.serviceType.value == ServicesType.anilist ||
        service == null;
    final userName = username?.trim().isNotEmpty == true
        ? username!.trim()
        : (anilistAuthController.userData.value.name ?? '');

    final cacheKey =
        '${isManga ? 'manga' : 'anime'}:$userName:${isAL ? 'al' : 'mal'}:${isAdult ? 'adult' : 'sfw'}';

    if (!refresh) {
      final cached = RecommendationCache.get(cacheKey, page);
      if (cached != null) {
        return cached;
      }
    }

    final trackedIds = _buildTrackedIdSet();

    final List<Future<List<Media>>> futures = [];

    if (page == 1 && !isManga && userName.isNotEmpty) {
      futures.add(_fetchAnimeSproutRecommendations(
        userName: userName,
        isAL: isAL,
        trackedIds: trackedIds,
        isAdult: isAdult,
      ));
    }

    futures.add(_fetchAnilistRecommendations(
      isManga: isManga,
      page: page,
      isAdult: isAdult,
    ));

    final resultsList = await Future.wait(futures, eagerError: false);

    final Map<String, Media> uniqueMap = {};

    for (final recList in resultsList) {
      for (final media in recList) {
        if (media.id != null && !trackedIds.contains(media.id)) {
          if (!uniqueMap.containsKey(media.id)) {
            uniqueMap[media.id!] = media;
          }
        }
      }
    }

    List<Media> results = uniqueMap.values.toList();

    if (!isAdult) {
      results = results.where((media) {
        final genres = media.genres ?? [];
        final hasAdultGenres = genres.any((g) {
          final genre = g.toUpperCase();
          return genre.contains('HENTAI') ||
              genre.contains('EROTICA') ||
              genre.contains('ADULT') ||
              genre.contains('18+') ||
              genre.contains('ECCHI');
        });
        final titleHasAdult = (media.title ?? '').toLowerCase().contains('hentai') ||
            (media.title ?? '').toLowerCase().contains('erotica') ||
            (media.title ?? '').toLowerCase().contains('nsfw');
        return !hasAdultGenres && !titleHasAdult;
      }).toList();
    }

    RecommendationCache.set(cacheKey, page, results);
    return results;
  } catch (e) {
    log('Error getting AI recommendations: $e');
    return [];
  }
}

Set<String> _buildTrackedIdSet() {
  final ids = <String>{};
  try {
    for (final m in anilistAuthController.userAnimeList) {
      if (m.id != null) ids.add(m.id!);
    }
    for (final m in anilistAuthController.userMangaList) {
      if (m.id != null) ids.add(m.id!);
    }
  } catch (e) {
    log('Error building tracked IDs: $e');
  }
  return ids;
}

Future<List<Media>> _fetchAnimeSproutRecommendations({
  required String userName,
  required bool isAL,
  required Set<String> trackedIds,
  required bool isAdult,
}) async {
  try {
    final uri = Uri.https(
      'anime.ameo.dev',
      '/user/$userName/recommendations',
      {
        if (isAL) 'source': 'anilist',
        'exs': 'true',
        'specials': 'true',
        'movies': 'true',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      return [];
    }

    final body = response.body;
    final jsonStart = body.indexOf('"initialRecommendations"');
    if (jsonStart == -1) return [];

    final scriptStart = body.lastIndexOf('<script', jsonStart);
    final scriptEnd = body.indexOf('</script>', jsonStart);
    if (scriptStart == -1 || scriptEnd == -1) return [];

    final scriptContent = body.substring(scriptStart, scriptEnd);
    final jsonTagStart = scriptContent.indexOf('{');
    if (jsonTagStart == -1) return [];

    final jsonStr = scriptContent.substring(jsonTagStart);
    final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

    final initialRecs =
        jsonData['initialRecommendations'] as Map<String, dynamic>?;
    if (initialRecs == null || initialRecs['type'] != 'ok') return [];

    final recommendations = initialRecs['recommendations'] as List<dynamic>;
    final animeData = initialRecs['animeData'] as Map<String, dynamic>;

    final List<Media> results = [];
    int processed = 0;

    for (final rec in recommendations) {
      if (processed >= 50) break;
      final malId = rec['id']?.toString();
      if (malId == null) continue;
      final data = animeData[malId] as Map<String, dynamic>?;
      if (data == null) continue;
      if (rec['planToWatch'] == true) continue;

      if (!isAdult) {
        final nsfw = data['nsfw'] == true ||
            (data['genres'] as List?)?.any((g) =>
                    ['HENTAI', 'EROTICA']
                        .contains(g['name']?.toUpperCase())) ==
                true;
        if (nsfw) continue;
      }

      final title = (data['alternative_titles'] as Map?)?['en'] as String?;
      final titleFallback = data['title'] as String?;
      final picture = (data['main_picture'] as Map?)?['large'] as String?;
      final synopsis = data['synopsis'] as String?;
      final genres = (data['genres'] as List?)
          ?.map((g) => (g['name'] as String).toUpperCase())
          .toList();

      String? resolvedId;
      if (isAL) {
        resolvedId = await _getAnilistIdFromMal(malId);
      } else {
        resolvedId = malId;
      }

      if (resolvedId == null || trackedIds.contains(resolvedId)) continue;

      results.add(Media(
        id: resolvedId,
        title: (title?.isNotEmpty == true ? title : titleFallback) ?? 'Unknown',
        image: picture ?? '',
        description: synopsis ?? '',
        genres: genres ?? [],
      ));

      processed++;
    }

    return results;
  } catch (e) {
    log('AnimeSprout fetch error: $e');
    return [];
  }
}

final Map<String, String> _malToAnilistCache = {};

Future<String?> _getAnilistIdFromMal(String malId) async {
  if (_malToAnilistCache.containsKey(malId)) {
    return _malToAnilistCache[malId];
  }
  try {
    final token = AuthKeys.anilistToken.get<String>('');
    const query = '''
    query(\$idMal: Int) {
      Media(idMal: \$idMal, type: ANIME) {
        id
      }
    }
    ''';
    final response = await http.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'idMal': int.tryParse(malId)},
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data']?['Media']?['id']?.toString();
      if (id != null) {
        _malToAnilistCache[malId] = id;
        return id;
      }
    }
  } catch (e) {
    log('MAL to AL conversion error: $e');
  }
  return null;
}

Future<List<Media>> _fetchAnilistRecommendations({
  required bool isManga,
  required int page,
  required bool isAdult,
}) async {
  try {
    final token = AuthKeys.anilistToken.get<String>('');
    const query = '''
    query(\$page: Int) {
      Page(page: \$page, perPage: 50) {
        recommendations(sort: RATING_DESC) {
          mediaRecommendation {
            id
            idMal
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              color
            }
            description
            genres
            type
            isAdult
            averageScore
            format
            status
            episodes
            chapters
            volumes
          }
        }
      }
    }
    ''';

    final response = await http.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'page': page},
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);
    final recs = data['data']?['Page']?['recommendations'] as List<dynamic>?;
    if (recs == null || recs.isEmpty) {
      return [];
    }

    final results = <Media>[];
    final seenIds = <String>{};

    for (final rec in recs) {
      final media = rec['mediaRecommendation'] as Map<String, dynamic>?;
      if (media == null) continue;

      final mediaType = media['type'] as String?;
      if (mediaType == null) continue;
      if (isManga && mediaType != 'MANGA') continue;
      if (!isManga && mediaType != 'ANIME') continue;
      if (!isAdult && media['isAdult'] == true) continue;

      final id = media['id']?.toString();
      if (id == null || !seenIds.add(id)) continue;

      final titleMap = media['title'] as Map?;
      String title = 'Unknown';
      if (titleMap != null) {
        title = titleMap['english'] ??
            titleMap['romaji'] ??
            titleMap['native'] ??
            'Unknown';
      }

      final genres = (media['genres'] as List?)
          ?.map((g) => g.toString().toUpperCase())
          .where((g) => g.isNotEmpty)
          .toList() ?? [];

      if (!isAdult) {
        final hasAdultGenres = genres.any((g) =>
            ['HENTAI', 'EROTICA', 'ADULT', '18+', 'ECCHI'].contains(g));
        if (hasAdultGenres) continue;
      }

      final coverImage = media['coverImage'] as Map?;
      final poster = coverImage?['large'] as String? ?? '';

      results.add(Media(
        id: id,
        title: title,
        image: poster,
        description: media['description'] as String? ?? '',
        genres: genres,
        rating: media['averageScore'] != null
            ? (media['averageScore'] / 10).toStringAsFixed(1)
            : '0.0',
        type: media['format']?.toString() ?? '',
        episodes: (media['episodes'] ?? media['chapters']) as int?,
        status: media['status']?.toString() ?? '',
      ));
    }

    return results;
  } catch (e) {
    log('AniList recommendations error: $e');
    return [];
  }
}
