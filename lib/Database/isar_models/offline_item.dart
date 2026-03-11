import 'package:isar_community/isar.dart';

import 'anime_details_data.dart';
import 'episode_class.dart';

part 'offline_item.g.dart';

@collection
class OfflineItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String number;

  String? animeTitle;

  AnilistMediaData? mediaData;

  List<Episode>? episodesList;

  List<Chapter>? chaptersList;

  OfflineItem({
    required this.number,
    this.animeTitle,
    this.mediaData,
    this.episodesList,
    this.chaptersList,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'animeTitle': animeTitle,
      'mediaData': mediaData?.toJson(),
      'episodesList': episodesList?.map((e) => e.toJson()).toList(),
      'chaptersList': chaptersList?.map((e) => e.toJson()).toList(),
    };
  }

  factory OfflineItem.fromJson(Map<String, dynamic> json) {
    return OfflineItem(
      number: json['number'],
      animeTitle: json['animeTitle'],
      mediaData: json['mediaData'] != null
          ? AnilistMediaData.fromJson(json['mediaData'])
          : null,
      episodesList: (json['episodesList'] as List?)
          ?.map((e) => Episode.fromJson(e))
          .toList(),
      chaptersList: (json['chaptersList'] as List?)
          ?.map((e) => Chapter.fromJson(e))
          .toList(),
    );
  }
}
