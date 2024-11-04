import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

const String BASE_URL = 'https://flamecomics.xyz';

Future<List<Map<String, dynamic>>> scrapeSliderData() async {
  final result = <Map<String, dynamic>>[];

  try {
    final response = await http.get(Uri.parse(BASE_URL));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page');
    }

    final document = parse(response.body);

    // Scraping slider data
    final slides = document.querySelectorAll('.swiper-slide');

    for (var slide in slides) {
      final title = slide.querySelector('.tt')?.text.trim();
      final link = slide.querySelector('a')?.attributes['href'];
      final id = link?.substring(0, (link!.length - 1)).split('/').last;
      final score = slide.querySelector('.numscore')?.text.trim();
      final status = slide.querySelector('.status i')?.text.trim();
      final genres = slide
          .querySelectorAll('.sliderInfoGenre li')
          .map((e) => e.text.trim())
          .toList();

      log(id.toString());
      // Extract bigbanner image URL from style attribute
      final bigBannerStyle = slide.querySelector('.bigbanner')?.attributes['style'];
      final bigBannerUrl = bigBannerStyle != null
          ? RegExp(r'url\((.*?)\)').firstMatch(bigBannerStyle)?.group(1)?.replaceAll("'", "")
          : null;

      result.add({
        'title': title,
        'id': id,
        'score': score,
        'status': status,
        'genres': genres,
        'image': bigBannerUrl,
      });
    }

    // Scraping trending data
    final trendingItems = document.querySelectorAll('.bs');

    for (var item in trendingItems) {
      final title = item.querySelector('.tt')?.text.trim();
      final link = item.querySelector('a')?.attributes['href'].toString();
      final id = link?.substring(0, (link.length - 1)).split('/').last;
      final imgUrl = item.querySelector('img')?.attributes['src'];

      result.add({
        'title': title,
        'id': id,
        'imgUrl': imgUrl,
      });
    }

    // Scraping latest updates
    final latestUpdates = document.querySelectorAll('.bs.styletere');

    for (var update in latestUpdates) {
      final title = update.querySelector('.tt')?.text.trim();
      final link = update.querySelector('a')?.attributes['href'].toString();
      final id = link?.substring(0, (link.length - 1)).split('/').last;
      final imgSrc = update.querySelector('img')?.attributes['src'];
      final numScore = update.querySelector('.numscore')?.text.trim();
      final status = update.querySelector('.status-dot')?.attributes['class']?[1]; // Assumes status is in a class
      final statusText = (status == 'ongoing') ? 'Ongoing' : 'New';

      // Extract chapters information
      final chapters = update.querySelectorAll('.chapter-list a').map((chapter) {
        final chapterTitle = chapter.querySelector('.epxs')?.text.trim();
        final chapterDate = chapter.querySelector('.epxdate')?.text.trim();
        final link = chapter.attributes['href'].toString();
        final id = link.substring(0, (link.length - 1)).split('/').last;
        return {
          'title': chapterTitle ?? "N/A",
          'date': chapterDate ?? "N/A",
          'id': id,
        };
      }).toList();

      result.add({
        'title': title ?? 'N/A',
        'id': id ?? "N/A",
        'image': imgSrc ?? "N/A",
        'rating': numScore?? "N/A",
        'status': statusText,
        'chapters': chapters,
      });
    }
  log(result.toString());
    return result;
  } catch (e) {
    throw Exception('Failed to scrape slider data: $e');
  }
}
