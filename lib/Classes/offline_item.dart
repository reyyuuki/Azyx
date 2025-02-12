import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Classes/episode_class.dart';

class OfflineItem {
  String number;
  AnilistMediaData mediaData;
  List<Episode> episodesList;
  String? animeTitle;
  OfflineItem(
      {required this.mediaData,
      required this.number,
      required this.episodesList,
      this.animeTitle});

  Map<dynamic, dynamic> toJson() {
    return {
      'number': number,
      'mediaData': mediaData.toJson(false),
      'animeTitle': animeTitle ?? '',
      'episodesList': episodesList.map((e) => e.toJson()).toList()
    };
  }

  factory OfflineItem.fromJson(Map<dynamic, dynamic> data) {
    return OfflineItem(
      mediaData: AnilistMediaData.fromJson(data['mediaData'], false),
      number: data['number'] ?? '',
      animeTitle: data['animeTitle'] ?? '',
      episodesList: (data['episodesList'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e, e['number'].toString()))
              .toList() ??
          [],
    );
  }
}
