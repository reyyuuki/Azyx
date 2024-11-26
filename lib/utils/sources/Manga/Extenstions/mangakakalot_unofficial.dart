import 'dart:developer';

import 'package:daizy_tv/utils/sources/Manga/Base/extract_class.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class MangakakalotUnofficial implements ExtractClass {
  @override
  String url = "https://ww8.mangakakalot.tv";

  @override
  String sourceVersion = "1/0";

  @override
  String sourceName = "MangaKakalot Unofficial";

  @override
  Future<dynamic> fetchChapters(String mangaId) async {
    try {
      final response = await http.get(Uri.parse('$url/manga/$mangaId'));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final chapters = <Map<String, String>>[];
        final chapterList = document.querySelector('.chapter-list');
        if (chapterList != null) {
          final chapterElements = chapterList.querySelectorAll('.row');
          for (var chapterElement in chapterElements) {
            final chapterTitle =
                chapterElement.querySelector('a')?.text.trim() ?? '';
            final chapterUrl =
                chapterElement.querySelector('a')?.attributes['href'] ?? '';
            final chapterViews =
                chapterElement.querySelectorAll('span')[1].text.trim();
            final chapterDate =
                chapterElement.querySelectorAll('span')[2].text.trim();

            chapters.add({
              'title': chapterTitle,
              'id': chapterUrl.toString().split('/').last,
              'views': chapterViews,
              'date': chapterDate,
              'link':chapterUrl
            });
          }
        }

        final metaData = {
          'chapterList': chapters,
        };
        // log(metaData.toString());
        return metaData;
      } else {
        log('Failed to load manga details, status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Future<dynamic> fetchPages(String link) async {
    final url = 'https://ww8.mangakakalot.tv$link';
    log(url);

    int index = 0;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final target = document.querySelector('.trang-doc');

        final title = document
            .querySelector('body > div.info-top-chapter > h2')
            ?.text
            .split('Chapter')
            .first
            .trim();
        final currentChapter =
            ('Chapter${document.querySelector('body > div.info-top-chapter > h2')?.text.split('Chapter').last}');
    
    
 final navLinks = target?.querySelectorAll('.btn-navigation-chap a') ?? [];
      String? nextChapter;
      String? previousChapter;

      if (navLinks.isNotEmpty) {
        for (var link in navLinks) {
          if (link.text.contains('NEXT')) {
            nextChapter = link.attributes['href'];
          } else if (link.text.contains('PREV')) {
            previousChapter = link.attributes['href'];
          }
        }
      }
      
        final images = target?.querySelectorAll('.vung-doc img').map((img) {
              index++;
              return {
                'title': img.attributes['title'] ?? '',
                'image': img.attributes['data-src'] ?? '',
              };
            }).toList() ??
            [];

        final assets = {
          'title': title,
          'currentChapter': currentChapter,
          'images': images,
          'totalImages': index,
          'nextChapter': nextChapter,
          'previousChapter': previousChapter,
          'link': link,
        };

      //  log(assets.toString());
        return assets;
      } else {
        log('Failed to load chapter details, status code: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Future<dynamic> fetchSearchsManga(String id, {int page = 1}) async {
    final String query = "$id?page=$page";
    final String searchUrl = "$url/search/$query";

    try {
      final response = await http.get(Uri.parse(searchUrl));

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final List<Map<String, String>> mangaList = [];

        document
            .querySelectorAll(".panel_story_list .story_item")
            .asMap()
            .forEach((index, element) {
          final target = element;
          final id = target
              .querySelector("a:first-child")
              ?.attributes['href']
              ?.split("/")[2]
              .trim();
          final image =
              target.querySelector("a:first-child img")?.attributes['src'];
          final title = target.querySelector("h3 a")?.text;

          if (id != null && image != null && title != null) {
            mangaList.add({
              'id': id,
              'image': image,
              'title': title,
            });
          }
        });

        return {
          'mangaList': mangaList,
          'metaData': {},
        };
      } else {
        throw Exception('Failed to load manga');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
