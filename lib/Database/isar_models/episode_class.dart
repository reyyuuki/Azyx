import 'package:isar_community/isar.dart';

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

  Episode({
    this.date,
    this.title,
    this.url,
    this.number = '',
    this.thumbnail,
    this.desc = '',
    this.filler,
  });

  factory Episode.fromJson(Map<dynamic, dynamic> data) {
    return Episode(
      title: data['name'] ?? "",
      url: data['url'] ?? "",
      number: data['number'] ?? '',
      desc: data['desc'] ?? '',
      date: data['dateUpload'] ?? "??",
      thumbnail: data['thumbnail'],
      filler: data['filler'],
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
