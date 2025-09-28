import 'dart:developer';

import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/utils/utils.dart';

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
  List<Anime>? relations;
  List<Anime>? recommendations;
  List<Character>? characters;
  ServicesType? servicesType;
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
    this.relations,
    this.recommendations,
    this.characters,
    this.servicesType,
    this.mediaType,
  });

  static String formatAiredDates(
    Map<String, dynamic>? startDate,
    Map<String, dynamic>? endDate,
  ) {
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

  factory AnilistMediaData.fromMAL(
    Map<String, dynamic> json, {
    bool isManga = false,
  }) {
    final node = json;
    return AnilistMediaData(
      id: node['id'].toString(),
      title: node['title'] ?? '??',
      description: node['synopsis'] ?? '??',
      image: node['main_picture']?['medium'] ?? '??',
      coverImage: node['main_picture']?['large'] ?? '??',
      episodes: isManga ? node['num_chapters'] : node['num_episodes'],
      type: node['media_type']?.toUpperCase() ?? '??',
      status: node['status']?.split('_').first.toUpperCase() ?? '??',
      rating: node['mean']?.toString() ?? '??',
      popularity: node['popularity'],
      // timeUntilAiring: int.parse(node['start_date']),
      genres:
          (node['genres'] as List<dynamic>?)
              ?.map((genre) => genre['name']?.toString() ?? '??')
              .toList() ??
          [],
      characters: [],
      recommendations: (node['recommendations'] as List<dynamic>)
          .map((e) => Anime.fromMAL(e))
          .toList(),
      servicesType: ServicesType.mal,
    );
  }

  factory AnilistMediaData.fromSimkl(Map<String?, dynamic> json, bool isMovie) {
    MediaType type = MediaType.anime;
    return AnilistMediaData(
      id: '${json['ids']?['simkl_id']?.toString() ?? json['ids']?['simkl']?.toString()}*${isMovie ? "MOVIE" : "SERIES"}',
      title: json['title'] ?? 'Unknown Title',
      description: json['overview'] ?? 'No description available.',
      image: json['poster'] != null
          ? 'https://wsrv.nl/?url=https://simkl.in/posters/${json['poster']}_m.jpg'
          : '',
      coverImage: json['fanart'] != null
          ? 'https://wsrv.nl/?url=https://simkl.in/fanart/${json['fanart']}_medium.jpg'
          : null,
      episodes: json['total_episodes'] ?? 1,
      type: json['country']?.toUpperCase() ?? 'UNKNOWN',
      // premiered: json['released'] ?? 'Unknown release date',
      // duration: json['runtime'] != null
      //     ? '${json['runtime']} minutes'
      //     : 'Unknown runtime',
      status: json['type']?.toUpperCase() ?? 'UNKNOWN',
      rating: json['ratings']?['simkl']?['rating']?.toString() ?? 'N/A',
      popularity: json['rank'] ?? 0,
      mediaType: type,
      // aired: json['released'] ?? 'Unknown air date',
      // totalChapters: '0',
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((genre) => genre.toString())
              .toList() ??
          [],
      recommendations:
          (json['users_recommendations'] as List<dynamic>?)
              ?.map((e) {
                try {
                  return Anime.fromSmallSimkl(e, isMovie);
                } catch (error) {
                  log('Error parsing recommendation: $error');
                  return null;
                }
              })
              .where((e) => e != null)
              .toList()
              .cast<Anime>() ??
          [],
      servicesType: ServicesType.simkl,
    );
  }

  factory AnilistMediaData.fromJson(Map<dynamic, dynamic> json, bool isManga) {
    log('new: ${json['recommendations']['edges'].length}');
    return AnilistMediaData(
      id: json['id']?.toString() ?? '1',
      title: json['title']['english'] ?? json['title']['romaji'] ?? "Unknown",
      description: json['description'],
      image: json['coverImage']['large'],
      episodes: isManga
          ? json['chapters'] ?? json['episodes']
          : json['episodes'],
      coverImage: json['bannerImage'] ?? json['coverImage']['large'],
      rating: json['averageScore'] != null
          ? (json['averageScore'] / 10).toString()
          : 'N/A',
      type: json['type'],
      status: json['status'] ?? '',
      popularity: json['popularity'] ?? 0,
      timeUntilAiring: !isManga
          ? (json['nextAiringEpisode']?['timeUntilAiring'])
          : 0,
      genres: (json['genres'] as List?)?.map((e) => e as String).toList() ?? [],
      relations:
          (json['relations']['edges'] as List?)
              ?.map((e) => Anime.fromJson(e['node']))
              .toList() ??
          [],
      recommendations:
          (json['recommendations']['edges'] as List?)
              ?.map(
                (e) => Anime.fromJson(e['node']['mediaRecommendation'] ?? {}),
              )
              .toList() ??
          [],
      characters:
          (json['characters']['edges'] as List?)
              ?.map((e) => Character.fromJson(e['node']))
              .toList() ??
          [],
      servicesType: ServicesType.values[json['service'] ?? 1],
    );
  }

  dynamic toJson(bool isManga) {
    return {
      'id': id,
      'title': {'english': title, 'romaji': title},
      'description': description,
      'coverImage': {'large': image},
      'bannerImage': coverImage != image ? coverImage : null,
      'episodes': episodes,
      'averageScore': (double.parse(rating ?? '0') * 10).toInt(),
      'type': type,
      'status': status,
      'popularity': popularity,
      'nextAiringEpisode': timeUntilAiring != 0
          ? {'timeUntilAiring': timeUntilAiring}
          : null,
      'genres': genres != null ? (genres as List).map((e) => e).toList() : null,
      'relations': {
        'edges': relations?.map((e) => {'node': e.toJson()}).toList() ?? [],
      },
      'recommendations': {
        'edges':
            recommendations
                ?.map(
                  (e) => {
                    'node': {'mediaRecommendation': e.toJson()},
                  },
                )
                .toList() ??
            [],
      },
      'characters': {
        'edges': characters?.map((e) => {'node': e.toJson()}).toList() ?? [],
      },
      'service': servicesType?.index ?? 1,
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
      'name': {'full': name},
      'image': {'large': image},
      'favourites': popularity,
    };
  }
}
