import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';

class AsuraScans implements ExtractClass {
  @override
  Future<dynamic> fetchChapters(String mangaId) async {
    try {
      List<Map<String, String>> chapters = [];
      const url = "https://asuracomic.net/series/nano-machine-453dcdeb";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final title =
            document.querySelector(".text-center .text-xl")?.text.trim();
        final chaptersElement =
            document.querySelectorAll(".overflow-y-auto div");
        if (chaptersElement.isNotEmpty) {
          for (var chapter in chaptersElement) {
            final title = chapter.querySelector("a")?.text.trim() ?? "";
            final subTitle = chapter.querySelector('a span')?.text.trim() ?? "";
            final date = chapter.querySelector('h3.text-xs')?.text.trim() ?? "";
            final link = chapter.querySelector("a")?.attributes['href'];
            if (link != null) {
              chapters.add(
                  {"title": '$title $subTitle', "date": date, "link": link});
            }
          }
          log(chapters.toString());
          return {"chapterList": chapters, "title": title};
        }
      }
    } catch (e) {
      log("error in asura scans when fetching chapters: $e ");
    }
  }

  @override
  Future<dynamic> fetchPages(String link) async {
    try {
      List<Map<String, String>> images = [];
      const url =
          "https://asuracomic.net/series/nano-machine-453dcdeb/chapter/233";
      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Connection': 'keep-alive'
      };
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final imagesElement = document
            .querySelectorAll("div.w-full.mx-auto.center img.object-cover")
            .map((img) {
          final image = img.attributes['src'] ?? "";
          return {"image": image};
        }).toList();

        log(imagesElement.toString());

        final title = document.querySelector(".flex-wrap a h3")?.text.trim();
        // log(response.body);
      }
    } catch (e) {
      log("error in scraping pages: $e");
    }
  }

  @override
  Future<dynamic> fetchSearchsManga(String name) async{
   try{
   const url =
          "https://asuracomic.net/series?page=1&name=solo";
      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Connection': 'keep-alive'
      };
      final response = await http.get(Uri.parse(url), headers: headers);
      if(response.statusCode == 200){

      }
   }catch(e){
    log("error when fetching search results: $e");
   }
  }


Future<void> fetchApiData() async {
  try {
    // API URL
    final url = Uri.parse('https://hb-api.omnitagjs.com/hb-api/prebid/v1?RefererUrl=https%3A%2F%2Fasuracomic.net%2Fseries%2Fsolo-max-level-newbie-1e637aa8%2Fchapter%2F181&PublisherDomain=https%3A%2F%2Fasuracomic.net');

    // Make the GET request
    final response = await http.get(url);

    // Check for successful response
    if (response.statusCode == 200) {
      log('Response body: ${response.body}'); // Log the response content
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    log('Error: $e');
  }
}


  @override
  // TODO: implement sourceName
  String get sourceName => throw UnimplementedError();

  @override
  // TODO: implement sourceVersion
  String get sourceVersion => throw UnimplementedError();

  @override
  // TODO: implement url
  String? get url => throw UnimplementedError();
}
