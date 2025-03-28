import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/video.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';

class AnimeAllData {
  String? url;
  String? episodeTitle;
  String? title;
  String? image;
  String? number;
  int? id;
  List<Video>? episodeUrls;
  List<Episode>? episodeList;
  Source? source;

  AnimeAllData(
      {this.episodeList,
      this.episodeTitle,
      this.episodeUrls,
      this.number,
      this.id,
      this.source,
      this.title,
      this.image,
      this.url});

  factory AnimeAllData.fromJson(Map<dynamic, dynamic> json) {
    return AnimeAllData(
      url: json['url'] as String?,
      episodeTitle: json['episodeTitle'] as String?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      number: json['number'] as String?,
      id: json['id'] as int?,
      episodeUrls: (json['episodeUrls'] as List<dynamic>?)
          ?.map((e) => Video.fromJson(e as Map<dynamic, dynamic>))
          .toList(),
      episodeList: (json['episodeList'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<dynamic, dynamic>, ""))
          .toList(),
      source: json['source'] != null
          ? Source.fromJson(json['source'] as Map<dynamic, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'episodeTitle': episodeTitle,
      'title': title,
      'image': image,
      'number': number,
      'id': id,
      'episodeUrls': episodeUrls?.map((e) => e.toJson()).toList(),
      'episodeList': episodeList?.map((e) => e.toJson()).toList(),
      'source': source?.toJson(),
    };
  }
}
