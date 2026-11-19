import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Models/anilist_schedules.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/utils/Anilist/anilist_calender.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
final AnilistDataController anilistDataController = Get.find();
class AnilistDataController extends GetxController {
  final String graphqlEndpoint = 'https://graphql.anilist.co';
  final RxList<AnilistSchedules> anilistSchedules = RxList();
  final Map<int, (DateTime, AnilistMediaData)> _detailsCache = {};
  final Map<int, Future<AnilistMediaData>> _inFlightDetails = {};

  @override
  void onInit() async {
    super.onInit();
    await fetchCalendarData(anilistSchedules);
  }

  Future<AnilistMediaData> fetchAnilistAnimeDetails(
    int animeId, {
    dynamic offlineData,
  }) async {
    final cached = _detailsCache[animeId];
    if (cached != null) {
      if (DateTime.now().difference(cached.$1).inMinutes < 20) {
        return cached.$2;
      }
    }

    if (_inFlightDetails.containsKey(animeId)) {
      return _inFlightDetails[animeId]!;
    }

    final future = _fetchWithRetry(animeId);
    _inFlightDetails[animeId] = future;

    try {
      final result = await future;
      _detailsCache[animeId] = (DateTime.now(), result);
      return result;
    } finally {
      _inFlightDetails.remove(animeId);
    }
  }

  Future<AnilistMediaData> _fetchWithRetry(int animeId) async {
    try {
      return await _fetchMediaDetailsFromApi(animeId);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return await _fetchMediaDetailsFromApi(animeId);
    }
  }

  Future<AnilistMediaData> _fetchMediaDetailsFromApi(int animeId) async {
    const String query = '''
    query (\$id: Int) {
      Media(id: \$id, type: ANIME) {
        id
        title {
          romaji
          english
          native
        }
        coverImage {
          extraLarge
          color
        }
        bannerImage
        description
        status
        format
        episodes
        duration
        season
        seasonYear
        source
        countryOfOrigin
        averageScore
        meanScore
        popularity
        favourites
        genres
        tags {
          name
          rank
          isMediaSpoiler
        }
        rankings {
          rank
          type
          allTime
          season
          year
          format
          context
        }
        studios {
          edges {
            isMain
            node {
              name
              isAnimationStudio
            }
          }
        }
        nextAiringEpisode {
          episode
          timeUntilAiring
          airingAt
        }
        trailer {
          id
          site
        }
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        siteUrl
        streamingEpisodes {
          title
          thumbnail
          url
        }
        stats {
          scoreDistribution {
            score
            amount
          }
          statusDistribution {
            status
            amount
          }
        }
        characters(sort: [ROLE, FAVOURITES_DESC], perPage: 10) {
          edges {
            role
            node {
              name {
                full
              }
              image {
                large
              }
            }
            voiceActors(language: JAPANESE) {
              name {
                full
              }
            }
          }
        }
        relations {
          edges {
            relationType(version: 2)
            node {
              id
              type
              title {
                romaji
              }
              coverImage {
                large
              }
              format
            }
          }
        }
        recommendations(sort: RATING_DESC, perPage: 10) {
          nodes {
            mediaRecommendation {
              id
              title {
                romaji
              }
              coverImage {
                large
              }
              averageScore
            }
          }
        }
        isFavourite
        mediaListEntry {
          id
          status
          progress
          score
          repeat
        }
      }
    }
    ''';

    final token = AuthKeys.anilistToken.get<String>('');
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };

    final response = await http.post(
      Uri.parse(graphqlEndpoint),
      headers: headers,
      body: json.encode({
        "query": query,
        "variables": {"id": animeId},
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final media = data['data']?['Media'];
      if (media == null) {
        throw Exception('Media not found');
      }
      return AnilistMediaData.fromJson(media, false);
    } else {
      throw Exception('Failed to load anime details: ${response.statusCode}');
    }
  }

  Future<List<AnilistMediaData>> searchAnilistQuick(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    const String searchGql = '''
    query(\$s: String) {
      Page(perPage: 7) {
        media(search: \$s, type: ANIME, sort: SEARCH_MATCH) {
          id
          title {
            romaji
            english
          }
          coverImage {
            medium
          }
          format
          seasonYear
          averageScore
        }
      }
    }
    ''';
    try {
      final response = await http.post(
        Uri.parse(graphqlEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': searchGql,
          'variables': {'s': q},
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data']?['Page']?['media'] as List?;
        if (list != null) {
          return list
              .whereType<Map>()
              .map((e) => AnilistMediaData.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      log('searchAnilistQuick error: $e');
    }
    return [];
  }
  Future<AnilistMediaData> fetchAnilistMangaDetails(int mangaId) async {
    const String graphqlEndpoint = 'https://graphql.anilist.co';
    const String query = '''
  query (\$id: Int) {
    Media(id: \$id, type: MANGA) {
      id
      title {
        romaji
        english
        native
      }
      synonyms
      description
      coverImage {
        large   
      }
      bannerImage
      averageScore
      chapters  
      type
      season
      seasonYear
      status
      format
      popularity
      startDate {
        year
        month
        day
      }
      endDate {
        year
        month
        day
      }
      genres
      studios {
        nodes {
          name
        }
      }
      characters {
        edges {
          node {
            name {
              full
            }
            favourites
            image {
              large
            }
          }
        }
      }
      relations {
        edges {
          node {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            type
            averageScore
          }
        }
      }
      recommendations {
        edges {
          node {
            mediaRecommendation {
              id
              title {
                romaji
                english
              }
              coverImage {
                large
              }
              averageScore
            }
          }
        }
      }
    }
  }
  ''';
    try {
      final response = await http.post(
        Uri.parse(graphqlEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": query,
          "variables": {"id": mangaId},
        }),
      );
      log('Request to AniList: id=$mangaId, statusCode=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final media = data['data']['Media'];
        return AnilistMediaData.fromJson(media, true);
      } else {
        log('Error response: ${response.body}');
        throw Exception('Failed to load manga details: ${response.body}');
      }
    } catch (error) {
      log('Exception: $error');
      throw Exception('Failed to load manga details: $error');
    }
  }
  Future<List<Media>> searchAnilistAnime({
    String? query,
    String? type = "ANIME",
    String? format,
    String? status,
    String? season,
    int? seasonYear,
    List<String>? genres,
    List<String>? tags,
    List<String>? sort,
  }) async {
    const String searchQuery = '''
    query (
      \$search: String,
      \$type: MediaType,
      \$format: MediaFormat,
      \$status: MediaStatus,
      \$season: MediaSeason,
      \$seasonYear: Int,
      \$genre_in: [String],
      \$tag_in: [String],
      \$sort: [MediaSort]
    ) {
      Page(perPage: 30) {
        media(
          search: \$search,
          type: \$type,
          format: \$format,
          status: \$status,
          season: \$season,
          seasonYear: \$seasonYear,
          genre_in: \$genre_in,
          tag_in: \$tag_in,
          sort: \$sort
        ) {
          id
          idMal
          title {
            romaji
            english
            native
          }
          coverImage {
            large
            medium
          }
          bannerImage
          averageScore
          episodes
          season
          seasonYear
          type
          status
          genres
          tags {
            name
            isMediaSpoiler
          }
          startDate {
            year
            month
            day
          }
          endDate {
            year
            month
            day
          }
          description
          popularity
          trending
          favourites
          meanScore
          isAdult
        }
      }
    }
  ''';
    try {
      final variables = <String, dynamic>{
        if (query != null && query.trim().isNotEmpty) "search": query.trim(),
        "type": type,
        if (format != null) "format": format,
        if (status != null) "status": status,
        if (season != null) "season": season,
        if (seasonYear != null) "seasonYear": seasonYear,
        if (genres != null && genres.isNotEmpty) "genre_in": genres,
        if (tags != null && tags.isNotEmpty) "tag_in": tags,
        if (sort != null && sort.isNotEmpty) "sort": sort,
      };
      log('AniList request variables: $variables');
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({"query": searchQuery, "variables": variables}),
      );
      log('Request to AniList: statusCode=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          log('GraphQL errors: ${data['errors']}');
          throw Exception('GraphQL error: ${data['errors']}');
        }
        final animeList = data['data']['Page']['media'] as List<dynamic>;
        log('Found ${animeList.length} results');
        if (animeList.isNotEmpty) {
          log('First result: ${animeList.first}');
        }
        return animeList.map<Media>((anime) => Media.fromJson(anime)).toList();
      } else {
        log('Error response: ${response.body}');
        throw Exception(
          'Failed to search anime: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (error) {
      log('Exception in searchAnilistAnime: $error');
      rethrow;
    }
  }
  Future<List<Media>> searchAnilistManga({
    String? query,
    String? type = "MANGA",
    String? format,
    String? status,
    List<String>? genres,
    List<String>? tags,
    List<String>? sort,
  }) async {
    const String searchQuery = '''
    query (
      \$search: String,
      \$type: MediaType,
      \$format: MediaFormat,
      \$status: MediaStatus,
      \$genre_in: [String],
      \$tag_in: [String],
      \$sort: [MediaSort]
    ) {
      Page(perPage: 30) {
        media(
          search: \$search,
          type: \$type,
          format: \$format,
          status: \$status,
          genre_in: \$genre_in,
          tag_in: \$tag_in,
          sort: \$sort
        ) {
          id
          idMal
          title {
            romaji
            english
            native
          }
          coverImage {
            large
            medium
          }
          bannerImage
          averageScore
          chapters
          volumes
          type
          status
          genres
          tags {
            name
            isMediaSpoiler
          }
          startDate {
            year
            month
            day
          }
          endDate {
            year
            month
            day
          }
          description
          popularity
          trending
          favourites
          meanScore
          isAdult
        }
      }
    }
  ''';
    try {
      final variables = <String, dynamic>{
        if (query != null && query.trim().isNotEmpty) "search": query.trim(),
        "type": type,
        if (format != null) "format": format,
        if (status != null) "status": status,
        if (genres != null && genres.isNotEmpty) "genre_in": genres,
        if (tags != null && tags.isNotEmpty) "tag_in": tags,
        if (sort != null && sort.isNotEmpty) "sort": sort,
      };
      log('AniList manga request variables: $variables');
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({"query": searchQuery, "variables": variables}),
      );
      log('Request to AniList: statusCode=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          log('GraphQL errors: ${data['errors']}');
          throw Exception('GraphQL error: ${data['errors']}');
        }
        final mangaList = data['data']['Page']['media'] as List<dynamic>;
        log('Found ${mangaList.length} manga results');
        return mangaList.map<Media>((manga) => Media.fromJson(manga)).toList();
      } else {
        log('Error response: ${response.body}');
        throw Exception(
          'Failed to search manga: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (error) {
      log('Exception in searchAnilistManga: $error');
      rethrow;
    }
  }
}
