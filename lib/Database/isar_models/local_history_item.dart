import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:isar_community/isar.dart';

part 'local_history_item.g.dart';

@collection
class LocalHistoryItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  int? mediaId;

  String? link;
  String? title;
  String? progress;
  String? image;
  String? sourceName;
  String? sourceId;

  int? lastTimeSeconds;
  int? totalDurationSeconds;
  int? currentTimeSeconds;
  int? currentPage;

  DateTime? lastWatched;

  @Enumerated(EnumType.ordinal32)
  HistoryMediaType? mediaType;

  AnilistMediaData? mediaData;
  List<Chapter>? chapterList;
  List<Episode>? episodeList;
  String? episodeUrlsJson;
  String? mangaSourceJson;
}

enum HistoryMediaType { anime, manga }
