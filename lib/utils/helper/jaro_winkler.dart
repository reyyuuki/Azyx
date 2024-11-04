import 'dart:developer';



double jaroWinklerDistance(String s1, String s2) {
  if (s1 == s2) return 1.0;
  final maxLength = [s1.length, s2.length].reduce((a, b) => a > b ? a : b);
  final matchWindow = (maxLength / 2).floor() - 1;
  final matches = <String>[];
  final s1Matches = List<bool>.filled(s1.length, false);
  final s2Matches = List<bool>.filled(s2.length, false);

  for (int i = 0; i < s1.length; i++) {
    final start = i - matchWindow >= 0 ? i - matchWindow : 0;
    final end = i + matchWindow + 1 < s2.length ? i + matchWindow + 1 : s2.length;

    for (int j = start; j < end; j++) {
      if (!s2Matches[j] && s1[i] == s2[j]) {
        s1Matches[i] = true;
        s2Matches[j] = true;
        matches.add(s1[i]);
        break;
      }
    }
  }

  if (matches.isEmpty) return 0.0;

  int t = 0;
  int k = 0;
  for (int i = 0; i < s1.length; i++) {
    if (s1Matches[i]) {
      while (!s2Matches[k]) k++;
      if (s1[i] != s2[k]) t++;
      k++;
    }
  }

  final m = matches.length.toDouble();
  final jaroSimilarity = (m / s1.length + m / s2.length + (m - t / 2) / m) / 3;
  int l = 0;
  while (l < s1.length && l < s2.length && s1[l] == s2[l] && l < 4) l++;

  return jaroSimilarity + (l * 0.1 * (1 - jaroSimilarity));
}


Future<Map<String, dynamic>?> searchMostSimilarManga(
    String query, Future<dynamic> Function(String) scrapeFunction) async {
  try {
    final result = await scrapeFunction(query);
    final mangaList = result['mangaList'] as List<dynamic>?;

    if (mangaList == null) {
      log('No manga data found.');
      return null;
    }

    Map<String, dynamic>? mostSimilarManga;
    double highestSimilarity = 0.0;

    log("Manga List: ${mangaList.toString()}");

    for (var manga in mangaList) {
      try {
        log("Processing manga item: ${manga.toString()}");

        // Check that `manga` is a Map with the expected keys and types
        if (manga is Map<String, dynamic> &&
            manga.containsKey('title') &&
            manga.containsKey('id') &&
            manga['title'] is String &&
            manga['id'] is String) {

          final title = manga['title'] as String;
          final id = manga['id'] as String;

          log("Manga title: $title, Manga ID: $id");

          if (title.isEmpty) {
            log("Warning: Title is empty for manga item: ${manga.toString()}");
            continue;
          }

          final similarity = jaroWinklerDistance(query, title);

          if (similarity > highestSimilarity) {
            highestSimilarity = similarity;
            mostSimilarManga = {
              'title': title,
              'similarity': similarity,
              'details': manga,
              'id': id
            };
          }
        } else {
          log("Error: Manga item does not have the expected structure or types: ${manga.toString()}");
        }
      } catch (e) {
        log("Error processing manga item: ${manga.toString()}, Error: $e");
      }
    }

    log("Most similar manga found: ${mostSimilarManga.toString()}");
    return mostSimilarManga;

  } catch (e, stackTrace) {
    log("Error in searchMostSimilarManga function: $e\n$stackTrace");
    return null;
  }
}

