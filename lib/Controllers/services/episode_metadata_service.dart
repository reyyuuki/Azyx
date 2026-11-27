import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:http/http.dart' as http;

enum EpisodeMetadataProvider {
  auto('auto', 'Auto (Recommended)', 'Tries AniZip, then Kitsu, then Jikan'),
  anizip('anizip', 'AniZip', 'Fast AniList-mapped titles, summaries & thumbnails'),
  kitsu('kitsu', 'Kitsu', 'Detailed episode synopses and high-res stills'),
  jikan('jikan', 'Jikan (MAL)', 'Episode titles and filler flags from MyAnimeList');

  final String id;
  final String label;
  final String description;

  const EpisodeMetadataProvider(this.id, this.label, this.description);

  static EpisodeMetadataProvider fromId(String? raw) {
    return EpisodeMetadataProvider.values.firstWhere(
      (p) => p.id == raw,
      orElse: () => EpisodeMetadataProvider.auto,
    );
  }
}

class EpisodeMetadataService {
  static bool get isEnabled =>
      MetadataKeys.episodeMetadataEnabled.get<bool>(true);

  static set isEnabled(bool value) =>
      MetadataKeys.episodeMetadataEnabled.set(value);

  static EpisodeMetadataProvider get selectedProvider =>
      EpisodeMetadataProvider.fromId(
        MetadataKeys.episodeMetadataProvider.get<String>('auto'),
      );

  static set selectedProvider(EpisodeMetadataProvider provider) =>
      MetadataKeys.episodeMetadataProvider.set(provider.id);

  static Future<List<Episode>> enrichEpisodes({
    required List<Episode> episodes,
    required int anilistId,
    String? title,
    int? malId,
  }) async {
    if (!isEnabled || episodes.isEmpty) return episodes;

    final provider = selectedProvider;
    var current = List<Episode>.from(episodes);
    int? resolvedMalId = malId;

    if (provider == EpisodeMetadataProvider.auto ||
        provider == EpisodeMetadataProvider.anizip) {
      final aniResult = await _fetchAniZip(anilistId);
      if (aniResult != null) {
        resolvedMalId ??= aniResult.malId;
        current = _mergeEpisodes(current, aniResult.map);
      }
      if (provider == EpisodeMetadataProvider.anizip ||
          _allEnriched(current)) {
        return current;
      }
    }

    if (provider == EpisodeMetadataProvider.auto ||
        provider == EpisodeMetadataProvider.kitsu) {
      if (title != null && title.trim().isNotEmpty) {
        final kitsuMap = await _fetchKitsu(title.trim(), current.length);
        if (kitsuMap.isNotEmpty) {
          current = _mergeEpisodes(current, kitsuMap);
        }
      }
      if (provider == EpisodeMetadataProvider.kitsu ||
          _allEnriched(current)) {
        return current;
      }
    }

    if (provider == EpisodeMetadataProvider.auto ||
        provider == EpisodeMetadataProvider.jikan) {
      final jikanMap = await _fetchJikan(
        malId: resolvedMalId,
        title: title,
      );
      if (jikanMap.isNotEmpty) {
        current = _mergeEpisodes(current, jikanMap);
      }
    }

    return current;
  }

  static bool _allEnriched(List<Episode> episodes) {
    return episodes.every(
      (e) =>
          (e.title != null && e.title!.trim().isNotEmpty) &&
          (e.thumbnail != null && e.thumbnail!.trim().isNotEmpty),
    );
  }

  static List<Episode> _mergeEpisodes(
    List<Episode> base,
    Map<String, _EpisodeMeta> metaByNum,
  ) {
    if (metaByNum.isEmpty) return base;
    return base.map((entry) {
      final key = entry.number.trim();
      final meta = metaByNum[key] ??
          metaByNum[int.tryParse(key)?.toString() ?? ''];
      if (meta == null) return entry;

      final hasTitle = entry.title != null && entry.title!.trim().isNotEmpty;
      final hasDesc = entry.desc != null && entry.desc!.trim().isNotEmpty;
      final hasThumb =
          entry.thumbnail != null && entry.thumbnail!.trim().isNotEmpty;

      return Episode(
        url: entry.url ?? '',
        number: entry.number,
        title: hasTitle ? entry.title : (meta.title ?? entry.title ?? ''),
        desc: hasDesc ? entry.desc : (meta.desc ?? entry.desc ?? ''),
        thumbnail:
            hasThumb ? entry.thumbnail : (meta.thumbnail ?? entry.thumbnail ?? ''),
        sortKeys: entry.sortKeys,
        sortVals: entry.sortVals,
        season: entry.season,
        type: entry.type,
        filler: (entry.filler == true) || (meta.filler == true),
      );
    }).toList();
  }

  static Future<_AniZipResult?> _fetchAniZip(int anilistId) async {
    try {
      final resp = await http
          .get(
            Uri.parse('https://api.ani.zip/mappings?anilist_id=$anilistId'),
          )
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final parsed = jsonDecode(resp.body);
      if (parsed is! Map) return null;
      final malId = (parsed['mappings']?['mal_id'] as num?)?.toInt();
      final anifyEps = parsed['episodes'];
      if (anifyEps is! Map) return null;

      final result = <String, _EpisodeMeta>{};
      for (final entry in anifyEps.entries) {
        final e = entry.value;
        if (e is! Map) continue;
        final epNum = (e['absoluteEpisodeNumber'] ??
                e['episodeNumber'] ??
                e['episode'] ??
                entry.key)
            .toString();
        final titleMap = e['title'];
        final title = titleMap is Map
            ? (titleMap['en'] ?? titleMap['x-jat'])?.toString()
            : titleMap?.toString();
        result[epNum] = _EpisodeMeta(
          title: title,
          desc: e['overview']?.toString(),
          thumbnail: e['image']?.toString(),
        );
      }
      return _AniZipResult(map: result, malId: malId);
    } catch (e) {
      log('EpisodeMetadataService AniZip error: $e');
      return null;
    }
  }

  static Future<Map<String, _EpisodeMeta>> _fetchKitsu(
    String title,
    int targetCount,
  ) async {
    final result = <String, _EpisodeMeta>{};
    try {
      final searchResp = await http
          .get(
            Uri.parse(
              'https://kitsu.io/api/edge/anime?filter[text]=${Uri.encodeComponent(title)}&page[limit]=1',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (searchResp.statusCode != 200) return result;
      final searchData = jsonDecode(searchResp.body);
      final list = searchData['data'];
      if (list is! List || list.isEmpty) return result;
      final kitsuId = list.first['id']?.toString();
      if (kitsuId == null || kitsuId.isEmpty) return result;

      int offset = 0;
      const limit = 20;
      while (offset < targetCount && offset < 200) {
        final epResp = await http
            .get(
              Uri.parse(
                'https://kitsu.io/api/edge/anime/$kitsuId/episodes?page[limit]=$limit&page[offset]=$offset',
              ),
            )
            .timeout(const Duration(seconds: 8));
        if (epResp.statusCode != 200) break;
        final epData = jsonDecode(epResp.body);
        final items = epData['data'];
        if (items is! List || items.isEmpty) break;
        for (final item in items) {
          final attrs = item['attributes'];
          if (attrs is! Map) continue;
          final numStr = attrs['number']?.toString();
          if (numStr == null) continue;
          final titles = attrs['titles'];
          final epTitle = (attrs['canonicalTitle'] ??
                  (titles is Map ? (titles['en_us'] ?? titles['en']) : null))
              ?.toString();
          final thumb = attrs['thumbnail'] is Map
              ? attrs['thumbnail']['original']?.toString()
              : null;
          result[numStr] = _EpisodeMeta(
            title: epTitle,
            desc: (attrs['synopsis'] ?? attrs['description'])?.toString(),
            thumbnail: thumb,
          );
        }
        if (items.length < limit) break;
        offset += limit;
      }
    } catch (e) {
      log('EpisodeMetadataService Kitsu error: $e');
    }
    return result;
  }

  static Future<Map<String, _EpisodeMeta>> _fetchJikan({
    int? malId,
    String? title,
  }) async {
    final result = <String, _EpisodeMeta>{};
    try {
      int? resolvedMalId = malId;
      if (resolvedMalId == null && title != null && title.trim().isNotEmpty) {
        final searchResp = await http
            .get(
              Uri.parse(
                'https://api.jikan.moe/v4/anime?q=${Uri.encodeComponent(title.trim())}&limit=1',
              ),
            )
            .timeout(const Duration(seconds: 8));
        if (searchResp.statusCode == 200) {
          final parsed = jsonDecode(searchResp.body);
          final data = parsed['data'];
          if (data is List && data.isNotEmpty) {
            resolvedMalId = (data.first['mal_id'] as num?)?.toInt();
          }
        }
      }
      if (resolvedMalId == null) return result;

      final epResp = await http
          .get(
            Uri.parse(
              'https://api.jikan.moe/v4/anime/$resolvedMalId/episodes',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (epResp.statusCode != 200) return result;
      final parsed = jsonDecode(epResp.body);
      final data = parsed['data'];
      if (data is! List) return result;
      for (final item in data) {
        if (item is! Map) continue;
        final malNum = item['mal_id']?.toString();
        if (malNum == null) continue;
        result[malNum] = _EpisodeMeta(
          title: (item['title'] ?? item['title_romanji'])?.toString(),
          filler: item['filler'] == true,
        );
      }
    } catch (e) {
      log('EpisodeMetadataService Jikan error: $e');
    }
    return result;
  }
}

class _AniZipResult {
  final Map<String, _EpisodeMeta> map;
  final int? malId;

  const _AniZipResult({required this.map, this.malId});
}

class _EpisodeMeta {
  final String? title;
  final String? desc;
  final String? thumbnail;
  final bool? filler;

  const _EpisodeMeta({
    this.title,
    this.desc,
    this.thumbnail,
    this.filler,
  });
}
