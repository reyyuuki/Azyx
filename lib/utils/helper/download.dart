import 'dart:developer';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> extractStreams(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception("Failed to load master playlist");
  }

  final content = response.body;
  final List<Map<String, dynamic>> streams = [];

  final regex = RegExp(
    r'#EXT-X-STREAM-INF:.*?BANDWIDTH=(\d+),RESOLUTION=(\d+x\d+),FRAME-RATE=([\d.]+),CODECS="([^"]+)"\n(.*.m3u8)',
    multiLine: true,
  );

  for (final match in regex.allMatches(content)) {
    final bandwidth = int.parse(match.group(1)!);
    final resolution = match.group(2)!;
    final frameRate = double.parse(match.group(3)!);
    final codecs = match.group(4)!;
    final url = match.group(5)!;

    String quality;
    if (resolution == "1920x1080") {
      quality = "1080p";
    } else if (resolution == "1280x720") {
      quality = "720p";
    } else if (resolution == "640x360") {
      quality = "360p";
    } else {
      quality = "unknown";
    }

    streams.add({
      "quality": quality,
      "resolution": resolution,
      "bandwidth": bandwidth,
      "frameRate": frameRate,
      "codecs": codecs,
      "url": url,
    });
  }

  log('Master playlist streams: ${streams[0]['url']}');
  return streams;
}

Future<List<String>> getSegmentLinks(String baseUrl, String link) async {
  final response = await http.get(Uri.parse('$baseUrl/$link'));
  if (response.statusCode != 200) {
    throw Exception("Failed to load segments");
  }

  return response.body
      .split('\n')
      .where((line) => line.isNotEmpty && !line.startsWith("#"))
      .map((line) => '$baseUrl/$line') // Prepend base URL for full path
      .toList();
}

String makeBaseUrl(String uri) =>
    uri.split('/').takeWhile((part) => !part.endsWith(".m3u8")).join('/');



Future<void> fetchAllSegments(String masterUrl) async {
  final streams = await extractStreams(masterUrl);
  final baseUrl = makeBaseUrl(masterUrl);
  final link = '$baseUrl/${streams[2]['url']}';
  log(link);
}
