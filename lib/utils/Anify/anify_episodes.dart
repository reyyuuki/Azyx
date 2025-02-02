import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Classes/episode_class.dart';
import 'package:http/http.dart' as http;

Future<List<Episode>> fetchAnifyEpisodes(int id, List<Episode> data) async {
  final response =
      await http.get(Uri.parse('https://anify.eltik.cc/content-metadata/$id'));
  if (response.statusCode == 200) {
    try {
      final json = jsonDecode(response.body);
      final episodesList = json[0]['data'];
      if (episodesList == null || episodesList.isEmpty) {
        return data;
      }
      for (int i = 0; i < data.length; i++) {
        if (i < episodesList.length) {
          data[i].title = episodesList[i]['title'] ?? data[i].title;
          data[i].desc = episodesList[i]['description'] ?? data[i].desc;
          data[i].thumbnail = episodesList[i]['img'] ?? data[i].thumbnail;
        }
      }
      return data;
    } catch (e) {
      log("Error while fetching Anify episodes details : $e ");
      return data;
    }
  } else {
    return data;
  }
}
