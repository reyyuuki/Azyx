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
    return AnilistMediaData(
      id: json['id'],
      episodes: json['episodes'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      coverImage: json['coverImage'],
      rating: json['rating'],
      type: json['type'],
      status: json['status'],
      popularity: json['popularity'],
      timeUntilAiring: json['timeUntilAiring'],
      genres: (json['genres'] as List?)?.map((e) => e as String).toList(),
      servicesType: json['servicesType'] != null
          ? ServicesType.values.firstWhere(
              (e) => e.name == json['servicesType'],
              orElse: () => ServicesType.mal,
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
    return Character(
      image: json['image'],
      name: json['name'],
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'image': image, 'name': name, 'popularity': popularity};
  }
}
