import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';

class LocalHistory {
  int? mediaId;
  String? link;
  String? title;
  String? progress;
  String? image;
  Duration? lastTime;
  Duration? totalDuration;
  Duration? currentTime;
  int? currentPage;
  AnimeAllData? animeData;
  Source? source;
  List<Chapter>? chapterList;

  LocalHistory({
    this.animeData,
    this.mediaId,
    this.chapterList,
    this.image,
    this.link,
    this.progress,
    this.source,
    this.currentPage,
    this.currentTime,
    this.totalDuration,
    this.lastTime,
    this.title,
  });

  factory LocalHistory.fromJson(Map<dynamic, dynamic> json) {
    return LocalHistory(
      mediaId: json['mediaId'] as int?,
      link: json['link'] as String?,
      title: json['title'] as String?,
      progress: json['progress'] as String?,
      image: json['image'] as String?,
      lastTime: json['lastTime'] != null
          ? Duration(seconds: json['lastTime'] as int)
          : null,
      totalDuration: json['totalDuration'] != null
          ? Duration(seconds: json['totalDuration'] as int)
          : null,
      currentTime: json['currentTime'] != null
          ? Duration(seconds: json['currentTime'] as int)
          : null,
      currentPage: json['currentPage'] as int?,
      animeData: json['animeData'] != null
          ? AnimeAllData.fromJson(json['animeData'] as Map<String, dynamic>)
          : null,
      source: json['source'] != null
          ? Source.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      chapterList: json['chapterList'] != null
          ? (json['chapterList'] as List<dynamic>)
                .map((e) => Chapter.fromJson(e as Map<dynamic, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'link': link,
      'title': title,
      'progress': progress,
      'image': image,
      'lastTime': lastTime?.inSeconds,
      'totalDuration': totalDuration?.inSeconds,
      'currentTime': currentTime?.inSeconds,
      'currentPage': currentPage,
      'animeData': animeData?.toJson(),
      'source': source?.toJson(),
      'chapterList': chapterList?.map((e) => e.toJson()).toList(),
    };
  }
}
