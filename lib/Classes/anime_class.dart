class Anime {
  String? title;
  String? image;
  String? bannerImage;
  String? description;
  String? rating;
  String? status;
  int? id;

  Anime(
      {this.id,
      this.image,
      this.title,
      this.description,
      this.rating,
      this.bannerImage,
      this.status});

  factory Anime.fromJson(Map<dynamic, dynamic> data) {
    return Anime(
        id: data['id'],
        title: data['title']['english'] ?? data['title']['romaji'],
        image: data['coverImage']['large'] ?? "N/A",
        description: data['description'] ?? "N/A",
        bannerImage: data['bannerImage'] ?? data['coverImage']['large'],
        status: data['status'],
        rating: data['averageScore'] != null
            ? (data['averageScore'] / 10).toString()
            : "5.0");
  }

  factory Anime.fromJsonToHive(Map<String, dynamic> data) {
    return Anime(
        id: data['id'],
        title: data['title']['english'] ?? data['title']['romaji'],
        image: data['coverImage']['large'] ?? "N/A",
        description: data['description'] ?? "N/A",
        bannerImage: data['bannerImage'] ?? "",
        status: data['status'],
        rating: data['averageScore'] ?? "5.0");
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': {
        'english': title,
        'romaji': title,
      },
      'coverImage': {
        'large': image,
      },
      'description': description,
      'bannerImage': bannerImage,
      'status': status,
      'averageScore': double.parse(rating!),
    };
  }
}
