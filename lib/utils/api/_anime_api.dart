import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

var box = Hive.box("app-data");
bool isConsumet = box.get("isConsumet", defaultValue: false);
String proxy = dotenv.get("PROXY_URL");
String aniwatchUrl = dotenv.get("HIANIME_URL");
String consumetUrl = dotenv.get("CONSUMET_URL");

Future<dynamic> fetchHomePageData() async {
  try {
    final response = await http.get(Uri.parse('$proxy$aniwatchUrl/home'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  } catch (error) {
    log('$error');
    return;
  }
}


Future<dynamic>? fetchAnimeDetailsConsumet(String id) async {
  try {
    final resp = await http.get(Uri.parse('$proxy${consumetUrl}info/$id'));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data;
    } else {
      log('Failed to fetch data: ${resp.statusCode}');
      return null;
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<dynamic> fetchAnimeDetailsAniwatch(String id) async {
  try {
    final resp = await http.get(Uri.parse('$proxy${aniwatchUrl}info?id=$id'));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data;
    } else {
      log('Failed to fetch data: ${resp.statusCode}');
      return null;
    }
  } catch (e) {
    log('Error fetching anime details: $e');
    return null;
  }
}

Future<dynamic>? fetchSearchesAniwatch(String id) async {}
Future<dynamic>? fetchSearchesConsumet(String id) async {}
Future<dynamic>? fetchStreamingDataConsumet(String id) async {
  final resp = await http.get(Uri.parse('$proxy${consumetUrl}episodes/$id'));
  if (resp.statusCode == 200) {
    final tempData = jsonDecode(resp.body);
    return tempData;
  }
}

Future<dynamic>? fetchStreamingDataAniwatch(String id) async {
  final resp = await http.get(Uri.parse('$proxy${aniwatchUrl}episodes/$id'));
  if (resp.statusCode == 200) {
    final tempData = jsonDecode(resp.body);
    return tempData;
  }
}

Future<dynamic> fetchStreamingLinksAniwatch(
    String id, String server, String category) async {
  try {
    final url =
        '${aniwatchUrl}episode-srcs?id=$id?server=$server&category=$category';
        log('${aniwatchUrl}episode-srcs?id=$id?server=$server&category=$category');
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final tempData = jsonDecode(resp.body);
      return tempData;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<dynamic>? fetchStreamingLinksConsumet(String id) async {
  final resp = await http.get(Uri.parse('$proxy${consumetUrl}watch/$id'));
  if (resp.statusCode == 200) {
    final tempData = jsonDecode(resp.body);
    return tempData;
  }
}


Future extractLinks(imageClass, titleClass, idClass) async {
  const url = 'https://hianime.to/home'; 

  final response = await http.Client().get(Uri.parse(url));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);

    try {
      dynamic items = [];

      var imageElements = document.getElementsByClassName(imageClass);
      var titleElements = document.getElementsByClassName(titleClass);
      var idElements = document.getElementsByClassName(idClass);
    
       int itemCount = imageElements.length < titleElements.length
          ? imageElements.length
          : titleElements.length;
      
      for (var i = 0; i < itemCount; i++) {
        String? imagelink = imageElements[i].children[0].attributes['data-src']; 
        String title = titleElements[i].children[1].text.trim();
        String? id = idElements[i].attributes['href'];

        if (imagelink != null && id != null) {
          items.add({
            'name': title,
            'poster': imagelink,
            'id': id,
            'rank': i,
          });
        }
      }

      return items;
    } catch (e) {
      log('Error: $e');
    }
  } else {
    log('Failed to load website: Status code ${response.statusCode}');
    return [{'error': 'ERROR: ${response.statusCode}.'}];
  }
}

