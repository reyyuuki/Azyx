import 'dart:developer';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> extractStreams(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception("Failed to load master playlist");
  }

  final content = response.body;
  final List<Map<String, dynamic>> streams = [];

  log(content); // Log the content to inspect

  // Updated regex to match both formats
  final regex = RegExp(
    r'#EXT-X-STREAM-INF:.*?BANDWIDTH=(\d+),RESOLUTION=(\d+x\d+)(?:,NAME="([^"]+)")?(?:,FRAME-RATE=([\d.]+),CODECS="([^"]+)")?\n(.*\.m3u8)',
    multiLine: true,
  );

  // Loop through each match of the regex in the playlist content
  for (final match in regex.allMatches(content)) {
    final bandwidth = int.parse(match.group(1)!);
    final resolution = match.group(2)!;
    final name = match.group(3); // Optional, used for Anivibe source
    final frameRate = match.group(4); // Optional, can be null
    final codecs = match.group(5); // Optional, can be null
    final streamUrl = match.group(6)!;

    // Determine the quality based on resolution or name
    String quality;
    if (name != null) {
      quality = name; // If the 'NAME' field exists (like Anivibe)
    } else {
      if (resolution == "1920x1080") {
        quality = "1080p";
      } else if (resolution == "1280x720") {
        quality = "720p";
      } else if (resolution == "854x480") {
        quality = "480p";
      } else if (resolution == "640x360") {
        quality = "360p";
      } else {
        quality = "unknown";
      }
    }

    // Create the stream data
    final streamData = {
      "quality": quality,
      "resolution": resolution,
      "bandwidth": bandwidth,
      "frameRate": frameRate, // Will be null if absent
      "codecs": codecs, // Will be null if absent
      "url": streamUrl,
    };

    // Add the stream data to the list
    streams.add(streamData);
  }

  log('Master playlist streams: $streams');
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
