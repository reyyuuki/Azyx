import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:dartotsu_extension_bridge/Models/DMedia.dart';

class Anime {
  String? title;
  String? url;
  String? image;
  String? bannerImage;
  String? description;
  String? rating;
  String? status;
  int? id;
  String? type;
  int? episodes;
  List<String>? genres;
  MediaType? mediaType;
  ServicesType? servicesType;
  Anime(
      {this.id,
      this.image,
      this.url,
      this.title,
      this.description,
      this.rating,
      this.bannerImage,
      this.episodes,
      this.type,
      this.status,
      this.mediaType,
      this.servicesType,
      this.genres});

  factory Anime.fromJson(Map<dynamic, dynamic> data) {
    return Anime(
      id: serviceHandler.serviceType.value == ServicesType.mal
          ? data['idMal']
          : data['id'],
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

  factory Anime.froDMedia(DMedia manga, MediaType type) {
    return Anime(
      url: manga.url ?? '',
      title: manga.title ?? "Unknown Title",
      description: manga.description ?? "No description available.",
      image: manga.cover ?? "",
      bannerImage: manga.cover,
      episodes: manga.episodes?.length ?? 0,
      status: '??',
      mediaType: type,
      genres: manga.genre ?? [],
      servicesType: serviceHandler.serviceType.value,
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

  factory Anime.fromMAL(Map<String, dynamic> json, {bool isManga = false}) {
    final node = json['node'] ?? {};

    return Anime(
      id: node['id'] ?? 0,
      title: node['title'] ?? node['alternative_titles']?['en'] ?? '??',
      description: node['synopsis'] ?? '??',
      image: node['main_picture']?['medium'] ?? '??',
      bannerImage: node['main_picture']?['large'] ?? '??',
      episodes: isManga ? node['num_chapters'] : node['num_episodes'],
      type: node['media_type'] ?? '??',
      // sea: node['start_season']?['season'] ?? '??',
      // premiered: node['start_date'] ?? '??',
      // duration: node['average_episode_duration']?.toString() ?? '??',
      status: node['status'] ?? '??',
      rating: node['mean']?.toString() ?? '??',
      // popularity: node['popularity']?.toString() ?? '??',
      // format: node['media_type'] ?? '??',
      // aired: node['start_date'] ?? '??',
      // totalChapters: node['num_chapters']?.toString() ?? '??',
      genres: (node['genres'] as List<dynamic>?)
              ?.map((genre) => genre['name']?.toString() ?? '??')
              .toList() ??
          [],
      // studios: (node['studios'] as List<dynamic>?)
      //     ?.map((studio) => studio['name']?.toString() ?? '??')
      //     .toList(),
      // characters: [],
      // relations: [],
      // recommendations: [],
      // nextAiringEpisode: null,
      // rankings: [],
      // mediaContent: [],
      // mediaType: node['media_type'] == 'tv' ? MediaType.anime : MediaType.manga,
      // serviceType: ServicesType.mal,
    );
  }
}
