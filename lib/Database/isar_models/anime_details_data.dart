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
    this.servicesType,
    this.mediaType,
  });

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

  factory AnilistMediaData.fromJson(Map<String, dynamic> json) {
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
