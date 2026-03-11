import 'package:azyx/Models/media.dart';

class MediaData {
  List<Media>? spotLightAnimes;
  List<Media>? popularAnimes;
  List<Media>? topUpcomingAnimes;
  List<Media>? completed;

  MediaData({
    this.spotLightAnimes,
    this.popularAnimes,
    this.topUpcomingAnimes,
    this.completed,
  });

  factory MediaData.fromJson(dynamic data) {
    return MediaData(
      spotLightAnimes: (data['trending']['media'] as List<dynamic>)
          .map((item) => Media.fromJson(item))
          .toList(),
      popularAnimes: (data['popular']['media'] as List<dynamic>)
          .map((item) => Media.fromJson(item))
          .toList(),
      topUpcomingAnimes: (data['latestReleasing']['media'] as List<dynamic>)
          .map((item) => Media.fromJson(item))
          .toList(),
      completed: (data['recentlyCompleted']['media'] as List<dynamic>)
          .map((item) => Media.fromJson(item))
          .toList(),
    );
  }
}
