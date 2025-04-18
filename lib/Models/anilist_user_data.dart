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

  factory User.fromJson(dynamic data){
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
}
