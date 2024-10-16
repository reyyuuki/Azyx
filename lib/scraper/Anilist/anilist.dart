import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Future<List<Map<String, String>>> scrapeAnimeData() async {
  String url = 'https://anilist.co/';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var document = parse(response.body);
    
    // Select all media cards from the page
    List<Element> animeCards = document.querySelectorAll('.media-card');

    // List to store extracted anime data
    List<Map<String, String>> animeData = [];
    
    for (var card in animeCards) {
      // Extract the necessary fields from each card
      var title = card.querySelector('.title')?.text.trim() ?? 'Unknown title';
      var link = card.querySelector('a')?.attributes['href'] ?? 'No link';
      var image = card.querySelector('img')?.attributes['src'] ?? 'No image';
      var episodes = card.querySelector('.hover-data')?.text.trim() ?? 'Unknown episodes';
      var studio = card.querySelector('.studios')?.text.trim() ?? 'Unknown studio';
      var genres = card.querySelector('.genres')?.text.trim() ?? 'Unknown genres';
      
      // Add extracted data to the list
      animeData.add({
        'title': title,
        'link': link,
        'image': image,
        'episodes': episodes,
        'studio': studio,
        'genres': genres,
      });
    }

    log(animeData.toString());
    return animeData;
  } else {
    throw Exception('Failed to load data');
  }
}
