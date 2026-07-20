import 'dart:developer';
import 'package:isar_community/isar.dart';
import 'package:azyx/utils/time_formater.dart';
import 'package:intl/intl.dart';

part 'episode_class.g.dart';

@embedded
class Episode {
  String? title;
  String? url;
  String? date;
  String number = '';
  String? thumbnail;
  String desc = '';
  bool? filler;
  String? season;
  String? type;
  List<String>? sortKeys;
  List<String>? sortVals;

  Episode({
    this.date,
    this.title,
    this.url,
    this.number = '',
    this.thumbnail,
    this.desc = '',
    this.filler,
    this.season,
    this.type,
    this.sortKeys,
    this.sortVals,
  });

  factory Episode.fromJson(Map<dynamic, dynamic> data) {
    final rawSortKeys = data['sortKeys'] as List<dynamic>?;
    final rawSortVals = data['sortVals'] as List<dynamic>?;

    return Episode(
      title: data['name'] ?? "",
      url: data['url'] ?? "",
      number: data['number'] ?? '',
      desc: data['desc'] ?? '',
      date: data['dateUpload'] != null
          ? formatDate(
              num.tryParse(data['dateUpload'].toString())?.toInt() ?? 1,
            )
          : data['dateUpload']?.toString() ?? "??",
      thumbnail: data['thumbnail'],
      filler: data['filler'],
      season: data['season']?.toString(),
      type: data['type']?.toString(),
      sortKeys: rawSortKeys?.map((e) => e.toString()).toList(),
      sortVals: rawSortVals?.map((e) => e.toString()).toList(),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'name': title ?? '',
      'url': url ?? '',
      'dateUpload': date ?? '',
      'number': number,
      'thumbnail': thumbnail ?? '',
      'desc': desc,
      'filler': filler,
      'season': season,
      'type': type,
      'sortKeys': sortKeys,
      'sortVals': sortVals,
    };
  }
}

extension EpisodeMap on Episode {
  Map<String, String> get sortMap {
    if (sortKeys == null || sortVals == null) return {};
    if (sortKeys!.isEmpty || sortVals!.isEmpty) return {};

    final pairCount = sortKeys!.length < sortVals!.length
        ? sortKeys!.length
        : sortVals!.length;
    if (pairCount == 0) return {};

    return Map<String, String>.fromIterables(
      sortKeys!.take(pairCount),
      sortVals!.take(pairCount),
    );
  }

  /// Returns sortMap with empty-value entries removed, or null if nothing meaningful remains.
  /// Use this when building a DEpisode to avoid triggering broken mapper API paths.
  Map<String, String>? get effectiveSortMap {
    final map = Map<String, String>.from(sortMap)
      ..removeWhere((_, v) => v.isEmpty);
    return map.isEmpty ? null : map;
  }
}

@embedded
class Chapter {
  String? title;
  String? link;
  String? scanlator;
  double? number;
  String? releaseDate;

  Chapter({
    this.link,
    this.number,
    this.releaseDate,
    this.scanlator,
    this.title,
  });

  factory Chapter.fromJson(Map<dynamic, dynamic> json) {
    return Chapter(
      title: json['title'],
      link: json['link'],
      scanlator: json['scanlator'],
      number: (json['number'] as num?)?.toDouble(),
      releaseDate: json['releaseDate'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'scanlator': scanlator,
      'number': number,
      'releaseDate': releaseDate,
    };
  }
}

class ChapterRecognition {
  static const _numberPattern = r"([0-9]+)(\.[0-9]+)?(\.?[a-z]+)?";

  static final _unwanted = RegExp(
    r"\b(?:v|ver|vol|version|volume|season|s)[^a-z]?[0-9]+",
  );

  static final _unwantedWhiteSpace = RegExp(r"\s(?=extra|special|omake)");

  static dynamic parseChapterNumber(String mangaTitle, String chapterName) {
    var name = chapterName.toLowerCase();

    name = name.replaceAll(mangaTitle.toLowerCase(), "").trim();

    name = name.replaceAll(',', '.').replaceAll('-', '.');

    name = name.replaceAll(_unwantedWhiteSpace, "");

    name = name.replaceAll(_unwanted, "");

    final episodeMatch = RegExp(r"e(\d+)").firstMatch(name);
    if (episodeMatch != null) {
      return int.parse(episodeMatch.group(1)!);
    }

    const numberPat = "*$_numberPattern";
    const ch = r"(?<=ch\.)";
    var match = RegExp("$ch $numberPat").firstMatch(name);
    if (match != null) {
      return _convertToIntIfWhole(_getChapterNumberFromMatch(match));
    }

    match = RegExp(_numberPattern).firstMatch(name);
    if (match != null) {
      return _convertToIntIfWhole(_getChapterNumberFromMatch(match));
    }

    return 0;
  }

  static dynamic _convertToIntIfWhole(double value) {
    return value % 1 == 0 ? value.toInt() : value;
  }

  static double _getChapterNumberFromMatch(Match match) {
    final initial = double.parse(match.group(1)!);
    final subChapterDecimal = match.group(2);
    final subChapterAlpha = match.group(3);
    final addition = _checkForDecimal(subChapterDecimal, subChapterAlpha);
    return initial + addition;
  }

  static double _checkForDecimal(String? decimal, String? alpha) {
    if (decimal != null && decimal.isNotEmpty) {
      return double.parse(decimal);
    }

    if (alpha != null && alpha.isNotEmpty) {
      if (alpha.contains("extra")) {
        return 0.99;
      }
      if (alpha.contains("omake")) {
        return 0.98;
      }
      if (alpha.contains("special")) {
        return 0.97;
      }
      final trimmedAlpha = alpha.replaceFirst('.', '');
      if (trimmedAlpha.length == 1) {
        return _parseAlphaPostFix(trimmedAlpha[0]);
      }
    }

    return 0.0;
  }

  static double _parseAlphaPostFix(String alpha) {
    final number = alpha.codeUnitAt(0) - ('a'.codeUnitAt(0) - 1);
    if (number >= 10) return 0.0;
    return number / 10.0;
  }
}

List<Chapter> mChapterToChapter(List<dynamic> chapters, String title) {
  return chapters.map((e) {
    String? eName;
    try {
      eName = e.name;
    } catch (_) {
      try {
        eName = e.title;
      } catch (_) {
        eName = null;
      }
    }

    return Chapter(
      title: eName,
      link: e.url,
      scanlator: e.scanlator,
      number: ChapterRecognition.parseChapterNumber(
        title,
        eName ?? '',
      ).toDouble(),
      releaseDate: calcTime(e.dateUpload ?? ''),
    );
  }).toList();
}

Episode mChapterToEpisode(dynamic item, dynamic episodeResult) {
  String? itemNumber;
  try {
    itemNumber = item.number?.toString();
  } catch (_) {
    itemNumber = null;
  }

  if (itemNumber == null || itemNumber.isEmpty) {
    try {
      itemNumber = item.episodeNumber;
    } catch (_) {}
  }

  String? itemName;
  try {
    itemName = item.name;
  } catch (_) {
    try {
      itemName = item.title;
    } catch (_) {
      itemName = null;
    }
  }

  String? episodeResultName;
  try {
    episodeResultName = episodeResult.name;
  } catch (_) {
    try {
      episodeResultName = episodeResult.title;
    } catch (_) {
      episodeResultName = null;
    }
  }

  String? season;
  String? type;
  List<String>? sortKeys;
  List<String>? sortVals;
  try {
    final rawSortMap = item.sortMap as Map<String, String>?;
    log('[EpisodeMap] DEpisode.sortMap = $rawSortMap (url=${item.url})');
    if (rawSortMap != null && rawSortMap.isNotEmpty) {
      sortKeys = rawSortMap.keys.toList();
      sortVals = rawSortMap.values.toList();
    }
    season = rawSortMap?['season']?.toString();
    type = rawSortMap?['type']?.toString();
    log('[EpisodeMap] Stored sortKeys=$sortKeys sortVals=$sortVals');
  } catch (e) {
    log('[EpisodeMap] ERROR reading sortMap: $e');
  }

  return Episode(
    title: itemName,
    url: item.url,
    number: (itemNumber != null && itemNumber.isNotEmpty)
        ? itemNumber
        : ChapterRecognition.parseChapterNumber(
            episodeResultName ?? '',
            itemName ?? '',
          ).toString(),
    desc: item.scanlator ?? '',
    thumbnail: item.thumbnail,
    season: season,
    type: type,
    sortKeys: sortKeys,
    sortVals: sortVals,
  );
}

String calcTime(dynamic timestamp, {String format = "dd-MM-yyyy"}) {
  if (timestamp == null) return '';
  final String tsStr = timestamp.toString().trim();
  if (tsStr.isEmpty) return '';
  final parsedNum = num.tryParse(tsStr);
  if (parsedNum == null) {
    return tsStr;
  }
  final parsed = parsedNum.toInt();
  try {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(parsed);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays <= 14) {
      if (difference.inDays == 0) {
        if (difference.inHours < 1) {
          return "${difference.inMinutes} minutes ago";
        }
        return "${difference.inHours} hours ago";
      }
      return "${difference.inDays} days ago";
    }

    return DateFormat(format).format(dateTime);
  } catch (_) {
    return tsStr;
  }
}
