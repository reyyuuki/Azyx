import 'package:azyx/Classes/anilist_search.dart';
import 'package:azyx/Classes/anime_details_data.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AnilistDataController extends GetxController {
  final String graphqlEndpoint = 'https://graphql.anilist.co';

  Future<DetailsData> fetchAnilistAnimeDetails(int animeId) async {
    const String query = '''
    query (\$id: Int) {
      Media(id: \$id) {
        id
        title {
          romaji
          english
          native
        }
        description
        coverImage {
          large   
        }
        bannerImage
        averageScore
        episodes
        type
        season
        seasonYear
        duration
        status
        chapters
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
        nextAiringEpisode {
          airingAt
          timeUntilAiring
        }
        rankings {
          rank
          type
          year
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
          "variables": {"id": animeId},
        }),
      );

      log('Request to AniList: id=$animeId, statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final media = data['data']['Media'];
        return DetailsData.fromJson(media, false);
      } else {
        log('Error response: ${response.body}');
        throw Exception('Failed to load anime details: ${response.body}');
      }
    } catch (error) {
      log('Exception: $error');
      throw Exception('Failed to load anime details: $error');
    }
  }

  Future<DetailsData> fetchAnilistMangaDetails(int mangaId) async {
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

        return DetailsData.fromJson(media, true);
      } else {
        log('Error response: ${response.body}');
        throw Exception('Failed to load manga details: ${response.body}');
      }
    } catch (error) {
      log('Exception: $error');
      throw Exception('Failed to load manga details: $error');
    }
  }

  Future<List<AnilistSearchData>> searchAnilistManga(String query) async {
    const String searchQuery = '''
    query (\$search: String) {
      Page(perPage: 30) {
        media(search: \$search, type: MANGA) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            large
          }
          bannerImage
          averageScore
          chapters
          volumes
          type
          status
        }
      }
    }
  ''';

    try {
      final response = await http.post(
        Uri.parse(graphqlEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": searchQuery,
          "variables": {"search": query},
        }),
      );

      log('Request to AniList: search=$query, statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangaList = data['data']['Page']['media'] as List<dynamic>;

        log(mangaList.toString());
        return mangaList.map<AnilistSearchData>((manga) {
          return AnilistSearchData.fromJson(manga, true);
        }).toList();
      } else {
        log('Error response: ${response.body}');
        throw Exception('Failed to search manga: ${response.body}');
      }
    } catch (error) {
      log('Exception: $error');
      throw Exception('Failed to search manga: $error');
    }
  }

  Future<List<AnilistSearchData>> searchAnilistAnime(String query) async {
    const String searchQuery = '''
    query (\$search: String) {
      Page(perPage: 30) {
        media(search: \$search, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            large
          }
          bannerImage
          averageScore
          episodes
          season
          seasonYear
          type
          status
        }
      }
    }
  ''';

    try {
      final response = await http.post(
        Uri.parse(graphqlEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "query": searchQuery,
          "variables": {"search": query},
        }),
      );

      log('Request to AniList: search=$query, statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final animeList = data['data']['Page']['media'] as List<dynamic>;
        return animeList.map<AnilistSearchData>((anime) {
          return AnilistSearchData.fromJson(anime, false);
        }).toList();
      } else {
        log('Error response: ${response.body}');
        throw Exception('Failed to search anime: ${response.body}');
      }
    } catch (error) {
      log('Exception: $error');
      throw Exception('Failed to search anime: $error');
    }
  }
}
