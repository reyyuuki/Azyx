import 'dart:developer';

import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class MangaNato implements ExtractClass {
  @override
  String get url => "https://chapmanganato.to/";

  @override
  String get sourceVersion => "1.0";

  @override
  String get sourceName => "MangaNato";

  @override
  Future fetchChapters(String mangaId) async {
    final chapters = <Map<String, String>>[];

    try {
      final response = await http.get(Uri.parse('$url$mangaId'));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final chapterList = document.querySelector(".row-content-chapter");
        if (chapterList != null) {
          final chapterElements = chapterList.querySelectorAll(".a-h");
          for (var chapterElement in chapterElements) {
            final chapterTitle = chapterElement.querySelector('a')!.text.trim();
            final chapterlink =
                chapterElement.querySelector("a")!.attributes['href'] ?? "";
            final chapterViews =
                chapterElement.querySelectorAll("span")[0].text.trim();
            final chapterDate =
                chapterElement.querySelectorAll('span')[1].text.trim();

            chapters.add({
              'title': chapterTitle,
              'id': chapterlink.split("/").last,
              'views': chapterViews,
              'date': chapterDate,
              'link': chapterlink
            });
          }
        }
      }
    } catch (e) {
      log("Error: $e");
    }
    log(chapters.toString());
    return {
      'chapterList': chapters,
    };
  }

  @override
  Future fetchPages(String link) async {
    log(link);
    int index = 0;
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final currentChapter = document
            .querySelector('.panel-breadcrumb')
            ?.querySelectorAll('a')[2]
            .attributes['title'];
        final title = document
            .querySelector('.panel-breadcrumb')
            ?.querySelectorAll('a')[1]
            .attributes['title'];
        final previousChapter = document
            .querySelector('.navi-change-chapter-btn-prev')
            ?.attributes['href'];
        final nextChapter = document
            .querySelector('.navi-change-chapter-btn-next')
            ?.attributes['href'];
        final images = document
                .querySelectorAll('.container-chapter-reader img')
                .map((img) {
              index++;
              return {
                'title': img.attributes['title'],
                'image': img.attributes['src']
              };
            }).toList();
        final assets = {
          'title': title,
          'currentChapter': currentChapter,
          'images': images,
          'totalImages': index,
          'nextChapter': nextChapter,
          'previousChapter': previousChapter,
          'link': link,
        };
        log(assets.toString());
        return assets;
      } else {
        log("Error Ocurred while scrapping");
        return {};
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<dynamic> fetchSearchsManga(String name) async {
    try {
      String formattedName = name.replaceAll(' ', '_');
      final response = await http
          .get(Uri.parse('https://manganato.com/search/story/$formattedName'));
      final List<Map<String, String>> mangaList = [];
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final searchList = document.querySelector('.panel-search-story');
        if (searchList != null) {
          final searchElements =
              searchList.querySelectorAll('.search-story-item');
          for (var searchElement in searchElements) {
            final link =
                searchElement.querySelector('a')?.attributes['href'] ?? "";
            final title =
                searchElement.querySelector('a')?.attributes['title'] ?? "";
            final image =
                searchElement.querySelector('a img')?.attributes['src'] ?? "";

            mangaList.add({
              'id': link.split('/').last,
              'title': title,
              'image': image,
              'link': link
            });
          }
          log(mangaList.toString());
          return {
            'mangaList': mangaList,
          };
        } else {
          log('Error While pin website');
        }
      } else {
        log("Error in Scrapping Search Data MangaNato");
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
