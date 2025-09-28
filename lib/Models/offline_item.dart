import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';

class OfflineItem {
  String number;
  AnilistMediaData mediaData;
  List<Episode>? episodesList;
  List<Chapter>? chaptersList;
  String? animeTitle;
  OfflineItem({
    required this.mediaData,
    required this.number,
    this.episodesList,
    this.chaptersList,
    this.animeTitle,
  });

  Map<dynamic, dynamic> toJson() {
    return {
      'number': number,
      'mediaData': mediaData.toJson(false),
      'animeTitle': animeTitle ?? '',
      'episodesList': episodesList?.map((e) => e.toJson()).toList(),
      'chaptersList': chaptersList?.map((e) => e.toJson()).toList(),
    };
  }

  factory OfflineItem.fromJson(Map<dynamic, dynamic> data, bool isManga) {
    return OfflineItem(
      mediaData: AnilistMediaData.fromJson(data['mediaData'], isManga),
      number: data['number'] ?? '',
      animeTitle: data['animeTitle'] ?? '',
      episodesList:
          (data['episodesList'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e, e['number'].toString()))
              .toList() ??
          [],
      chaptersList: data['chaptersList'] != null
          ? (data['chaptersList'] as List<dynamic>)
                .map((e) => Chapter.fromJson(e as Map<dynamic, dynamic>))
                .toList()
          : null,
    );
  }
}
