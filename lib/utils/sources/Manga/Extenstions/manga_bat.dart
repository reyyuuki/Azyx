import 'dart:developer';
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class MangaBat implements ExtractClass {
  @override
  Future<dynamic> fetchSearchsManga(String query) async {
    final String formattedQuery = query.replaceAll(' ', '_');
    final String url = 'https://h.mangabat.com/search/manga/$formattedQuery';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final searchItems =
            document.querySelectorAll('.panel-list-story .list-story-item');

        List<dynamic> mangaList = searchItems.map((element) {
          final titleElement = element.querySelector('.item-title');
          final String title = titleElement?.text.trim() ?? 'N/A';
          final String link = titleElement?.attributes['href'] ?? '';
          final String imageUrl =
              element.querySelector('.item-img img')?.attributes['src'] ?? '';
          final String rating =
              element.querySelector('.item-rate')?.text.trim() ?? 'N/A';
          final String author =
              element.querySelector('.item-author')?.text.trim() ?? 'N/A';
          final updatedElement = element.querySelectorAll('.item-time');
          final String updatedAt =
              updatedElement.isNotEmpty ? updatedElement[0].text.trim() : 'N/A';
          final String views =
              updatedElement.length > 1 ? updatedElement[1].text.trim() : 'N/A';
          return {
            'id': link.toString().split('/').last,
            'title': title,
            'link': link,
            'image': imageUrl,
            'rating': rating,
            'author': author,
            'updatedAt': updatedAt,
            'views': views,
          };
        }).toList();

        return {
          'mangaList': mangaList
        };
      } else {
        throw Exception(
            'Failed to load search results. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error occurred while scraping search data: ${e.toString()}');
      return [];
    }
  }

  @override
  Future<dynamic> fetchChapters(String mangaId) async {
    final String url = 'https://readmangabat.com/$mangaId';

    try {
      final response = await http.get(Uri.parse(url));

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
          final number = path.split('/').last.split('-').last;

          return {
            'id': path.split('/').last.split('-')[3],
            'title': title,
            'link': path,
            'views': views,
            'date': updatedAt,
            'number': number,
          };
        }).toList();

        final metaData = {
          'id': mangaId,
          'title': title,
          'chapterList': chapterList.toList(),
        };
        log(metaData.toString());
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
  String get url => 'https://h.mangabat.com/';

  @override
  Future<dynamic> fetchPages(String link) async {
    int index = 0;

    try {
      final response = await http
          .get(Uri.parse(link));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        log(url);
      
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

        final chapterNavLink =
            document.querySelector('.navi-change-chapter-btn');
        final nextChapterLink = chapterNavLink
                ?.querySelector('.navi-change-chapter-btn-next')
                ?.attributes['href'];
        final prevChapterLink = chapterNavLink
                ?.querySelector('.navi-change-chapter-btn-prev')
                ?.attributes['href'];

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

  @override
  String get sourceName => 'MangaBat';

  @override
  String get sourceVersion => '1.0';
}