import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

Future<void> addToAniList({
    required int mediaId,
    required String status,
    double? score,
    int? progress,
  }) async {
    const String url = 'https://graphql.anilist.co';
  const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'auth_token');
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    const String mutation = '''
    mutation SaveMediaListEntry(\$mediaId: Int!, \$status: MediaListStatus!, \$score: Float, \$progress: Int) {
      SaveMediaListEntry(mediaId: \$mediaId, status: \$status, score: \$score, progress: \$progress) {
        id
        status
        score
        progress
        media {
          id
          title {
            romaji
            english
          }
        }
      }
    }
  ''';

    final Map<String, dynamic> variables = {
      'mediaId': mediaId,
      'status': status,
      'score': score,
      'progress': progress,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'query': mutation, 'variables': variables}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Successfully added to list: ${data['data']['SaveMediaListEntry']}');
    } else {
      final error = jsonDecode(response.body);
      log('Error adding to list: ${error['errors']}');
    }
  }




Future<Uint8List?> fetchImageWithHeaders() async {
  try {
    final headers = {
      'Referer': 'https://mangareader.to/',
    };

    final response = await http.get(Uri.parse("https://c-1.mreadercdn.com/_v2/1/0dcb8f9eaacfd940603bd75c7c152919c72e45517dcfb1087df215e3be94206cfdf45f64815888ea0749af4c0ae5636fabea0abab8c2e938ab3ad7367e9bfa52/80/9b/809b160a72c64a6504d331ef4a04f527/809b160a72c64a6504d331ef4a04f527_1600.jpeg?t=515363393022bbd440b0b7d9918f291a&ttl=1908547557"), headers: headers);

    if (response.statusCode == 200) {
      log(response.bodyBytes.toString());
      return response.bodyBytes; // This is the raw image data
    } else {
      log('Failed to load image. Status code: ${response.statusCode}');
    }
  } catch (e) {
    log('Error fetching image: $e');
  }
  return null;
}
