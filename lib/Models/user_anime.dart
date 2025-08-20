class UserAnime {
  String? title;
  String? image;
  String? status;
  String? rating;
  double? score;
  int? progress;
  int? episodes;
  int? id;

  UserAnime(
      {this.id,
      this.image,
      this.title,
      this.rating,
      this.status,
      this.progress,
      this.score,
      this.episodes});

  factory UserAnime.fromJson(Map<String, dynamic> data) {
    return UserAnime(
        id: data['media']['id'],
        title: data['media']['title']?['english'] ??
            data['media']['title']?['romaji'] ??
            "Unknown",
        image: data['media']['coverImage']['large'],
        rating: data['media']['averageScore'] != null
            ? ((data['media']['averageScore'] / 10) ?? 1).toString()
            : '0',
        progress: data['progress'],
        episodes: data['media']['episodes'] ?? data['media']['chapters'],
        score: data['score'] != null ? data['score'].toDouble() : 0.0,
        status: data['status']);
  }

  factory UserAnime.fromMAL(Map<String, dynamic> json) {
    return UserAnime(
      id: json['node']['id'],
      title: json['node']['title'],
      image: json['node']['main_picture']['large'],
      progress: json['list_status']?['num_chapters_read'] ??
          json['list_status']?['num_episodes_watched'] ??
          0,
      episodes:
          json['node']?['num_episodes'] ?? json['node']?['num_chapters'] ?? 0,
      rating: json['node']?['mean']?.toString() ?? '??',
      status: json['list_status']['status'],
      score: json['list_status']['score'],
      // mediaListId: json['node']['id']?.toString(),
    );
  }
}
