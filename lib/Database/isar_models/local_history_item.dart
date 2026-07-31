import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:isar_community/isar.dart';
part 'local_history_item.g.dart';

@collection
class LocalHistoryItem {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  int? mediaId;
  String? link;
  String? title;
  String? progress;
  String? image;
  String? sourceName;
  String? sourceId;
  int? lastTimeSeconds;
  int? totalDurationSeconds;
  int? currentTimeSeconds;
  int? currentPage;
  DateTime? lastWatched;
  @Enumerated(EnumType.ordinal32)
  HistoryMediaType? mediaType;
  AnilistMediaData? mediaData;
  List<Chapter>? chapterList;
  List<Episode>? episodeList;
  String? episodeUrlsJson;
  String? mangaSourceJson;

  LocalHistoryItem();

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'link': link,
      'title': title,
      'progress': progress,
      'image': image,
      'sourceName': sourceName,
      'sourceId': sourceId,
      'lastTimeSeconds': lastTimeSeconds,
      'totalDurationSeconds': totalDurationSeconds,
      'currentTimeSeconds': currentTimeSeconds,
      'currentPage': currentPage,
      'lastWatched': lastWatched?.toIso8601String(),
      'mediaType': mediaType?.index,
      'mediaData': mediaData?.toJson(),
      'chapterList': chapterList?.map((e) => e.toJson()).toList(),
      'episodeList': episodeList?.map((e) => e.toJson()).toList(),
      'episodeUrlsJson': episodeUrlsJson,
      'mangaSourceJson': mangaSourceJson,
    };
  }

  factory LocalHistoryItem.fromJson(Map<String, dynamic> json) {
    return LocalHistoryItem()
      ..mediaId = json['mediaId']
      ..link = json['link']
      ..title = json['title']
      ..progress = json['progress']
      ..image = json['image']
      ..sourceName = json['sourceName']
      ..sourceId = json['sourceId']
      ..lastTimeSeconds = json['lastTimeSeconds']
      ..totalDurationSeconds = json['totalDurationSeconds']
      ..currentTimeSeconds = json['currentTimeSeconds']
      ..currentPage = json['currentPage']
      ..lastWatched = json['lastWatched'] != null ? DateTime.tryParse(json['lastWatched']) : null
      ..mediaType = json['mediaType'] != null && json['mediaType'] is int && json['mediaType'] < HistoryMediaType.values.length
          ? HistoryMediaType.values[json['mediaType']]
          : null
      ..mediaData = json['mediaData'] != null ? AnilistMediaData.fromJson(json['mediaData']) : null
      ..chapterList = (json['chapterList'] as List?)?.map((e) => Chapter.fromJson(e)).toList()
      ..episodeList = (json['episodeList'] as List?)?.map((e) => Episode.fromJson(e)).toList()
      ..episodeUrlsJson = json['episodeUrlsJson']
      ..mangaSourceJson = json['mangaSourceJson'];
  }
}

enum HistoryMediaType { anime, manga }
