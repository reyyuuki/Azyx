import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Models/anilist_schedules.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for formatting the date

const String url = 'https://graphql.anilist.co';

Future<void> fetchCalendarData(RxList<AnilistSchedules> callbackData,
    {int page = 1}) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  int startTime = currentTime - 86400;
  int endTime = currentTime + (86400 * 6);

  const String query = '''
    query (\$page: Int, \$startTime: Int, \$endTime: Int) {
      Page(page: \$page, perPage: 50) {
        pageInfo {
          hasNextPage
        }
        airingSchedules(
          airingAt_greater: \$startTime,
          airingAt_lesser: \$endTime,
          sort: TIME_DESC
        ) {
          episode
          airingAt
          timeUntilAiring
          media {
            id
            idMal
            status
            averageScore
            coverImage { 
              large 
            }
            title {
              english
              romaji
            }
          }
        }
      }
    }
  ''';

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'query': query,
      'variables': {
        'page': page,
        'startTime': startTime,
        'endTime': endTime,
      },
    }),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final pageInfo = responseData['data']['Page']['pageInfo'];
    final schedules = responseData['data']['Page']['airingSchedules'];

    // Map to hold anime grouped by date
    Map<String, List<Anime>> dateToAnimeList = {};

    for (var schedule in schedules) {
      int airingAt = schedule['airingAt'];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(airingAt * 1000);
      String formattedDate = DateFormat('EEEE, MMMM d, y').format(dateTime);

      var media = schedule['media'];
      Anime anime = Anime.fromJson(media); // Assuming Anime.fromJson exists

      if (!dateToAnimeList.containsKey(formattedDate)) {
        dateToAnimeList[formattedDate] = [];
      }
      dateToAnimeList[formattedDate]!.add(anime);
    }

    List<AnilistSchedules> result = dateToAnimeList.entries.map((entry) {
      log(entry.key);
      log(entry.value.length.toString());
      return AnilistSchedules(
        date: entry.key,
        animeList: entry.value,
      );
    }).toList();

    callbackData.addAll(result);

    log('Fetched ${callbackData.length} total airing schedules so far.');

    if (pageInfo['hasNextPage']) {
      await fetchCalendarData(callbackData, page: page + 1);
    }
  } else {
    log('Error: ${response.body}');
    throw Exception('Failed to load AniList data: ${response.statusCode}');
  }
}
