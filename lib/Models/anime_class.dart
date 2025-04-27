import 'dart:developer';

class Anime {
  String? title;
  String? image;
  String? bannerImage;
  String? description;
  String? rating;
  String? status;
  int? id;
  String? type;
  int? episodes;
  List<String>? genres;
  Anime(
      {this.id,
      this.image,
      this.title,
      this.description,
      this.rating,
      this.bannerImage,
      this.episodes,
      this.type,
      this.status,
      this.genres});

  factory Anime.fromJson(Map<dynamic, dynamic> data) {
    return Anime(
      id: data['id'],
      title: data['title']?['english'] ?? data['title']?['romaji'] ?? "Unknown",
      image: data['coverImage']?['large'] ?? "N/A",
      bannerImage: data['bannerImage'] ?? data['coverImage']?['large'] ?? '',
      description: data['description'] ?? "N/A",
      status: data['status'] ?? "",
      type: data['type'],
      episodes: data['episodes'] ?? data['chapters'],
      rating: data['averageScore'] != null
          ? (data['averageScore'] / 10).toStringAsFixed(1)
          : "5.0",
    );
  }

  factory Anime.fromJsonToHive(Map<String, dynamic> data) {
    return Anime(
      id: data['id'],
      title: data['title']['english'] ?? data['title']['romaji'],
      image: data['coverImage']['large'] ?? "N/A",
      bannerImage: data['bannerImage'] ?? "",
      description: data['description'] ?? "N/A",
      status: data['status'],
      rating: data['averageScore']?.toString() ?? "5.0",
      type: data['type'] ?? "",
      episodes: data['episodes'],
    );
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
      'averageScore': rating != null ? double.tryParse(rating!) ?? 5.0 : 5.0,
      'type': type,
      'episodes': episodes,
    };
  }
}
