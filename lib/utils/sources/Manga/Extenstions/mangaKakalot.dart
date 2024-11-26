import 'dart:developer';
import 'package:daizy_tv/utils/sources/Manga/Base/extract_class.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class MangaKakalot implements ExtractClass {
  @override
  String get url => 'https://chapmanganato.to/';

  @override
  String get sourceName => 'MangaKakalot';

  @override
  String get sourceVersion => '1.0';

  @override
  Future<dynamic> fetchChapters(String mangaId) async {
    final String baseUrl = '$url$mangaId';

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final target = document.querySelector('.story-info-right');

        if (target == null) {
          log('Error: Could not find the story-info-right element.');
          return {};
        }

        final String title = target.querySelector('h1')?.text.trim() ?? 'N/A';
        final chapterElements =
            document.querySelectorAll('.panel-story-chapter-list .a-h');
        final List<Map<String, dynamic>> chapterList =
            chapterElements.map((element) {
          final title =
              element.querySelector('.chapter-name')?.text.trim() ?? 'N/A';
          final path =
              element.querySelector('.chapter-name')?.attributes['href'] ?? '';
          final views =
              element.querySelector('.chapter-view')?.text.trim() ?? 'N/A';
          final updatedAt =
              element.querySelector('.chapter-time')?.text.trim() ?? 'N/A';
          // final number = path.split('/').last.split('-').last;

          return {
            'id': path.split('/').last,
            'title': title,
            'link': path,
            'views': views,
            'date': updatedAt,
            // 'number': int.parse(number),
          };
        }).toList();

        final metaData = {
          'id': mangaId,
          'title': title,
          'chapterList': chapterList.toList(),
        };

        log('Scraped Manga Info: ${metaData.toString()}');
        return metaData;
      } else {
        throw Exception(
            'Failed to load manga information. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error occurred while scraping manga info: ${e.toString()}');
      return {};
    }
  }

  @override
  Future<dynamic> fetchSearchsManga(String query) async {
    final String formattedQuery = query.replaceAll(' ', '_');
    final url = 'https://mangakakalot.com/search/story/$formattedQuery';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final mangaList = <Map<String, String>>[];

      document.querySelectorAll('.story_item').forEach((element) {
        final titleElement = element.querySelector('.story_name > a');
        final title = titleElement?.text.trim();
        final link = titleElement?.attributes['href'];
        final image = element.querySelector('img')?.attributes['src'];

        final author = element
            .querySelectorAll('span')[0]
            .text
            .replaceAll('Author(s) : ', '')
            .trim();
        final updated = element
            .querySelectorAll('span')[1]
            .text
            .replaceAll('Updated : ', '')
            .trim();
        final views = element
            .querySelectorAll('span')[2]
            .text
            .replaceAll('View : ', '')
            .trim();

        mangaList.add({
          'id': (link?.split('/')[3])!,
          'title': title!,
          'link': link!,
          'image': image!,
          'author': author,
          'updated': updated,
          'views': views,
        });
      });
      log('data: ${mangaList.toString()}');
      return {
        'mangaList': mangaList
      };
    } else {
      throw Exception('Failed to load manga search results');
    }
  }

  @override
  Future<dynamic> fetchPages(String link) async {
    int index = 0;
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        final document = parse(response.body);

        final title = document
            .querySelector('.panel-chapter-info-top h1')
            ?.text
            .toLowerCase()
            .split('chapter')
            .first
            .trim()
            .toUpperCase();

        final currentChapter =
            'Chapter${document.querySelector('.panel-chapter-info-top h1')?.text.toLowerCase().split('chapter').last.toUpperCase()}';

        final images = await Future.wait(document
            .querySelectorAll('.container-chapter-reader img')
            .map((img) async {
          final imgUrl = img.attributes['src'] ?? '';
          index++;
          return {
            'title': img.attributes['title'] ?? '',
            'image': imgUrl,
          };
        }).toList());
        final chapterNavLink =
            document.querySelector('.navi-change-chapter-btn');
        final nextChapterLink = chapterNavLink
                ?.querySelector('.navi-change-chapter-btn-next')
                ?.attributes['href'];
        final prevChapterLink = chapterNavLink
                ?.querySelector('.navi-change-chapter-btn-prev')
                ?.attributes['href'];

        final assets = {
          'title': title,
          'currentChapter': currentChapter,
          'nextChapter': nextChapterLink,
          'previousChapter': prevChapterLink,
          'link': link,
          'images': images,
          'totalImages': index,
        };
        log(assets.toString());
        return assets;
      } else {
        log('Failed to load chapter details, status code: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      log('Error: $e');
    }
    return {};
  }
}