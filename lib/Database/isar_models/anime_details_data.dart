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
  @ignore
  String? color;
  @ignore
  int? favourites;
  @ignore
  int? meanScore;
  @ignore
  String? siteUrl;
  @ignore
  String? countryOfOrigin;
  @ignore
  int? nextEpisodeNumber;
  @ignore
  int? nextEpisodeAiringAt;
  @ignore
  List<AzRanking>? rankingsList;
  @ignore
  List<AzMediaTag>? tagsList;
  @ignore
  List<AzScoreBucket>? scoreDistribution;
  @ignore
  List<AzStatusBucket>? statusDistribution;
  @ignore
  List<AzStreamingEpisode>? streamingEpisodesList;
  @ignore
  AzMediaListEntry? mediaListEntry;
  @ignore
  bool? isFavourite;
  @ignore
  String? bannerImage;
  @ignore
  int? seasonYear;
  @ignore
  int? startYear;
  @ignore
  int? startMonth;
  @ignore
  int? startDay;
  @ignore
  int? endYear;
  @ignore
  int? endMonth;
  @ignore
  int? endDay;
  String? get format => type;
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
    this.color,
    this.favourites,
    this.meanScore,
    this.siteUrl,
    this.countryOfOrigin,
    this.nextEpisodeNumber,
    this.nextEpisodeAiringAt,
    this.rankingsList,
    this.tagsList,
    this.scoreDistribution,
    this.statusDistribution,
    this.streamingEpisodesList,
    this.mediaListEntry,
    this.isFavourite,
    this.bannerImage,
    this.seasonYear,
    this.startYear,
    this.startMonth,
    this.startDay,
    this.endYear,
    this.endMonth,
    this.endDay,
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
    String? color;
    if (coverImageJson is Map) {
      image = coverImageJson['extraLarge'] ??
          coverImageJson['large'] ??
          coverImageJson['medium'];
      color = coverImageJson['color']?.toString();
    } else {
      image = json['image']?.toString() ?? coverImageJson?.toString();
    }
    final studiosJson = json['studios'];
    List<String>? studios;
    if (studiosJson is Map && studiosJson['edges'] is List) {
      final edges = studiosJson['edges'] as List;
      dynamic selectedNode;
      for (final e in edges) {
        if (e is Map &&
            e['isMain'] == true &&
            e['node'] is Map &&
            e['node']['isAnimationStudio'] == true) {
          selectedNode = e['node'];
          break;
        }
      }
      if (selectedNode == null) {
        for (final e in edges) {
          if (e is Map &&
              e['node'] is Map &&
              e['node']['isAnimationStudio'] == true) {
            selectedNode = e['node'];
            break;
          }
        }
      }
      if (selectedNode != null && selectedNode['name'] != null) {
        studios = [selectedNode['name'].toString()];
      } else {
        studios = edges
            .map((e) => e is Map && e['node'] is Map
                ? e['node']['name']?.toString()
                : null)
            .whereType<String>()
            .toList();
      }
    } else if (studiosJson is Map && studiosJson['nodes'] is List) {
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

    List<AzRanking>? rankingsList;
    if (json['rankings'] is List) {
      rankingsList = (json['rankings'] as List)
          .whereType<Map>()
          .map((r) => AzRanking.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    List<AzMediaTag>? tagsList;
    if (json['tags'] is List) {
      tagsList = (json['tags'] as List)
          .whereType<Map>()
          .map((t) => AzMediaTag.fromJson(Map<String, dynamic>.from(t)))
          .toList();
    }

    List<AzScoreBucket>? scoreDist;
    List<AzStatusBucket>? statusDist;
    if (json['stats'] is Map) {
      final s = json['stats'];
      if (s['scoreDistribution'] is List) {
        scoreDist = (s['scoreDistribution'] as List)
            .whereType<Map>()
            .map((e) => AzScoreBucket.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (s['statusDistribution'] is List) {
        statusDist = (s['statusDistribution'] as List)
            .whereType<Map>()
            .map((e) => AzStatusBucket.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    List<AzStreamingEpisode>? streamingEps;
    if (json['streamingEpisodes'] is List) {
      streamingEps = (json['streamingEpisodes'] as List)
          .whereType<Map>()
          .map((e) => AzStreamingEpisode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    int? nextEpNum;
    int? nextAirSeconds;
    if (json['nextAiringEpisode'] is Map) {
      nextEpNum = (json['nextAiringEpisode']['episode'] as num?)?.toInt();
      nextAirSeconds =
          (json['nextAiringEpisode']['timeUntilAiring'] as num?)?.toInt();
    }

    AzMediaListEntry? mle;
    if (json['mediaListEntry'] is Map) {
      mle = AzMediaListEntry.fromJson(
          Map<String, dynamic>.from(json['mediaListEntry']));
    }

    final bool? isFav = json['isFavourite'] as bool?;

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
      type: json['format']?.toString() ?? json['type']?.toString(),
      status: json['status']?.toString(),
      popularity: json['popularity'],
      timeUntilAiring: nextAirSeconds ?? json['timeUntilAiring'],
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
          ?.whereType<Map>()
          .map((e) => Character.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      relations: (json['relations']?['edges'] as List?)
          ?.whereType<Map>()
          .map((e) => AnilistMediaData.fromJson(Map<String, dynamic>.from(e['node'] ?? {})))
          .toList(),
      recommendations: (json['recommendations']?['nodes'] as List?)
          ?.whereType<Map>()
          .map(
            (e) => AnilistMediaData.fromJson(
              Map<String, dynamic>.from(e['mediaRecommendation'] ?? {}),
            ),
          )
          .where((m) => m.id != null && m.id!.isNotEmpty)
          .toList() ??
          (json['recommendations']?['edges'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => AnilistMediaData.fromJson(
                  Map<String, dynamic>.from(e['node']?['mediaRecommendation'] ?? {}),
                ),
              )
              .where((m) => m.id != null && m.id!.isNotEmpty)
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
      color: color,
      favourites: (json['favourites'] as num?)?.toInt(),
      meanScore: (json['meanScore'] as num?)?.toInt(),
      siteUrl: json['siteUrl']?.toString(),
      countryOfOrigin: json['countryOfOrigin']?.toString(),
      nextEpisodeNumber: nextEpNum,
      nextEpisodeAiringAt: nextAirSeconds,
      rankingsList: rankingsList,
      tagsList: tagsList,
      scoreDistribution: scoreDist,
      statusDistribution: statusDist,
      streamingEpisodesList: streamingEps,
      mediaListEntry: mle,
      isFavourite: isFav,
      bannerImage: json['bannerImage']?.toString(),
      seasonYear: json['seasonYear'] is int
          ? json['seasonYear'] as int
          : int.tryParse(json['seasonYear']?.toString() ?? ''),
      startYear:
          json['startDate'] is Map ? json['startDate']['year'] as int? : null,
      startMonth:
          json['startDate'] is Map ? json['startDate']['month'] as int? : null,
      startDay:
          json['startDate'] is Map ? json['startDate']['day'] as int? : null,
      endYear: json['endDate'] is Map ? json['endDate']['year'] as int? : null,
      endMonth:
          json['endDate'] is Map ? json['endDate']['month'] as int? : null,
      endDay: json['endDate'] is Map ? json['endDate']['day'] as int? : null,
    );
  }
}

@embedded
class Character {
  String? image;
  String? name;
  int? popularity;
  @ignore
  String? role;
  @ignore
  String? voiceActorName;

  Character({
    this.image,
    this.name,
    this.popularity,
    this.role,
    this.voiceActorName,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> node = (json['node'] is Map)
        ? Map<String, dynamic>.from(json['node'])
        : json;
    final nameJson = node['name'];
    String? name;
    if (nameJson is Map) {
      name = nameJson['full'] ?? nameJson['userPreferred'];
    } else {
      name = nameJson?.toString();
    }
    final imageJson = node['image'];
    String? image;
    if (imageJson is Map) {
      image = imageJson['large'] ?? imageJson['medium'];
    } else {
      image = imageJson?.toString();
    }

    final role = json['role']?.toString();
    final vaList = json['voiceActors'] as List?;
    String? vaName;
    if (vaList != null && vaList.isNotEmpty) {
      final firstVa = vaList.first;
      if (firstVa is Map) {
        vaName = firstVa['name'] is Map
            ? firstVa['name']['full']?.toString()
            : firstVa['name']?.toString();
      }
    }

    return Character(
      image: image,
      name: name,
      popularity: node['popularity'] ?? node['favourites'],
      role: role,
      voiceActorName: vaName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'name': name,
      'popularity': popularity,
      'role': role,
      'voiceActorName': voiceActorName,
    };
  }
}

class AzRanking {
  final int? rank;
  final String? type;
  final bool allTime;
  final String? season;
  final int? year;
  final String? format;
  final String? context;

  const AzRanking({
    this.rank,
    this.type,
    this.allTime = false,
    this.season,
    this.year,
    this.format,
    this.context,
  });

  factory AzRanking.fromJson(Map<String, dynamic> json) {
    return AzRanking(
      rank: (json['rank'] as num?)?.toInt(),
      type: json['type']?.toString(),
      allTime: json['allTime'] == true,
      season: json['season']?.toString(),
      year: (json['year'] as num?)?.toInt(),
      format: json['format']?.toString(),
      context: json['context']?.toString(),
    );
  }
}

class AzMediaTag {
  final String name;
  final int rank;
  final bool isMediaSpoiler;

  const AzMediaTag({
    required this.name,
    required this.rank,
    this.isMediaSpoiler = false,
  });

  factory AzMediaTag.fromJson(Map<String, dynamic> json) {
    return AzMediaTag(
      name: json['name']?.toString() ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      isMediaSpoiler: json['isMediaSpoiler'] == true,
    );
  }
}

class AzScoreBucket {
  final int score;
  final int amount;

  const AzScoreBucket({required this.score, required this.amount});

  factory AzScoreBucket.fromJson(Map<String, dynamic> json) {
    return AzScoreBucket(
      score: (json['score'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AzStatusBucket {
  final String status;
  final int amount;

  const AzStatusBucket({required this.status, required this.amount});

  factory AzStatusBucket.fromJson(Map<String, dynamic> json) {
    return AzStatusBucket(
      status: json['status']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AzStreamingEpisode {
  final String? title;
  final String? thumbnail;
  final String? url;

  const AzStreamingEpisode({this.title, this.thumbnail, this.url});

  factory AzStreamingEpisode.fromJson(Map<String, dynamic> json) {
    return AzStreamingEpisode(
      title: json['title']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      url: json['url']?.toString(),
    );
  }
}

class AzMediaListEntry {
  final int? id;
  final String? status;
  final int? progress;
  final double? score;
  final int? repeat;

  const AzMediaListEntry({
    this.id,
    this.status,
    this.progress,
    this.score,
    this.repeat,
  });

  factory AzMediaListEntry.fromJson(Map<String, dynamic> json) {
    return AzMediaListEntry(
      id: (json['id'] as num?)?.toInt(),
      status: json['status']?.toString(),
      progress: (json['progress'] as num?)?.toInt(),
      score: (json['score'] as num?)?.toDouble(),
      repeat: (json['repeat'] as num?)?.toInt(),
    );
  }
}
