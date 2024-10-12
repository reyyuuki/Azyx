import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

Future<Map<String, dynamic>> scrapMangaData(String language, String id) async {
   String url = "https://mangareader.to/$id";
  Map<String, dynamic> results = {};

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Title
    final titleElement = document.querySelector('.manga-name');
    final title = titleElement?.text.trim();

    // Image URL
    final imageElement = document.querySelector('.manga-poster img');
    final imageUrl = imageElement?.attributes['src'];

    // Description (using correct selector)
    final descriptionElement = document.querySelector('.description');
    final description = descriptionElement?.text.trim();

    // Genres
    final genreElements = document.querySelectorAll('.genres a');
    final genres = genreElements.map((genre) => genre.text.trim()).toList();

    // Store the manga details
    if (title != null && imageUrl != null) {
      results = {
        'title': title,
        'imageUrl': imageUrl,
        'description': description,
        'genres': genres,
      };
    } else {
      log('Failed to extract some manga details');
    }

    // Now extract chapter list
    List<Map<String, dynamic>> chapterList = [];

    // Select the chapter list element
    final chapterListElement = document.querySelector('#$language');
    if (chapterListElement == null) {
      log('Chapter list element not found.');
      return results; // Return results without chapters if element is not found
    }

    // Extract chapter information
    final chapterElements = chapterListElement.querySelectorAll('.chapter-item');
    if (chapterElements.isEmpty) {
      log('No chapter items found.');
    } else {
      for (final chapterElement in chapterElements) {
        // Extract chapter number
        final chapterNumber = chapterElement.attributes['data-number'];

        // Extract chapter title and URL (if available)
        final chapterTitleElement = chapterElement.querySelector('a');
        final chapterTitle = chapterTitleElement?.attributes['title']?.trim() ?? 'No Title';
        final chapterUrl = chapterTitleElement?.attributes['href'];

        // If there's no link, skip the chapter
        if (chapterNumber != null && chapterUrl != null) {
          chapterList.add({
            'number': chapterNumber,
            'title': chapterTitle,
            'url': 'https://mangareader.to$chapterUrl', // Complete URL
          });
        } else {
          log('Failed to extract chapter details for an item.');
        }
      }
    }

    // Add chapter list to results
    results['chapters'] = chapterList;
    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}
