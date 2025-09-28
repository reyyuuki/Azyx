import 'package:azyx/utils/time_formater.dart';
import 'package:dartotsu_extension_bridge/Mangayomi/Eval/dart/model/m_chapter.dart';
import 'package:dartotsu_extension_bridge/Mangayomi/Eval/dart/model/m_manga.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:intl/intl.dart';

class Episode {
  String? title;
  String? url;
  String? date;
  String number;
  String? thumbnail;
  String desc;
  bool? filler;

  Episode({
    this.date,
    this.title,
    this.url,
    required this.number,
    this.thumbnail,
    required this.desc,
    this.filler,
  });

  factory Episode.fromJson(Map<dynamic, dynamic> data, String? number) {
    return Episode(
      title: data['name'] ?? "",
      url: data['url'] ?? "",
      number: number ?? data['number'],
      desc: data['desc'] ?? '',
      date: data['dateUpload'] != null
          ? formatDate(int.tryParse(data['dateUpload'] ?? 12) ?? 1)
          : data['dateUpload'] ?? "??",
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

Episode mChapterToEpisode(DEpisode chapter, DMedia? selectedMedia) {
  var episodeNumber = ChapterRecognition.parseChapterNumber(
    selectedMedia?.title ?? '',
    chapter.name ?? '',
  );
  return Episode(
    number: episodeNumber != -1 ? episodeNumber.toString() : chapter.name ?? '',
    url: chapter.url,
    title: chapter.name,
    thumbnail: null,
    desc: "",
    filler: false,
  );
}

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

List<Chapter> mChapterToChapter(List<DEpisode> chapters, String title) {
  return chapters.map((e) {
    return Chapter(
      title: e.name,
      link: e.url,
      scanlator: e.scanlator,
      number: ChapterRecognition.parseChapterNumber(title, e.name!).toDouble(),
      releaseDate: calcTime(e.dateUpload ?? ''),
    );
  }).toList();
}

String calcTime(String timestamp, {String format = "dd-MM-yyyy"}) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
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
}
