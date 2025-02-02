import 'package:azyx/Classes/anime_class.dart';

class DetailsData {
  int? id;
  String? title;
  String? japaneseTitle;
  String? description;
  String? image;
  String? coverImage;
  String? rating;
  String? premiered;
  String? type;
  String? season;
  String? duration;
  String? quality;
  String? status;
  String? aired;
  int? popularity;
  int? timeUntilAiring;
  List<String>? studios;
  List<String>? genres;
  List<Anime>? relations;
  List<Anime>? recommendations;
  List<Character>? characters;

  DetailsData({
    this.id,
    this.title,
    this.japaneseTitle,
    this.description,
    this.image,
    this.coverImage,
    this.rating,
    this.premiered,
    this.type,
    this.season,
    this.duration,
    this.quality,
    this.status,
    this.aired,
    this.popularity,
    this.timeUntilAiring,
    this.studios,
    this.genres,
    this.relations,
    this.recommendations,
    this.characters,
  });

  static String formatAiredDates(
      Map<String, dynamic>? startDate, Map<String, dynamic>? endDate) {
    String format(Map<String, dynamic>? date) {
      if (date == null || date['year'] == null) return '';
      return '${date['year']}-${date['month']?.toString().padLeft(2, '0') ?? '??'}-${date['day']?.toString().padLeft(2, '0') ?? '??'}';
    }

    final start = format(startDate);
    final end = format(endDate);

    if (start.isEmpty) return '';
    return end.isEmpty ? start : '$start to $end';
  }

  factory DetailsData.fromJson(Map<String, dynamic> json, isManga) {
    return DetailsData(
      id: json['id'],
      title: json['title']['english'] ?? json['title']['romaji'],
      japaneseTitle: json['title']['native'] ?? "",
      description: json['description'],
      image: json['coverImage']['large'],
      coverImage: json['bannerImage'] ?? json['coverImage']['large'],
      rating: json['averageScore'] != null
          ? (json['averageScore'] / 10).toString()
          : 'N/A',
      premiered: json['season'] != null
          ? '${json['season']} ${json['seasonYear']}'
          : 'N/A',
      type: json['type'],
      season: json['season'],
      duration: !isManga ? ("${json['duration']}m").toString() : "",
      quality: json['format'] ?? "",
      status: json['status'],
      aired:
          !isManga ? formatAiredDates(json['startDate'], json['endDate']) : "",
      popularity: json['popularity'],
      timeUntilAiring: !isManga
          ? json['nextAiringEpisode'] != null &&
                  json['nextAiringEpisode']['timeUntilAiring'] != null
              ? json['nextAiringEpisode']['timeUntilAiring']
              : 0
          : 0,
      studios: (json['studios']['nodes'] as List<dynamic>?)
          ?.map((e) => e['name'] as String)
          .toList(),
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      relations: (json['relations']['edges'] as List<dynamic>?)
          ?.map((e) => Anime.fromJson(e['node']))
          .toList(),
      recommendations: (json['recommendations']['edges'] as List<dynamic>?)
          ?.map((e) => Anime.fromJson(e['node']['mediaRecommendation']))
          .toList(),
      characters: (json['characters']['edges'] as List<dynamic>?)
          ?.map((e) => Character.fromJson(e['node']))
          .toList(),
    );
  }
}

class Character {
  String? name;
  String? image;
  int? popularity;

  Character({this.name, this.image, this.popularity});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name']['full'] ?? '',
      image: json['image']['large'] ?? "",
      popularity: json['favourites'] ?? "",
    );
  }
}
