import 'package:azyx/Models/simkl.dart';

class UserAnime {
  String? title;
  String? image;
  String? status;
  String? rating;
  double? score;
  int? progress;
  int? episodes;
  String? id;
  String? totalEpisodes;
  String? type;
  String? medialistIds;

  UserAnime({
    this.id,
    this.image,
    this.title,
    this.totalEpisodes,
    this.type,
    this.rating,
    this.status,
    this.progress,
    this.score,
    this.episodes,
    this.medialistIds,
  });

  factory UserAnime.fromJson(Map<String, dynamic> data) {
    return UserAnime(
      id: data['media']['id'].toString(),
      title:
          data['media']['title']?['english'] ??
          data['media']['title']?['romaji'] ??
          "Unknown",
      image: data['media']['coverImage']['large'],
      rating: data['media']['averageScore'] != null
          ? ((data['media']['averageScore'] / 10) ?? 1).toString()
          : '0',
      progress: data['progress'],
      episodes: data['media']['episodes'] ?? data['media']['chapters'],
      score: data['score'] != null ? data['score'].toDouble() : 0.0,
      status: data['status'],
    );
  }
  factory UserAnime.fromSimklMovie(Map<String, dynamic> json) {
    final show = json['movie'];
    final ids = show['ids'] ?? {};
    return UserAnime(
      id: '${ids['simkl']}*MOVIE',
      title: show['title'],
      image: show['poster'] != null
          ? "https://wsrv.nl/?url=https://simkl.in/posters/${show['poster']}_m.jpg"
          : '?',
      progress: Simkl.simklMovieToAL(json['status']) != 'COMPLETED' ? 0 : 1,
      totalEpisodes: '1',
      status: Simkl.simklMovieToAL(json['status']),
      type: "movie",
      // mediaStatus: json['not_aired_episodes_count'] == 0
      //     ? "COMPLETED"
      //     : "AIRING",
      rating: null,
      score: null,
      medialistIds: '${ids['simkl']}*MOVIE',
    );
  }

  factory UserAnime.fromSimklShow(Map<String, dynamic> json) {
    final show = json['show'];
    final ids = show['ids'] ?? {};
    return UserAnime(
      id: '${ids['simkl']}*SERIES',
      title: show['title'],
      image: show['poster'] != null
          ? "https://wsrv.nl/?url=https://simkl.in/posters/${show['poster']}_m.jpg"
          : '?',
      progress: json['watched_episodes_count'] ?? 0,
      episodes: json['total_episodes_count'],
      status: Simkl.simklShowToAL(json['status']),
      type: "show",
      // mediaStatus: json['not_aired_episodes_count'] == 0
      //     ? "completed"
      //     : "airing",
      rating: null,
      score: null,
      // format: null,
      medialistIds: '${ids['simkl']}*SERIES',
    );
  }

  factory UserAnime.fromMAL(Map<String, dynamic> json) {
    return UserAnime(
      id: json['node']['id'].toString(),
      title: json['node']['title'],
      image: json['node']['main_picture']['large'],
      progress:
          json['list_status']?['num_chapters_read'] ??
          json['list_status']?['num_episodes_watched'] ??
          0,
      episodes:
          json['node']?['num_episodes'] ?? json['node']?['num_chapters'] ?? 0,
      rating: json['node']?['mean']?.toString() ?? '??',
      status: json['list_status']['status'],
      score: json['list_status']['score'].toDouble(),
    );
  }
}
