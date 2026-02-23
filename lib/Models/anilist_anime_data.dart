import 'package:azyx/Models/anime_class.dart';

class MediaData {
  List<Anime>? spotLightAnimes;
  List<Anime>? popularAnimes;
  List<Anime>? topUpcomingAnimes;
  List<Anime>? completed;

  MediaData({
    this.spotLightAnimes,
    this.popularAnimes,
    this.topUpcomingAnimes,
    this.completed,
  });

  factory MediaData.fromJson(dynamic data) {
    return MediaData(
      spotLightAnimes: (data['trending']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
      popularAnimes: (data['popular']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
      topUpcomingAnimes: (data['latestReleasing']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
      completed: (data['recentlyCompleted']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
    );
  }
}
