import 'package:azyx/Models/anilist_schedules.dart';
import 'package:azyx/Models/anilist_search.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/utils/Anilist/anilist_calender.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

final AnilistDataController anilistDataController = Get.find();

class AnilistDataController extends GetxController {
  final String graphqlEndpoint = 'https://graphql.anilist.co';
  final RxList<AnilistSchedules> anilistSchedules = RxList();
  @override
  void onInit() async {
    super.onInit();
    await fetchCalendarData(anilistSchedules);
  }

  Future<AnilistMediaData> fetchAnilistAnimeDetails(int animeId,
      {dynamic offlineData}) async {
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
        status
        popularity
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
        offlineData = data;
        return AnilistMediaData.fromJson(media, false);
      } else {
        log('Error response: ${response.body}');
        throw Exception('Failed to load anime details: ${response.body}');
      }
    } catch (error) {
      log('Exception: $error');
      throw Exception('Failed to load anime details: $error');
    }
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

  // Future<List<AnilistSchedules>> fetchAniListCalendar() async {
  //   const String url = 'https://graphql.anilist.co';
  //   const String query = r'''
  //   query {
  //     Page(page: 1, perPage: 50) {
  //       airingSchedules(notYetAired: true, sort: TIME) {
  //         id
  //         airingAt
  //         episode
  //         media {
  //           id
  //           title {
  //             romaji
  //             english
  //             native
  //           }
  //           coverImage {
  //             large
  //           }
  //         }
  //       }
  //     }
  //   }
  // ''';

  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'query': query}),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final List<dynamic> schedules = data['data']['Page']['airingSchedules'];

  //     Map<String, List<Anime>> dateToAnimeList = {};

  //     for (var schedule in schedules) {
  //       int airingAt = schedule['airingAt'];
  //       DateTime dateTime =
  //           DateTime.fromMillisecondsSinceEpoch(airingAt * 1000);
  //       String formattedDate = DateFormat('EEEE, MMMM d, y').format(dateTime);

  //       var media = schedule['media'];

  //       if (!dateToAnimeList.containsKey(formattedDate)) {
  //         dateToAnimeList[formattedDate] = [];
  //       }
  //       dateToAnimeList[formattedDate]!.add(Anime.fromJson(media));
  //     }

  //     List<AnilistSchedules> result = dateToAnimeList.entries.map((entry) {
  //       return AnilistSchedules(
  //         date: entry.key,
  //         animeList: entry.value,
  //       );
  //     }).toList();

  //     return result;
  //   } else {
  //     throw Exception('Failed to fetch AniList calendar');
  //   }
  // }
}
