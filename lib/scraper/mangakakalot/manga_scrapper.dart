// ignore_for_file: empty_catches

import 'dart:developer';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

const urlLink = "https://ww8.mangakakalot.tv";

Future<dynamic> fetchMangaList({
  required int page,
}) async {
  final query = "?type=latest&page=$page";
  final url = "$urlLink/manga_list/$query";

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final mangaList = <Map<String, String>>[];

      document
          .querySelectorAll('.truyen-list .list-truyen-item-wrap')
          .forEach((element) {
        final image = urlLink +
            (element.querySelector('a img')?.attributes['data-src'] ?? '');
        final title = element.querySelector('h3 a')?.text ?? '';
        final chapter =
            element.querySelector('.list-story-item-wrap-chapter')?.text ?? '';
        final view = element.querySelector('.aye_icon')?.text ?? '';
        final description = (element.querySelector('p')?.text ?? '')
            .replaceAll('More.\n', ' ... \n')
            .trim();

        mangaList.add({
          'id': element
                  .querySelector('a')
                  ?.attributes['href']
                  ?.split('/')[2]
                  .trim() ??
              '',
          'image': image,
          'title': title,
          'chapter': chapter,
          'view': view,
          'description': description,
        });
      });
      log(mangaList.toString());
      return mangaList;
    } else {}
  } catch (e) {}
}

Future<dynamic> fetchMangaDetails(String mangaId) async {
  try {
    final response = await http.get(Uri.parse('$urlLink/manga/$mangaId'));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);

      final target = document.querySelector('.manga-info-top');

      final imageUrl =
          "https://www.mangakakalot.com${target?.querySelector('.manga-info-pic img')?.attributes['src'] ?? ''}";
      final name = target?.querySelector('h1')?.text.trim() ?? '';
      final alternativeTitle =
          target?.querySelector('.story-alternative')?.text.trim() ?? '';

      final authors = target
          ?.querySelectorAll('.manga-info-text li')[1]
          .querySelectorAll('a')
          .map((e) => e.text.trim())
          .toList();

      final status = target
              ?.querySelectorAll('.manga-info-text li')[2]
              ?.text
              .split(":")[1]
              .trim() ??
          'Unknown';
      final updated = target
              ?.querySelectorAll('.manga-info-text li')[3]
              ?.text
              .split(":")[1]
              .trim() ??
          'Unknown';
      final view = target
              ?.querySelectorAll('.manga-info-text li')[5]
              ?.text
              .split(":")[1]
              .trim() ??
          'Unknown';

      final genresRaw = target
              ?.querySelectorAll('.manga-info-text li')[6]
              ?.text
              .split(":")[1]
              .trim() ??
          '';
      final genres = genresRaw
          .split(",")
          .map((val) => val.trim())
          .where((val) => val.isNotEmpty)
          .toList();

      final descriptionElement = document.querySelector('#noidungm');
      final description =
          descriptionElement?.text.split('summary:').last.trim() ?? '';

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
          });
        }
      }

      final metaData = {
        'imageUrl': imageUrl,
        'name': name,
        'alternativeTitle': alternativeTitle,
        'authors': authors,
        'status': status,
        'updated': updated,
        'view': view,
        'genres': genres,
        'description': description,
        'chapterList': chapters,
      };
      log(metaData.toString());
      return metaData;
    } else {
      log('Failed to load manga details, status code: ${response.statusCode}');
    }
  } catch (e) {
    log('Error: $e');
  }
}

Future<dynamic> fetchChapterDetails(
    {required String mangaId, required String chapterId}) async {
  final url = 'https://ww8.mangakakalot.tv/chapter/$mangaId/$chapterId';
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

      final chapterListIds =
          target?.querySelectorAll('#c_chapter option').map((option) {
                return {
                  'id': option.attributes['value'] ?? '',
                  'name': option.text.trim(),
                };
              }).toList() ??
              [];

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
        'chapterListIds': chapterListIds,
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

Future<dynamic> scrapeMangaSearch(String id, {int page = 1}) async {
  final String query = "$id?page=$page";
  final String url = "$urlLink/search/$query";

  try {
    final response = await http.get(Uri.parse(url));

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

