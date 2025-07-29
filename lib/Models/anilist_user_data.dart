class User {
  String? name;
  int? id;
  String? avatar;
  int? animeCount;
  int? mangaCount;
  int? episodesWatched;
  int? minutesWatched;
  int? chaptersRead;

  User(
      {this.name,
      this.id,
      this.avatar,
      this.animeCount,
      this.mangaCount,
      this.episodesWatched,
      this.minutesWatched,
      this.chaptersRead});

  factory User.fromJson(dynamic data) {
    return User(
      name: data['name'],
      id: data['id'],
      avatar: data['avatar']['large'],
      animeCount: data['statistics']['anime']['count'],
      mangaCount: data['statistics']['manga']['count'],
      episodesWatched: data['statistics']['anime']['episodeWatched'],
      minutesWatched: data['statistics']['anime']['minutesWatched'],
      chaptersRead: data['statistics']['manga']['chaptersRead'],
    );
  }

  factory User.fromMAL(Map<String, dynamic> json) {
    final animeStats = json['data']?['statistics']['anime'];
    final mangaStats = json['data']?['statistics']['manga'];
    return User(
      id: json['data']?['mal_id'],
      name: json['data']?['username'],
      avatar: json['picture'] ??
          json['data']?['images']?['jpg']?['image_url'] ??
          json['data']?['images']?['webp']?['image_url'],
      animeCount: animeStats['count'],
      mangaCount: mangaStats['count'],
      episodesWatched: animeStats['episodeWatched'],
      minutesWatched: animeStats['minutesWatched'],
      chaptersRead: mangaStats['chaptersRead'],
    );
  }
}
