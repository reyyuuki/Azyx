import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

/// Scrapes slider items from the given URL and returns a list of maps containing the data.
Future<dynamic> scrapeSliderItems() async {
  // Send HTTP GET request
  var response = await http.get(Uri.parse('https://miruro.tv'));

  // Check if the request was successful
  if (response.statusCode == 200) {
    log(response.body.toString());
    // Parse the HTML content
    var document = parse(response.body);

    // Select all elements with class name 'swiper-slide sc-fjBUEo fRXLnj'
    List<Element> sliderItems = document.getElementsByClassName('swiper-slide sc-fjBUEo fRXLnj');

    // Create a list to store the mapped data
    List<Map<String, dynamic>> scrapedData = [];

    // Iterate through each item and extract relevant data
    for (var item in sliderItems) {
      // Get the title
      var title = item.attributes['title'];

      // Get the image URL
      var imgElement = item.querySelector('img');
      var imgUrl = imgElement?.attributes['src'];

      // Get the description
      var descriptionElement = item.querySelector('p.sc-cJTOIK');
      var description = descriptionElement?.text;

      // Get the type (e.g., TV)
      var typeElement = item.querySelector('div[style*="flex-shrink: 0;"]');
      var type = typeElement?.text;

      // Get the total episodes (assuming it comes after the TV label)
      var episodesElement = item.querySelector('div svg + div');
      var episodes = episodesElement?.text;

      // Get the rating (stars or other indicators)
      var ratingElement = item.querySelector('div svg + div + div');
      var rating = ratingElement?.text;

      // Add the extracted data to the list
      scrapedData.add({
        'title': title,
        'image_url': imgUrl,
        'description': description,
        'type': type,
        'episodes': episodes,
        'rating': rating,
      });
    }

    log(scrapedData.toString());
    return scrapedData;
  } else {
    // Return an empty list if the request fails
    print('Failed to load the page: ${response.statusCode}');
    return [];
  }
}