import 'dart:io';
import 'package:hive/hive.dart';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart' hide isar;
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/utils/utils.dart';
import 'package:get/get.dart';

class Deeplink {
  static void handleDeepLink(Uri uri, {bool isInitial = false}) {
    if (isInitial) {
      if (Hive.isBoxOpen("offline-data")) {
        final box = Hive.box("offline-data");
        if (box.get("last_processed_deeplink") == uri.toString()) {
          return;
        }
        box.put("last_processed_deeplink", uri.toString());
      }
    }
    Utils.log("HANDLING DEEEPLIINK => ${uri.toString()}");
    final illegalSchemes = Get.find<ExtensionManager>()
        .managers
        .expand((e) => e.schemes.toList())
        .toList();

    if (!illegalSchemes.contains(uri.scheme.toLowerCase()) && uri.host.toLowerCase() != 'add-repo') {
      final mediaTarget = _parseMediaTarget(uri);
      if (mediaTarget != null) {
         _openMediaTarget(mediaTarget);
         return;
      }
    }

    if (uri.host.toLowerCase() == 'add-repo') {
      _legacyUseDeepLink(uri);
      return;
    }

    bool isRepoAdded = false;
    azyxSnackBar("Adding repo... please wait.");
    final manager = Get.find<ExtensionManager>().managers;
    for (final handler in manager) {
      Utils.log('Matching ${uri.scheme} with ${handler.schemes.toString()}');
      if (handler.schemes.contains(uri.scheme.toLowerCase())) {
        handler.handleSchemes(uri);
        isRepoAdded = true;
        break;
      }
    }
    azyxSnackBar(
      isRepoAdded
          ? "Added Repo Links Successfully!"
          : "Missing or invalid parameters in the link.",
    );
  }

  static void _legacyUseDeepLink(Uri uri) {
    if (uri.host != 'add-repo') return;
    String managerId;
    String? animeUrl;
    String? mangaUrl;
    if (Platform.isAndroid) {
      switch (uri.scheme.toLowerCase()) {
        case 'aniyomi':
          managerId = 'aniyomi';
          animeUrl = uri.queryParameters['url']?.trim();
          break;
        case 'tachiyomi':
          managerId = 'aniyomi';
          mangaUrl = uri.queryParameters['url']?.trim();
          break;
        default:
          managerId = 'mangayomi';
          animeUrl =
              (uri.queryParameters["url"] ?? uri.queryParameters['anime_url'])
                  ?.trim();
          mangaUrl = uri.queryParameters['manga_url']?.trim();
          break;
      }
    } else {
      managerId = 'mangayomi';
      animeUrl =
          (uri.queryParameters["url"] ?? uri.queryParameters['anime_url'])
              ?.trim();
      mangaUrl = uri.queryParameters['manga_url']?.trim();
    }

    if (animeUrl != null) sourceController.addRepo(animeUrl, ItemType.anime, managerId);
    if (mangaUrl != null) sourceController.addRepo(mangaUrl, ItemType.manga, managerId);

    if (animeUrl != null || mangaUrl != null) azyxSnackBar('Repo added succesfully');
    else azyxSnackBar('Unsupported link');
  }

  static _MediaDeepLinkTarget? _parseMediaTarget(Uri uri) {
    final webTarget = _parseWebTarget(uri);
    if (webTarget != null) return webTarget;
    return _parseCustomTarget(uri);
  }

  static _MediaDeepLinkTarget? _parseWebTarget(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'https' && scheme != 'http') return null;

    final host = uri.host.toLowerCase();
    final segments = _compactSegments(uri.pathSegments);

    if (_isHost(host, 'anilist.co')) {
      return _parseAnimeMangaTarget(
        uri: uri,
        segments: segments,
        serviceType: ServicesType.anilist,
      );
    }

    if (_isHost(host, 'myanimelist.net')) {
      return _parseAnimeMangaTarget(
        uri: uri,
        segments: segments,
        serviceType: ServicesType.mal,
      );
    }

    if (_isHost(host, 'simkl.com')) {
      return _parseSimklTarget(uri: uri, segments: segments);
    }

    return null;
  }

  static _MediaDeepLinkTarget? _parseCustomTarget(Uri uri) {
    if (uri.host.toLowerCase() == 'callback' ||
        uri.host.toLowerCase() == 'add-repo') {
      return null;
    }

    final segments = _compactSegments(uri.pathSegments);
    ServicesType? serviceType = _serviceFromToken(uri.host);
    int offset = 0;

    if (serviceType == null && segments.isNotEmpty) {
      serviceType = _serviceFromToken(segments.first);
      if (serviceType != null) {
        offset = 1;
      }
    }

    if (serviceType == null) return null;

    final mediaSegments = segments.skip(offset).toList();

    if (serviceType == ServicesType.simkl) {
      return _parseSimklTarget(uri: uri, segments: mediaSegments);
    }

    return _parseAnimeMangaTarget(
      uri: uri,
      segments: mediaSegments,
      serviceType: serviceType,
    );
  }

  static _MediaDeepLinkTarget? _parseAnimeMangaTarget({
    required Uri uri,
    required List<String> segments,
    required ServicesType serviceType,
  }) {
    if (segments.isEmpty) return null;

    final first = segments.first.toLowerCase();

    if ((first == 'anime.php' || first == 'manga.php') &&
        uri.queryParameters.containsKey('id')) {
      final isManga = first == 'manga.php';
      final id = _extractNumericId(uri.queryParameters['id']!);
      if (id == null) return null;

      return _MediaDeepLinkTarget(
        serviceType: serviceType,
        isManga: isManga,
        mediaId: id,
        initialTabIndex: _parseInitialTabIndex(uri.fragment),
      );
    }

    if (segments.length < 2) return null;

    final type = first;
    final isAnimePath = type == 'anime';
    final isMangaPath = type == 'manga';
    if (!isAnimePath && !isMangaPath) return null;

    final id = _extractNumericId(segments[1]);
    if (id == null) return null;

    return _MediaDeepLinkTarget(
      serviceType: serviceType,
      isManga: isMangaPath,
      mediaId: id,
      initialTabIndex: _parseInitialTabIndex(uri.fragment),
    );
  }

  static _MediaDeepLinkTarget? _parseSimklTarget({
    required Uri uri,
    required List<String> segments,
  }) {
    if (segments.length < 2) return null;

    final type = segments.first.toLowerCase();
    final isMovie = {'movie', 'movies', 'film', 'films'}.contains(type);
    final isSeries = {'anime', 'tv', 'series', 'show', 'shows'}.contains(type);

    if (!isMovie && !isSeries) return null;

    final id = _extractNumericId(segments[1]);
    if (id == null) return null;

    return _MediaDeepLinkTarget(
      serviceType: ServicesType.simkl,
      isManga: false,
      mediaId: '$id*${isMovie ? 'MOVIE' : 'SERIES'}',
      initialTabIndex: _parseInitialTabIndex(uri.fragment),
    );
  }

  static ServicesType? _serviceFromToken(String raw) {
    final token = raw.toLowerCase();
    if (token.contains('anilist')) return ServicesType.anilist;
    if (token.contains('myanimelist') || token == 'mal') {
      return ServicesType.mal;
    }
    if (token.contains('simkl')) return ServicesType.simkl;

    switch (token) {
      case 'anilist':
      case 'al':
        return ServicesType.anilist;
      case 'mal':
      case 'myanimelist':
        return ServicesType.mal;
      case 'simkl':
        return ServicesType.simkl;
      default:
        return null;
    }
  }

  static int _parseInitialTabIndex(String fragment) {
    var tab = fragment.trim().toLowerCase();
    tab = tab.replaceFirst(RegExp(r'^/+'), '');

    switch (tab) {
      case 'watch':
      case 'read':
        return 1;
      case 'comment':
      case 'comments':
        return 2;
      case 'details':
      default:
        return 0;
    }
  }

  static void _openMediaTarget(
    _MediaDeepLinkTarget target, {
    int attempts = 0,
  }) {
    if (!Get.isRegistered<ServiceHandler>() || Get.context == null) {
      if (attempts >= 300) return;
      Future.delayed(const Duration(milliseconds: 200), () {
        _openMediaTarget(target, attempts: attempts + 1);
      });
      return;
    }

    final handler = Get.find<ServiceHandler>();
    if (handler.serviceType.value != target.serviceType) {
      handler.changeService(target.serviceType);
    }

    _openHydratedMediaTarget(target);
  }

  static Future<void> _openHydratedMediaTarget(
      _MediaDeepLinkTarget target) async {

    AnilistMediaData? mediaData;
    
    try {
      final fetchedMedia = await serviceHandler.fetchAnimeDetails(
        FetchDetailsParams(
          id: target.mediaId,
          isManga: target.isManga,
        ),
      );

      mediaData = fetchedMedia;
    } catch (_) {
      // Fallback
    }

    final tag = 'deep-link-${DateTime.now().millisecondsSinceEpoch}';

    CarousaleData smallMedia = CarousaleData(
       id: target.mediaId, 
       image: mediaData?.coverImage ?? '', 
       title: mediaData?.title ?? ''
    );

    if (target.isManga) {
      Get.to(() => MangaDetailsScreen(
            tagg: tag,
            smallMedia: smallMedia,
          ));
    } else {
      Get.to(() => AnimeDetailsScreen(
            tagg: tag,
            smallMedia: smallMedia,
          ));
    }
  }

  static bool _isHost(String host, String domain) {
    return host == domain || host.endsWith('.$domain');
  }

  static List<String> _compactSegments(List<String> segments) {
    return segments.where((s) => s.trim().isNotEmpty).toList();
  }

  static String? _extractNumericId(String raw) {
    return RegExp(r'\d+').firstMatch(raw)?.group(0);
  }
}

class _MediaDeepLinkTarget {
  final ServicesType serviceType;
  final bool isManga;
  final String mediaId;
  final int initialTabIndex;

  const _MediaDeepLinkTarget({
    required this.serviceType,
    required this.isManga,
    required this.mediaId,
    required this.initialTabIndex,
  });
}
