import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

const String url = "https://mangareader.to/home";

Future<List<Map<String, dynamic>>> scrapSlider() async {
  List<Map<String, dynamic>> results = [];  // Simple list to store the results
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Select all slides in the slider
    final slides = document.querySelectorAll('.swiper-slide .deslide-item');

    if (slides.isNotEmpty) {
      for (final slide in slides) {
        // Extract the image URL and the title
        final imageElement = slide.querySelector('.manga-poster img');
        final imageUrl = imageElement?.attributes['src'];
        final idElement = slide.querySelector('.deslide-cover')?.attributes['href'];
        final id = idElement?.substring(1, idElement.length); // Extracting ID
        final titleElement = slide.querySelector('.desi-head-title a');
        final title = titleElement?.attributes['title']; // Manga title
        final chapter = slide.querySelector('.desi-sub-text')?.text; // Chapter info
        final description = slide.querySelector('.mb-3')?.text; // Description
        final genreElements = slide.querySelectorAll('.scd-genres span');
        List<String> genres = [];

        // Collect genres
        for (final genreElement in genreElements) {
          final genreText = genreElement.text.trim();
          genres.add(genreText);
        }

        log(id.toString()); // Logging the ID for debug purposes

        // Store the result in the list as a map
        if (title != null && imageUrl != null) {
          results.add({
            'id': id,
            'title': title,
            'imageUrl': imageUrl,
            'chapter': chapter ?? 'No chapter info',
            'description': description ?? 'No description available',
            'genres': genres.isNotEmpty ? genres : ['No genres available'],
          });
        }
      }
    } else {
      log('No slides found');
    }
    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}

Future<List<Map<String, dynamic>>> scrapTrending() async {
  List<Map<String, dynamic>> results = [];  // Simple list to store the results
  const String url = "https://mangareader.to/home";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Select all items in the trending section
    final trendingItems = document.querySelectorAll('#trending-home .item');

    if (trendingItems.isNotEmpty) {
      for (final item in trendingItems) {
        // Extract the image URL and the title
        final imageElement = item.querySelector('.manga-poster img');
        final imageUrl = imageElement?.attributes['src'];
        final idElement = item.querySelector('.link-mask')?.attributes['href'];
        final id = idElement?.substring(1, idElement.length); // Extracting ID
        final titleElement = item.querySelector('.anime-name');
        final title = titleElement?.text.trim(); // Manga title
        final numberElement = item.querySelector('.number span');
        final rank = numberElement?.text.trim(); // Rank number

        log(id.toString()); // Logging the ID for debug purposes

        // Store the result in the list as a map
        if (title != null && imageUrl != null) {
          results.add({
            'id': id,
            'title': title,
            'imageUrl': imageUrl,
            'rank': rank ?? 'No rank available',
          });
        }
      }
    } else {
      log('No trending items found');
    }
    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}

Future<List<Map<String, dynamic>>> scrapFeatured() async {
  List<Map<String, dynamic>> results = [];  // Simple list to store the results
  const String url = "https://mangareader.to/home";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Select all items in the featured section
    final featuredItems = document.querySelectorAll('#featured-03 .swiper-slide');

    if (featuredItems.isNotEmpty) {
      for (final item in featuredItems) {
        // Extract the image URL and the title
        final imageElement = item.querySelector('.manga-poster img');
        final imageUrl = imageElement?.attributes['src'];
        final idElement = item.querySelector('.link-mask')?.attributes['href'];
        final id = idElement?.substring(1, idElement.length); // Extracting ID
        final titleElement = item.querySelector('.manga-name a');
        final title = titleElement?.text.trim(); // Manga title
        final subtitle = item.querySelector('.mp-desc')?.text.trim(); // Subtitle or chapter info

        log(id.toString()); // Logging the ID for debug purposes

        // Store the result in the list as a map
        if (title != null && imageUrl != null) {
          results.add({
            'id': id,
            'title': title,
            'imageUrl': imageUrl,
            'subtitle': subtitle ?? 'No subtitle available',
          });
        }
      }
    } else {
      log('No featured items found');
    }
    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}


Future<List<Map<String, dynamic>>> scrapMangaList() async {
  List<Map<String, dynamic>> results = [];
  const String url = "https://mangareader.to/home";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Select all manga items
    final mangaItems = document.querySelectorAll('.manga_list-sbs .item-spc');

    if (mangaItems.isNotEmpty) {
      for (final item in mangaItems) {
        // Extract the title
        final titleElement = item.querySelector('.manga-name a');
        final title = titleElement?.text.trim();

        // Extract the URL of the manga page
        final idElement = item.querySelector('.manga-name a')?.attributes['href'];
        final id = idElement?.substring(1, idElement.length); // Extracting ID (skip '/')

        // Extract the image URL
        final imageElement = item.querySelector('.manga-poster img');
        final imageUrl = imageElement?.attributes['src'];

        // Extract the genres (action, adventure, magic, etc.)
        final genreElements = item.querySelectorAll('.fdi-infor a');
        final genres = genreElements.map((genre) => genre.text.trim()).toList();

        log(id.toString()); // Logging the ID for debug purposes

        // Store the result in the list as a map
        if (title != null && imageUrl != null) {
          results.add({
            'id': id,
            'title': title,
            'imageUrl': imageUrl,
            'genres': genres,
          });
        }
      }
    } else {
      log('No manga items found');
    }

    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}



Future<List<Map<String, dynamic>>> scrapCompleted() async {
  List<Map<String, dynamic>> results = [];
  const String url = "https://mangareader.to/home";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Select all manga items in the completed section
    final completedItems = document.querySelectorAll('#featured-04 .swiper-slide');

    if (completedItems.isNotEmpty) {
      for (final item in completedItems) {
        // Extract the title
        final titleElement = item.querySelector('.manga-name a');
        final title = titleElement?.text.trim();

        // Extract the URL of the manga page
        final idElement = item.querySelector('.link-mask')?.attributes['href'];
        final id = idElement?.substring(1, idElement.length); // Extracting ID (skip '/')

        // Extract the image URL
        final imageElement = item.querySelector('.manga-poster img');
        final imageUrl = imageElement?.attributes['src'];

        // Extract the genres (romance, school, etc.)
        final genreElements = item.querySelectorAll('.fdi-infor a');
        final genres = genreElements.map((genre) => genre.text.trim()).toList();

        log(id.toString()); // Logging the ID for debug purposes

        // Store the result in the list as a map
        if (title != null && imageUrl != null) {
          results.add({
            'id': id,
            'title': title,
            'imageUrl': imageUrl,
            'genres': genres,
          });
        }
      }
    } else {
      log('No completed items found');
    }

    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}




Future<List<Map<String, dynamic>>> scrapChartSection(String sectionId) async {
  List<Map<String, dynamic>> results = [];
  const String url = "https://mangareader.to/home";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    // Parse the HTML document
    final document = parse(response.body);

    // Select the chart section (today, week, month) by ID
    final chartItems = document.querySelectorAll('#$sectionId .featured-block-ul li');

    if (chartItems.isNotEmpty) {
      for (final item in chartItems) {
        // Extract the title
        final titleElement = item.querySelector('.manga-name a');
        final title = titleElement?.text.trim();

        // Extract the URL of the manga page
        final idElement = item.querySelector('.manga-poster')?.attributes['href'];
        final id = idElement?.substring(1, idElement.length); // Extracting ID (skip '/')

        // Extract the genres (action, demons, etc.)
        final genreElements = item.querySelectorAll('.fdi-cate a');
        final genres = genreElements.map((genre) => genre.text.trim()).toList();

        // Extract the number of views
        final viewsElement = item.querySelector('.fdi-view');
        final views = viewsElement?.text.trim();

        // Extract the latest chapter
        final chapterElement = item.querySelector('.fdi-chapter a');
        final latestChapter = chapterElement?.text.trim();

        log(id.toString()); // Logging the ID for debug purposes

        // Store the result in the list as a map
        if (title != null) {
          results.add({
            'id': id,
            'title': title,
            'genres': genres,
            'views': views ?? 'N/A',
            'latestChapter': latestChapter ?? 'N/A',
          });
        }
      }
    } else {
      log('No items found in the section: $sectionId');
    }

    log(results.toString());
    return results;
  } catch (e) {
    log('Error: $e');
  }

  return results;
}

// Example usage for different sections
Future<void> scrapSchedule() async {
  List<Map<String, dynamic>> todayResults = await scrapChartSection('chart-today');
  List<Map<String, dynamic>> weekResults = await scrapChartSection('chart-week');
  List<Map<String, dynamic>> monthResults = await scrapChartSection('chart-month');

  // Process the results as needed
}
