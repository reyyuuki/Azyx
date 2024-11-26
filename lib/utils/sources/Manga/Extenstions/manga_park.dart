// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;

// Future<dynamic> fetchChapters(String mangaId) async {
//   try {
//     final chapters = <Map<String, String>>[];
//     final url = "https://mangapark.net/comic/124815/magic-emperor";
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final document = parser.parse(response.body);
//       final chaptersElements = document.querySelectorAll("#chap-index .episode-item");
//       if (chaptersElements.isNotEmpty) {
//         for (var chapter in chaptersElements) {
//           final title = chapter.querySelector(".d-flex a sapn b")?.text.trim() ??
//               "Unknown Title";
//           final link =
//               chapter.querySelector(".d-flex a")?.attributes['href'] ?? "";
//           final date =
//               chapter.querySelector('.ms-auto i')?.text.trim();

//           chapters.add({
//             "title": "Chapter $title",
//             "link": link,
//             "date": date ?? "??",
//             "id": link.split("/").last
//           });
//         }
//         log(chapters.toString());
//         return {"chapterList": chapters};
//       }
//     }
//   } catch (e, stackTrace) {
//     log("Error in MangaPark chapters scraping: $e",
//         error: e, stackTrace: stackTrace);
//   }
// }

// Future<dynamic> fetchPages(String link) async {
//   int index = 0;
//   try {
//     List<Map<String,String>> totalImages = [];
//     final url = "https://mangapark.net$link";
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final document = parser.parse(response.body);
//       final images =
//           document.querySelectorAll(".space-y-5 div div");
//       //     .map((img) {
//       //   final imageUrl = img.querySelector("div img")?.attributes['src'] ?? "";
//       //   index++;
//       //   return {"image": imageUrl};
//       // }).toList();
//   if(images.isNotEmpty){
//     for(var image in images){
//       index++;
//       final img = image.querySelector("div img")?.attributes['src'] ?? "";
//         totalImages.add({
//           "image":img
//         });
//     }
//   }

//       final title =
//           document.querySelector(".comic-detail .text-xl a")?.text.trim() ??
//               "Unknown Title";
//       final currentChapter = document
//               .querySelector(".comic-detail .text-lg a span")
//               ?.text
//               .trim() ??
//           "Unknown Chapter";

//       final navLinks = document.querySelectorAll(".grow a");
//       String? nextChapterId;
//       String? prevChapterId;
//       for (var link in navLinks) {
//         final spanText = link.querySelector("span")?.text;
//         if (spanText?.contains("Next") ?? false) {
//           nextChapterId = link.attributes['href'];
//         } else if (spanText?.contains("Prev") ?? false) {
//           prevChapterId = link.attributes['href'];
//         }
//       }

//       final result = {
//         'title': title,
//         'currentChapter': currentChapter,
//         'images': totalImages,
//         'totalImages': index,
//         'nextChapter': nextChapterId,
//         'previousChapter': prevChapterId,
//         'link': link,
//       };
//       log(result.toString());
//       return result;
//     }
//   } catch (e, stackTrace) {
//     log("Error in MangaPark chapters pages scraping: $e",
//         error: e, stackTrace: stackTrace);
//   }
//   return {};
// }
