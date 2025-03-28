import 'dart:developer';

import 'package:azyx/Classes/anime_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';

class AnilistMediaData {
  int? id;
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
  List<Anime>? relations;
  List<Anime>? recommendations;
  List<Character>? characters;

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
    this.relations,
    this.recommendations,
    this.characters,
  });

  static String formatAiredDates(
      Map<String, dynamic>? startDate, Map<String, dynamic>? endDate) {
    try {
      String format(Map<String, dynamic>? date) {
        if (date == null || date['year'] == null) return '';
        return '${date['year']}-${date['month']?.toString().padLeft(2, '0') ?? '??'}-${date['day']?.toString().padLeft(2, '0') ?? '??'}';
      }

      final start = format(startDate);
      final end = format(endDate);

      if (start.isEmpty) return '';
      return end.isEmpty ? start : '$start to $end';
    } catch (e) {
      log('Error: $e');
      azyxSnackBar(e.toString());
      return "";
    }
  }

  factory AnilistMediaData.fromJson(Map<dynamic, dynamic> json, bool isManga) {
    return AnilistMediaData(
      id: json['id'] ?? 1,
      title: json['title']['english'] ?? json['title']['romaji'] ?? "Unknown",
      description: json['description'],
      image: json['coverImage']['large'],
      episodes: isManga ? json['chapters'] : json['episodes'],
      coverImage: json['bannerImage'] ?? json['coverImage']['large'],
      rating: json['averageScore'] != null
          ? (json['averageScore'] / 10).toString()
          : 'N/A',
      type: json['type'],
      status: json['status'] ?? '',
      popularity: json['popularity'] ?? "",
      timeUntilAiring:
          !isManga ? (json['nextAiringEpisode']?['timeUntilAiring']) : 0,
      genres: (json['genres'] as List?)?.map((e) => e as String).toList() ?? [],
      relations: (json['relations']['edges'] as List?)
              ?.map((e) => Anime.fromJson(e['node']))
              .toList() ??
          [],
      recommendations: (json['recommendations']['edges'] as List?)
              ?.map(
                  (e) => Anime.fromJson(e['node']['mediaRecommendation'] ?? {}))
              .toList() ??
          [],
      characters: (json['characters']['edges'] as List?)
              ?.map((e) => Character.fromJson(e['node']))
              .toList() ??
          [],
    );
  }

  dynamic toJson(bool isManga) {
    return {
      'id': id,
      'title': {
        'english': title,
        'romaji': title,
      },
      'description': description,
      'coverImage': {
        'large': image,
      },
      'bannerImage': coverImage != image ? coverImage : null,
      'episodes': episodes,
      'averageScore': (double.parse(rating!) * 10).toInt(),
      'type': type,
      'status': status,
      'popularity': popularity,
      'nextAiringEpisode':
          timeUntilAiring != 0 ? {'timeUntilAiring': timeUntilAiring} : null,
      'genres': genres != null ? (genres as List).map((e) => e).toList() : null,
      'relations': {
        'edges': relations?.map((e) => {'node': e.toJson()}).toList() ?? [],
      },
      'recommendations': {
        'edges': recommendations
                ?.map((e) => {
                      'node': {'mediaRecommendation': e.toJson()}
                    })
                .toList() ??
            []
      },
      'characters': {
        'edges': characters?.map((e) => {'node': e.toJson()}).toList() ?? []
      },
    };
  }
}

class Character {
  String? name;
  String? image;
  int? popularity;

  Character({this.name, this.image, this.popularity});

  factory Character.fromJson(dynamic json) {
    return Character(
      name: json['name']['full'] ?? '',
      image: json['image']['large'] ?? "",
      popularity: json['favourites'] ?? 0,
    );
  }

  dynamic toJson() {
    return {
      'name': {
        'full': name,
      },
      'image': {
        'large': image,
      },
      'favourites': popularity,
    };
  }
}
