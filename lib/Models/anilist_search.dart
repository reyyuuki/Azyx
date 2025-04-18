class AnilistSearchData {
  int? id;
  String? title;
  String? image;
  String? coverImage;
  int? episodes;
  String? rating;
  String? type;
  String? status;

  AnilistSearchData({
    this.id,
    this.title,
    this.image,
    this.episodes,
    this.coverImage,
    this.rating,
    this.status,
    this.type
  });

  factory AnilistSearchData.fromJson(Map<String,dynamic> json,isManga){
    return AnilistSearchData(
      id: json['id'],
      title: json['title']['english'] ?? json['title']['romaji'] ?? json['title']['native'] ?? "Unknown title",
      image: json['coverImage']['large'] ?? "",
      coverImage: json['bannerImage'] ?? json['coverImage']['large'] ?? "",
      episodes: isManga ? json['chapters'] ?? 0 : json['episodes'] ?? 0,
      rating: json['averageScore'] != null ? (json['averageScore'] / 10).toString() : "N/A",
      status: json['status'] ?? "N/A",
      type: json['type'] ?? "N/A"
    );
  }
}