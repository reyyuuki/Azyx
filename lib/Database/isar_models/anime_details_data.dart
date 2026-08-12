import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:isar_community/isar.dart';
part 'anime_details_data.g.dart';

@embedded
class AnilistMediaData {
  String? id;
  int? episodes;
  String? title;
  String? titleRomaji;
  String? titleNative;
  String? description;
  String? image;
  String? coverImage;
  String? rating;
  String? type;
  String? status;
  int? popularity;
  int? timeUntilAiring;
  List<String>? genres;
  List<String>? synonyms;
  List<String>? studios;
  String? season;
  int? duration;
  String? source;
  String? startDate;
  String? endDate;
  String? trailerUrl;
  String? trailerThumbnail;
  List<String>? pictures;
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
    this.titleRomaji,
    this.titleNative,
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
    this.synonyms,
    this.studios,
    this.season,
    this.duration,
    this.source,
    this.startDate,
    this.endDate,
    this.trailerUrl,
    this.trailerThumbnail,
    this.pictures,
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
    final altTitles = json['alternative_titles'] as Map<String, dynamic>?;
    final seasonMap = json['start_season'] as Map<String, dynamic>?;
    final studioList = (json['studios'] as List?)
        ?.map((e) => e['name'].toString())
        .toList();

    String? seasonStr;
    if (seasonMap != null && seasonMap['season'] != null) {
      seasonStr =
          "${seasonMap['season'].toString().toUpperCase()} ${seasonMap['year'] ?? ''}"
              .trim();
    }

    int? durationMins;
    if (json['average_episode_duration'] != null) {
      durationMins = (json['average_episode_duration'] as int) ~/ 60;
    }

    final picsList = (json['pictures'] as List?)
        ?.map((e) => (e['large'] ?? e['medium'])?.toString())
        .whereType<String>()
        .toList();

    return AnilistMediaData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '??',
      titleRomaji: altTitles?['ja']?.toString() ?? altTitles?['en']?.toString(),
      titleNative: altTitles?['ja']?.toString(),
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
      synonyms: (altTitles?['synonyms'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      studios: studioList,
      season: seasonStr,
      duration: durationMins,
      source: json['source']?.toString().replaceAll('_', ' ').toUpperCase(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      pictures: picsList,
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
      'titleRomaji': titleRomaji,
      'titleNative': titleNative,
      'description': description,
      'image': image,
      'coverImage': coverImage,
      'rating': rating,
      'type': type,
      'status': status,
      'popularity': popularity,
      'timeUntilAiring': timeUntilAiring,
      'genres': genres,
      'synonyms': synonyms,
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
    String? titleRomaji;
    String? titleNative;
    if (titleJson is Map) {
      title =
          titleJson['english'] ??
          titleJson['romaji'] ??
          titleJson['native'] ??
          '??';
      titleRomaji = titleJson['romaji']?.toString();
      titleNative = titleJson['native']?.toString();
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
    final studiosJson = json['studios'];
    List<String>? studios;
    if (studiosJson is Map && studiosJson['nodes'] is List) {
      studios = (studiosJson['nodes'] as List)
          .map((e) => e['name'].toString())
          .toList();
    } else if (studiosJson is List) {
      studios = studiosJson.map((e) => e.toString()).toList();
    }

    final seasonVal = json['season']?.toString();
    final seasonYr = json['seasonYear']?.toString();
    String? seasonStr;
    if (seasonVal != null) {
      seasonStr = "$seasonVal ${seasonYr ?? ''}".trim().toUpperCase();
    }

    final trailerMap = json['trailer'] as Map<String, dynamic>?;
    String? trailerUrl;
    String? trailerThumbnail;
    if (trailerMap != null &&
        trailerMap['site'] == 'youtube' &&
        trailerMap['id'] != null) {
      final ytId = trailerMap['id'].toString().trim();
      if (ytId.isNotEmpty) {
        trailerUrl = "https://www.youtube.com/watch?v=$ytId";
        final thumbFromApi = trailerMap['thumbnail']?.toString().trim();
        trailerThumbnail = (thumbFromApi != null && thumbFromApi.isNotEmpty)
            ? thumbFromApi
            : "https://img.youtube.com/vi/$ytId/hqdefault.jpg";
      }
    }

    final picsList = <String>[];
    if (json['bannerImage'] != null &&
        json['bannerImage'].toString().isNotEmpty) {
      picsList.add(json['bannerImage'].toString());
    }
    if (image != null && image.isNotEmpty && !picsList.contains(image)) {
      picsList.add(image);
    }
    if (json['pictures'] is List) {
      for (final p in (json['pictures'] as List)) {
        final url = (p is Map ? (p['large'] ?? p['medium']) : p)?.toString();
        if (url != null && url.isNotEmpty && !picsList.contains(url)) {
          picsList.add(url);
        }
      }
    }

    return AnilistMediaData(
      id: json['id']?.toString(),
      episodes: json['episodes'],
      title: title,
      titleRomaji: titleRomaji ?? json['titleRomaji']?.toString(),
      titleNative: titleNative ?? json['titleNative']?.toString(),
      description: json['description'],
      image: image,
      coverImage: json['bannerImage']?.toString() ?? image,
      rating: json['averageScore']?.toString() ?? json['rating']?.toString(),
      type: json['type']?.toString(),
      status: json['status']?.toString(),
      popularity: json['popularity'],
      timeUntilAiring: json['timeUntilAiring'],
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList(),
      synonyms: (json['synonyms'] as List?)?.map((e) => e.toString()).toList(),
      studios: studios,
      season: seasonStr,
      duration: json['duration'],
      source: json['source']?.toString().replaceAll('_', ' ').toUpperCase(),
      startDate: json['startDate'] is Map
          ? "${json['startDate']['year']}-${json['startDate']['month']}-${json['startDate']['day']}"
          : json['startDate']?.toString(),
      endDate: json['endDate'] is Map
          ? "${json['endDate']['year']}-${json['endDate']['month']}-${json['endDate']['day']}"
          : json['endDate']?.toString(),
      trailerUrl: trailerUrl,
      trailerThumbnail: trailerThumbnail,
      pictures: picsList.isNotEmpty ? picsList : null,
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
