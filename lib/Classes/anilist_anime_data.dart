import 'package:azyx/Classes/anime_class.dart';

class AnilistAnimeData {
  List<Anime>? spotLightAnimes;
  List<Anime>? popularAnimes;
  List<Anime>? topUpcomingAnimes;
  List<Anime>? completed;

  AnilistAnimeData({
    this.spotLightAnimes,
    this.popularAnimes,
    this.topUpcomingAnimes,
    this.completed,
  });

  factory AnilistAnimeData.fromJson(dynamic data) {
    return AnilistAnimeData(
      spotLightAnimes: (data['trending']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
      popularAnimes:
          (data['popular']['media'] as List<dynamic>).map((item) => Anime.fromJson(item)).toList(),
      topUpcomingAnimes: (data['latestReleasing']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
      completed: (data['recentlyCompleted']['media'] as List<dynamic>)
          .map((item) => Anime.fromJson(item))
          .toList(),
    );
  }
}
