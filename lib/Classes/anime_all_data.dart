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

  factory AnimeAllData.fromJson(
      String url,
      String episodeTitle,
      String title,
      String number,
      String image,
      int id,
      List<Video> episodeUrls,
      List<Episode> episodeList,
      Source source) {
    return AnimeAllData(
        url: url,
        episodeTitle: episodeTitle,
        title: title,
        number: number,
        id: id,
        image: image,
        episodeUrls: episodeUrls,
        episodeList: episodeList);
  }
}
