class UserAnime {
  String? tilte;
  String? image;
  String? status;
  String? rating;
  int? progress;
  int? episodes;
  int? id;

  UserAnime(
      {this.id,
      this.image,
      this.tilte,
      this.rating,
      this.status,
      this.progress,
      this.episodes});

  factory UserAnime.fromJson(Map<String, dynamic> data) {
    return UserAnime(
        id: data['media']['id'],
        tilte: data['media']['title']?['english'] ?? data['media']['title']?['romaji'] ?? "Unknown",
        image: data['media']['coverImage']['large'],
        rating: ((data['media']['averageScore'] / 10) ?? 1).toString(),
        progress: data['media']['progress'],
        episodes: data['media']['epiosdes'],
        status: data['status']);
  }
}
