import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:isar_community/isar.dart';

part 'anime_details_data.g.dart';

@embedded
class AnilistMediaData {
  String? id;
  int? episodes;
  String? title;
  String? description;
  String? image;
  String? coverImage;
  String? rating;
  String? type;
  String? status;
  int? popularity;
  int? timeUntilAiring;
  List<String>? genres;

  List<Character>? characters;
  List<AnilistMediaData>? relations;
  List<AnilistMediaData>? recommendations;

  @Enumerated(EnumType.ordinal32)
  ServicesType? servicesType;

  @Enumerated(EnumType.ordinal32)
  MediaType? mediaType;

  AnilistMediaData({
    this.id,
    this.title,
    this.episodes,
    this.description,
    this.image,
    this.coverImage,
    this.rating,
    this.type,
    this.status,
    this.popularity,
    this.timeUntilAiring,
    this.genres,
    this.characters,
    this.relations,
    this.recommendations,
    this.servicesType,
    this.mediaType,
  });

  factory AnilistMediaData.fromMAL(
    Map<String, dynamic> json, {
    bool isManga = false,
  }) {
    return AnilistMediaData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '??',
      image: json['main_picture']?['large'] ?? json['main_picture']?['medium'],
      coverImage: json['main_picture']?['large'],
      episodes: isManga ? json['num_chapters'] : json['num_episodes'],
      description: json['synopsis'],
      status: json['status'],
      rating: json['mean']?.toString(),
      type: json['media_type'],
      popularity: json['popularity'],
      genres: (json['genres'] as List?)
          ?.map((e) => e['name'].toString())
          .toList(),
    );
  }

  factory AnilistMediaData.fromSimkl(
    Map<String, dynamic> json, [
    bool isMovie = false,
  ]) {
    return AnilistMediaData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '??',
      image: json['poster'] != null
          ? "https://wsrv.nl/?url=https://simkl.in/posters/${json['poster']}_m.jpg"
          : '?',
      episodes: json['total_episodes_count'],
      description: json['overview'],
      status: json['status'],
      rating: json['ratings']?['simkl']?['rating']?.toString(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episodes': episodes,
      'title': title,
      'description': description,
      'image': image,
      'coverImage': coverImage,
      'rating': rating,
      'type': type,
      'status': status,
      'popularity': popularity,
      'timeUntilAiring': timeUntilAiring,
      'genres': genres,
      'servicesType': servicesType?.name,
      'mediaType': mediaType?.name,
    };
  }

  factory AnilistMediaData.fromJson(
    Map<String, dynamic> json, [
    bool isManga = false,
  ]) {
    final titleJson = json['title'];
    String? title;
    if (titleJson is Map) {
      title =
          titleJson['english'] ??
          titleJson['romaji'] ??
          titleJson['native'] ??
          '??';
    } else {
      title = titleJson?.toString() ?? '??';
    }

    final coverImageJson = json['coverImage'];
    String? image;
    if (coverImageJson is Map) {
      image = coverImageJson['large'] ?? coverImageJson['medium'];
    } else {
      image = json['image']?.toString() ?? coverImageJson?.toString();
    }

    return AnilistMediaData(
      id: json['id']?.toString(),
      episodes: json['episodes'],
      title: title,
      description: json['description'],
      image: image,
      coverImage: json['bannerImage']?.toString() ?? image,
      rating: json['averageScore']?.toString() ?? json['rating']?.toString(),
      type: json['type']?.toString(),
      status: json['status']?.toString(),
      popularity: json['popularity'],
      timeUntilAiring: json['timeUntilAiring'],
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList(),
      characters: (json['characters']?['edges'] as List?)
          ?.map((e) => Character.fromJson(e['node']))
          .toList(),
      relations: (json['relations']?['edges'] as List?)
          ?.map((e) => AnilistMediaData.fromJson(e['node']))
          .toList(),
      recommendations: (json['recommendations']?['edges'] as List?)
          ?.map(
            (e) => AnilistMediaData.fromJson(
              e['node']?['mediaRecommendation'] ?? {},
            ),
          )
          .toList(),
      servicesType: json['servicesType'] != null
          ? ServicesType.values.firstWhere(
              (e) => e.name == json['servicesType'],
              orElse: () => ServicesType.anilist,
            )
          : null,
      mediaType: json['mediaType'] != null
          ? MediaType.values.firstWhere(
              (e) => e.name == json['mediaType'],
              orElse: () => MediaType.anime,
            )
          : null,
    );
  }
}

@embedded
class Character {
  String? image;
  String? name;
  int? popularity;

  Character({this.image, this.name, this.popularity});

  factory Character.fromJson(Map<String, dynamic> json) {
    final nameJson = json['name'];
    String? name;
    if (nameJson is Map) {
      name = nameJson['full'] ?? nameJson['userPreferred'];
    } else {
      name = nameJson?.toString();
    }

    final imageJson = json['image'];
    String? image;
    if (imageJson is Map) {
      image = imageJson['large'] ?? imageJson['medium'];
    } else {
      image = imageJson?.toString();
    }

    return Character(
      image: image,
      name: name,
      popularity: json['popularity'] ?? json['favourites'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'image': image, 'name': name, 'popularity': popularity};
  }
}
