import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/services/episode_metadata_service.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Widgets/anime/episodes_list.dart';
import 'package:azyx/Widgets/custom_drop_down.dart';
import 'package:azyx/Widgets/list_editor_sheet.dart';
import 'package:azyx/utils/source_mapper.dart';
import 'package:azyx/Screens/Anime/Details/widgets/wrong_title_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnimeDetailsController extends GetxController {
  final Rx<AnilistMediaData> mediaData = AnilistMediaData().obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final RxBool isFavourite = false.obs;
  final RxString listStatus = ''.obs;
  final RxInt listProgress = 0.obs;

  final RxList<Episode> episodesList = RxList<Episode>();
  final RxBool isFetchingEpisodes = false.obs;
  final RxBool extensionError = false.obs;
  final RxString mappedExtensionTitle = ''.obs;
  final Rx<Source?> activeSource = Rx<Source?>(null);

  final RxString activeTab = 'ov'.obs;
  final RxString toastMessage = ''.obs;
  final RxBool isToastVisible = false.obs;
  Timer? _toastTimer;

  final RxBool isSearchOpen = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<AnilistMediaData> searchResults = RxList<AnilistMediaData>();
  final RxBool isSearching = false.obs;
  final RxBool searchHasError = false.obs;
  Timer? _searchDebounce;

  final RxString selectedSeason = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString episodeFilter = ''.obs;
  final RxInt selectedRangeIndex = 0.obs;
  final RxInt totalUnrangedEpisodes = 0.obs;
  final RxList<Episode> filteredEpisodes = RxList<Episode>();

  final Map<String, GlobalKey> sectionKeys = {
    'ov': GlobalKey(),
    'ch': GlobalKey(),
    'rl': GlobalKey(),
    'ep': GlobalKey(),
    'cm': GlobalKey(),
  };

  final ScrollController scrollController = ScrollController();
  bool _isManualScrolling = false;

  int? currentAnimeId;
  bool isOfflineMode = false;
  OfflineItem? offlineItemData;
  int _sourceRequestVersion = 0;

  int _beginSourceRequest() {
    SourceMapper.interruptMapping();
    sourceController.cancelInProgress('search');
    sourceController.cancelInProgress('detail');
    return ++_sourceRequestVersion;
  }

  bool _isStaleSourceRequest(int reqId) => reqId != _sourceRequestVersion;

  @override
  void onInit() {
    super.onInit();
    activeSource.value = sourceController.activeSource.value;
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _toastTimer?.cancel();
    _searchDebounce?.cancel();
    SourceMapper.interruptMapping();
    sourceController.cancelInProgress('search');
    sourceController.cancelInProgress('detail');
    super.onClose();
  }

  Future<void> initialize({
    required int animeId,
    OfflineItem? offlineData,
    bool isOffline = false,
  }) async {
    currentAnimeId = animeId;
    isOfflineMode = isOffline;
    offlineItemData = offlineData;

    isLoading.value = true;
    error.value = '';

    if (isOffline && offlineData?.mediaData != null) {
      mediaData.value = offlineData!.mediaData!;
      episodesList.assignAll(offlineData.episodesList ?? []);
      _initFilters();
      _applyFilters();
      isLoading.value = false;
      return;
    }

    await _loadSplitData(animeId);
  }

  Future<void> _loadSplitData(int animeId) async {
    isLoading.value = mediaData.value.title == null || mediaData.value.title == '??';

    Future.microtask(() async {
      _fetchContentFromSource();
    });

    try {
      final primaryData = await serviceHandler.fetchAnimeDetails(
        FetchDetailsParams(id: animeId.toString()),
      );
      if (primaryData.id != null) {
        _mergeMedia(primaryData);
        _syncInitialStatus(primaryData);
      }
    } catch (e) {
      log('serviceHandler.fetchAnimeDetails error: $e');
    } finally {
      isLoading.value = false;
    }

    try {
      final secondary = await anilistDataController.fetchAnilistAnimeDetails(animeId);
      _mergeSecondaryData(secondary);
      if (episodesList.isEmpty && !isFetchingEpisodes.value) {
        _fetchContentFromSource();
      }
    } catch (e) {
      log('secondary AniList fetch error: $e');
    }
  }

  void _fetchContentFromSource() {
    final title = mediaData.value.title ?? mediaData.value.titleRomaji;
    if (title != null && title.isNotEmpty && title != '??') {
      fetchEpisodes();
    }
  }

  void _mergeMedia(AnilistMediaData fresh) {
    final cur = mediaData.value;
    mediaData.value = AnilistMediaData(
      id: fresh.id ?? cur.id,
      title: (fresh.title != null && fresh.title != '??') ? fresh.title : cur.title,
      titleRomaji: fresh.titleRomaji ?? cur.titleRomaji,
      titleNative: fresh.titleNative ?? cur.titleNative,
      episodes: fresh.episodes ?? cur.episodes,
      description: fresh.description ?? cur.description,
      image: fresh.image ?? cur.image,
      coverImage: fresh.coverImage ?? cur.coverImage,
      rating: fresh.rating ?? cur.rating,
      type: fresh.type ?? cur.type,
      status: fresh.status ?? cur.status,
      popularity: fresh.popularity ?? cur.popularity,
      timeUntilAiring: fresh.timeUntilAiring ?? cur.timeUntilAiring,
      genres: fresh.genres ?? cur.genres,
      synonyms: fresh.synonyms ?? cur.synonyms,
      studios: fresh.studios ?? cur.studios,
      season: fresh.season ?? cur.season,
      duration: fresh.duration ?? cur.duration,
      source: fresh.source ?? cur.source,
      startDate: fresh.startDate ?? cur.startDate,
      endDate: fresh.endDate ?? cur.endDate,
      trailerUrl: fresh.trailerUrl ?? cur.trailerUrl,
      trailerThumbnail: fresh.trailerThumbnail ?? cur.trailerThumbnail,
      pictures: fresh.pictures ?? cur.pictures,
      characters: fresh.characters ?? cur.characters,
      relations: fresh.relations ?? cur.relations,
      recommendations: fresh.recommendations ?? cur.recommendations,
      servicesType: fresh.servicesType ?? cur.servicesType,
      mediaType: fresh.mediaType ?? cur.mediaType,
      color: fresh.color ?? cur.color,
      favourites: fresh.favourites ?? cur.favourites,
      meanScore: fresh.meanScore ?? cur.meanScore,
      siteUrl: fresh.siteUrl ?? cur.siteUrl,
      countryOfOrigin: fresh.countryOfOrigin ?? cur.countryOfOrigin,
      nextEpisodeNumber: fresh.nextEpisodeNumber ?? cur.nextEpisodeNumber,
      nextEpisodeAiringAt: fresh.nextEpisodeAiringAt ?? cur.nextEpisodeAiringAt,
      rankingsList: fresh.rankingsList ?? cur.rankingsList,
      tagsList: fresh.tagsList ?? cur.tagsList,
      scoreDistribution: fresh.scoreDistribution ?? cur.scoreDistribution,
      statusDistribution: fresh.statusDistribution ?? cur.statusDistribution,
      mediaListEntry: fresh.mediaListEntry ?? cur.mediaListEntry,
      isFavourite: fresh.isFavourite ?? cur.isFavourite,
      bannerImage: fresh.bannerImage ?? cur.bannerImage,
      seasonYear: fresh.seasonYear ?? cur.seasonYear,
      startYear: fresh.startYear ?? cur.startYear,
      startMonth: fresh.startMonth ?? cur.startMonth,
      startDay: fresh.startDay ?? cur.startDay,
      endYear: fresh.endYear ?? cur.endYear,
      endMonth: fresh.endMonth ?? cur.endMonth,
      endDay: fresh.endDay ?? cur.endDay,
    );
  }

  void _mergeSecondaryData(AnilistMediaData sec) {
    final cur = mediaData.value;
    mediaData.value = AnilistMediaData(
      id: cur.id ?? sec.id,
      title: cur.title ?? sec.title,
      titleRomaji: cur.titleRomaji ?? sec.titleRomaji,
      titleNative: cur.titleNative ?? sec.titleNative,
      episodes: cur.episodes ?? sec.episodes,
      description: (cur.description != null && cur.description!.isNotEmpty)
          ? cur.description
          : sec.description,
      image: cur.image ?? sec.image,
      coverImage: cur.coverImage ?? sec.coverImage,
      rating: cur.rating ?? sec.rating,
      type: cur.type ?? sec.type,
      status: cur.status ?? sec.status,
      popularity: cur.popularity ?? sec.popularity,
      timeUntilAiring: cur.timeUntilAiring ?? sec.timeUntilAiring,
      genres: (cur.genres != null && cur.genres!.isNotEmpty) ? cur.genres : sec.genres,
      synonyms: (cur.synonyms != null && cur.synonyms!.isNotEmpty) ? cur.synonyms : sec.synonyms,
      studios: (cur.studios != null && cur.studios!.isNotEmpty) ? cur.studios : sec.studios,
      season: cur.season ?? sec.season,
      duration: cur.duration ?? sec.duration,
      source: cur.source ?? sec.source,
      startDate: cur.startDate ?? sec.startDate,
      endDate: cur.endDate ?? sec.endDate,
      trailerUrl: cur.trailerUrl ?? sec.trailerUrl,
      trailerThumbnail: cur.trailerThumbnail ?? sec.trailerThumbnail,
      pictures: (cur.pictures != null && cur.pictures!.isNotEmpty) ? cur.pictures : sec.pictures,
      characters: (sec.characters != null && sec.characters!.isNotEmpty)
          ? sec.characters
          : cur.characters,
      relations: (sec.relations != null && sec.relations!.isNotEmpty)
          ? sec.relations
          : cur.relations,
      recommendations: (sec.recommendations != null && sec.recommendations!.isNotEmpty)
          ? sec.recommendations
          : cur.recommendations,
      servicesType: cur.servicesType ?? sec.servicesType,
      mediaType: cur.mediaType ?? sec.mediaType,
      color: sec.color ?? cur.color,
      favourites: sec.favourites ?? cur.favourites,
      meanScore: sec.meanScore ?? cur.meanScore,
      siteUrl: sec.siteUrl ?? cur.siteUrl,
      countryOfOrigin: sec.countryOfOrigin ?? cur.countryOfOrigin,
      nextEpisodeNumber: sec.nextEpisodeNumber ?? cur.nextEpisodeNumber,
      nextEpisodeAiringAt: sec.nextEpisodeAiringAt ?? cur.nextEpisodeAiringAt,
      rankingsList: (sec.rankingsList != null && sec.rankingsList!.isNotEmpty)
          ? sec.rankingsList
          : cur.rankingsList,
      tagsList: (sec.tagsList != null && sec.tagsList!.isNotEmpty)
          ? sec.tagsList
          : cur.tagsList,
      scoreDistribution: (sec.scoreDistribution != null && sec.scoreDistribution!.isNotEmpty)
          ? sec.scoreDistribution
          : cur.scoreDistribution,
      statusDistribution: (sec.statusDistribution != null && sec.statusDistribution!.isNotEmpty)
          ? sec.statusDistribution
          : cur.statusDistribution,
      mediaListEntry: cur.mediaListEntry ?? sec.mediaListEntry,
      isFavourite: cur.isFavourite ?? sec.isFavourite,
      bannerImage: sec.bannerImage ?? cur.bannerImage,
      seasonYear: cur.seasonYear ?? sec.seasonYear,
      startYear: cur.startYear ?? sec.startYear,
      startMonth: cur.startMonth ?? sec.startMonth,
      startDay: cur.startDay ?? sec.startDay,
      endYear: cur.endYear ?? sec.endYear,
      endMonth: cur.endMonth ?? sec.endMonth,
      endDay: cur.endDay ?? sec.endDay,
    );
  }

  Future<void> loadAnimeData(int animeId) async {
    await _loadSplitData(animeId);
  }

  void _syncInitialStatus(AnilistMediaData media) {
    isFavourite.value = media.isFavourite ?? false;
    if (media.mediaListEntry != null && media.mediaListEntry!.status != null) {
      listStatus.value = _mapAniListStatusToDisplay(media.mediaListEntry!.status!);
      listProgress.value = media.mediaListEntry!.progress ?? 0;
    } else if (serviceHandler.isLoggedIn.value) {
      final existing = serviceHandler.userAnimeList.firstWhereOrNull(
        (e) => e.id == media.id,
      );
      if (existing != null) {
        listStatus.value = _mapAniListStatusToDisplay(existing.status ?? '');
        listProgress.value = existing.progress ?? 0;
      }
    }
  }

  String _mapAniListStatusToDisplay(String status) {
    switch (status.toUpperCase()) {
      case 'CURRENT':
        return 'Currently watching';
      case 'PLANNING':
        return 'Plan to watch';
      case 'COMPLETED':
        return 'Completed';
      case 'REPEATING':
        return 'Rewatching';
      case 'PAUSED':
        return 'Paused';
      case 'DROPPED':
        return 'Dropped';
      default:
        return status;
    }
  }

  String _mapDisplayStatusToAniList(String display) {
    switch (display) {
      case 'Currently watching':
        return 'CURRENT';
      case 'Plan to watch':
        return 'PLANNING';
      case 'Completed':
        return 'COMPLETED';
      case 'Rewatching':
        return 'REPEATING';
      case 'Paused':
        return 'PAUSED';
      case 'Dropped':
        return 'DROPPED';
      default:
        return display;
    }
  }

  Future<void> toggleFavourite() async {
    final animeId = currentAnimeId;
    if (animeId == null) return;

    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isEmpty) {
      showToast('Sign in to AniList to favourite this');
      return;
    }

    final previous = isFavourite.value;
    isFavourite.value = !previous;
    showToast(isFavourite.value ? 'Added to favourites' : 'Removed from favourites');

    final success = await serviceHandler.toggleFavourite(animeId);
    if (!success) {
      isFavourite.value = previous;
      showToast('Failed to update favourites');
    }
  }

  Future<void> setMediaListStatus(String status) => setListStatus(status);
  Future<void> deleteFromList() => setListStatus(null);

  Future<void> saveMediaListEntry(ListEditorResult result) async {
    final animeId = currentAnimeId;
    if (animeId == null) return;
    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isEmpty) {
      showToast('Sign in to AniList to save this');
      return;
    }
    final previousStatus = listStatus.value;
    final previousProgress = listProgress.value;
    listStatus.value = _mapAniListStatusToDisplay(result.status);
    listProgress.value = result.progress;
    try {
      await serviceHandler.updateListEntry(
        UserMedia(
          id: animeId.toString(),
          status: result.status,
          score: result.score > 0 ? result.score : null,
          progress: result.progress,
          startedAt: result.startedAt,
          completedAt: result.completedAt,
          isPrivate: result.isPrivate,
          repeat: result.repeat,
        ),
        isAnime: true,
      );
      showToast('Saved to ${listStatus.value.toLowerCase()}');
    } catch (_) {
      listStatus.value = previousStatus;
      listProgress.value = previousProgress;
      showToast('Failed to update list');
    }
  }

  Future<void> setListStatus(String? newDisplayStatus) async {
    final animeId = currentAnimeId;
    if (animeId == null) return;

    final token = AuthKeys.anilistToken.get<String>('');
    if (token.isEmpty) {
      showToast('Sign in to AniList to save this');
      return;
    }

    final previousStatus = listStatus.value;
    final previousProgress = listProgress.value;

    if (newDisplayStatus == null || newDisplayStatus.isEmpty) {
      listStatus.value = '';
      showToast('Removed from list');

      final entryId = mediaData.value.mediaListEntry?.id;
      if (entryId != null) {
        final success = await serviceHandler.deleteMediaListEntry(entryId);
        if (!success) {
          listStatus.value = previousStatus;
          showToast('Failed to remove from list');
        }
      }
      return;
    }

    listStatus.value = newDisplayStatus;
    showToast('Added to ${newDisplayStatus.toLowerCase()}');

    final aniStatus = _mapDisplayStatusToAniList(newDisplayStatus);
    try {
      await serviceHandler.updateListEntry(
        UserMedia(
          id: animeId.toString(),
          status: aniStatus,
          progress: previousProgress > 0 ? previousProgress : 1,
        ),
        isAnime: true,
      );
    } catch (_) {
      listStatus.value = previousStatus;
      showToast('Failed to update list');
    }
  }

  Future<void> fetchEpisodes() async {
    if (sourceController.installedExtensions.isEmpty) {
      extensionError.value = true;
      return;
    }

    if (sourceController.activeSource.value == null) {
      sourceController.setActiveSource(sourceController.installedExtensions.first);
    }
    activeSource.value = sourceController.activeSource.value;

    final reqId = _beginSourceRequest();
    isFetchingEpisodes.value = true;
    extensionError.value = false;
    episodesList.clear();
    filteredEpisodes.clear();

    try {
      final titles = [
        mediaData.value.title ?? '',
        mediaData.value.titleRomaji ?? '',
        mediaData.value.titleNative ?? '',
      ].where((t) => t.isNotEmpty).toList();

      final result = await SourceMapper.mapMedia(
        titles,
        (mediaData.value.title ?? '').obs,
        mediaId: mediaData.value.id ?? currentAnimeId.toString(),
        type: ItemType.anime,
        synonyms: mediaData.value.synonyms ?? [],
      );

      if (isClosed || _isStaleSourceRequest(reqId)) return;

      if (result != null && result.url != null) {
        mappedExtensionTitle.value = result.title ?? '';
        await fetchEpisodesForLink(result.url!, reqId: reqId);
      } else {
        extensionError.value = true;
      }
    } catch (e) {
      if (isClosed || _isStaleSourceRequest(reqId)) return;
      log('fetchEpisodes error: $e');
      extensionError.value = true;
    } finally {
      if (!isClosed && !_isStaleSourceRequest(reqId)) {
        isFetchingEpisodes.value = false;
      }
    }
  }

  Future<void> fetchEpisodesForLink(String link, {int? reqId}) async {
    final activeReqId = reqId ?? _beginSourceRequest();
    final token = 'detail_${currentAnimeId ?? ''}_$activeReqId';
    sourceController.updateToken('detail', token);
    try {
      final episodeResult = await sourceController.activeSource.value!.methods
          .getDetail(DMedia.withUrl(link));

      if (isClosed || _isStaleSourceRequest(activeReqId)) return;

      final rawList = List<DEpisode>.from(episodeResult.episodes ?? []);
      rawList.sort((a, b) {
        final typeA = a.sortMap?['type']?.toLowerCase() ?? '';
        final typeB = b.sortMap?['type']?.toLowerCase() ?? '';
        int typeRank(String type) {
          if (type == 'subbed') return 0;
          if (type == 'dubbed') return 1;
          if (type.isNotEmpty) return 2;
          return 3;
        }

        final rankA = typeRank(typeA);
        final rankB = typeRank(typeB);
        if (rankA != rankB) return rankA.compareTo(rankB);

        final seasonA = int.tryParse(a.sortMap?['season'] ?? '') ?? 1;
        final seasonB = int.tryParse(b.sortMap?['season'] ?? '') ?? 1;
        if (seasonA != seasonB) return seasonA.compareTo(seasonB);

        final numA = double.tryParse(a.episodeNumber);
        final numB = double.tryParse(b.episodeNumber);
        if (numA != null && numB != null) return numA.compareTo(numB);
        if (numA != null) return -1;
        if (numB != null) return 1;
        return (a.name ?? '').compareTo(b.name ?? '');
      });

      final mapped = rawList.map((e) => mChapterToEpisode(e, episodeResult)).toList();
      episodesList.assignAll(mapped);

      if (episodesList.isNotEmpty) {
        await _enrichWithAnifyData();
      }

      _initFilters();
      _applyFilters();
    } catch (e) {
      log('_fetchEpisodesForLink error: $e');
      extensionError.value = true;
    }
  }

  Future<void> _enrichWithAnifyData() async {
    if (!EpisodeMetadataService.isEnabled || currentAnimeId == null) return;
    try {
      final enriched = await EpisodeMetadataService.enrichEpisodes(
        episodes: episodesList.toList(),
        anilistId: currentAnimeId!,
        title: mediaData.value.title ?? mediaData.value.titleRomaji,
      );
      episodesList.assignAll(enriched);
    } catch (e) {
      log('_enrichWithAnifyData error: $e');
    }
  }

  void _initFilters() {
    final seasons = getAvailableSeasons();
    if (seasons.isNotEmpty && !seasons.contains(selectedSeason.value)) {
      selectedSeason.value = seasons.first;
    }
    final types = getAvailableTypes();
    if (types.isNotEmpty && !types.contains(selectedType.value)) {
      final hasSub = types.any((t) => t.toLowerCase() == 'subbed');
      selectedType.value = hasSub
          ? types.firstWhere((t) => t.toLowerCase() == 'subbed')
          : types.first;
    }
  }

  List<String> getAvailableSeasons() {
    final s = episodesList
        .map((e) => e.season)
        .where((season) => season != null && season.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    s.sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    return s;
  }

  List<String> getAvailableTypes() {
    final t = episodesList
        .map((e) => e.type)
        .where((type) => type != null && type.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    t.sort();
    return t;
  }

  void setSeasonFilter(String s) {
    selectedSeason.value = s;
    selectedRangeIndex.value = 0;
    _applyFilters();
  }

  void setTypeFilter(String t) {
    selectedType.value = t;
    selectedRangeIndex.value = 0;
    _applyFilters();
  }

  void setEpisodeRange(int index) {
    selectedRangeIndex.value = index;
    _applyFilters();
  }

  void setEpisodeSearch(String query) {
    episodeFilter.value = query;
    _applyFilters();
  }

  int _rangeChunkSize(int total) => total > 100 ? 50 : 25;

  List<({int index, String label})> getEpisodeRanges() {
    final total = totalUnrangedEpisodes.value;
    final chunk = _rangeChunkSize(total);
    if (total <= chunk) return const [];
    final count = (total / chunk).ceil();
    return List.generate(count, (i) {
      final start = i * chunk + 1;
      final end = (i + 1) * chunk > total ? total : (i + 1) * chunk;
      return (index: i, label: '$start - $end');
    });
  }

  void _applyFilters() {
    final q = episodeFilter.value.toLowerCase().trim();
    var list = episodesList.where((ep) {
      if (q.isNotEmpty) {
        final titleMatch = ep.title?.toLowerCase().contains(q) ?? false;
        final numMatch = ep.number.toLowerCase().contains(q);
        if (!titleMatch && !numMatch) return false;
      }
      if (selectedSeason.value.isNotEmpty) {
        final s = ep.season ?? '1';
        if (s != selectedSeason.value) return false;
      }
      if (selectedType.value.isNotEmpty) {
        final t = ep.type ?? 'Subbed';
        if (t.toLowerCase() != selectedType.value.toLowerCase()) return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      final numA = double.tryParse(a.number);
      final numB = double.tryParse(b.number);
      if (numA != null && numB != null) return numA.compareTo(numB);
      if (numA != null) return -1;
      if (numB != null) return 1;
      return (a.title ?? '').compareTo(b.title ?? '');
    });

    if (q.isNotEmpty) {
      totalUnrangedEpisodes.value = list.length;
      filteredEpisodes.assignAll(list);
      return;
    }

    totalUnrangedEpisodes.value = list.length;
    final chunk = _rangeChunkSize(list.length);
    if (list.length <= chunk || selectedRangeIndex.value == -1) {
      filteredEpisodes.assignAll(list);
      return;
    }

    final maxRange = (list.length / chunk).ceil() - 1;
    final safeIdx = selectedRangeIndex.value.clamp(0, maxRange);
    if (safeIdx != selectedRangeIndex.value) {
      selectedRangeIndex.value = safeIdx;
    }
    final start = safeIdx * chunk;
    final end = (start + chunk) > list.length ? list.length : (start + chunk);
    filteredEpisodes.assignAll(list.sublist(start, end));
  }

  LocalHistoryItem? getLocalHistory() {
    final id = currentAnimeId;
    if (id == null) return null;
    return localHistoryController.animeWatchingHistory.firstWhereOrNull(
      (item) => item.mediaId == id,
    );
  }

  int getNextEpisodeNumber() {
    final history = getLocalHistory();
    if (history?.progress != null) {
      final ep = int.tryParse(history!.progress!);
      if (ep != null) return ep;
    }
    if (listProgress.value > 0) {
      return listProgress.value + 1;
    }
    return 1;
  }

  Future<void> onPrimaryAction(BuildContext context) async {
    if (mediaData.value.status?.toUpperCase() == 'NOT_YET_RELEASED') {
      showToast('Not released yet');
      return;
    }

    if (episodesList.isEmpty) {
      scrollToSection('ep');
      return;
    }

    final targetNumber = getNextEpisodeNumber().toString();
    final episode = episodesList.firstWhereOrNull((e) => e.number == targetNumber) ??
        episodesList.first;

    onEpisodeTapped(context, episode);
  }

  void onEpisodeTapped(BuildContext context, Episode episode) {
    final source = sourceController.activeSource.value;
    if (source == null) {
      showToast('Select an extension first');
      return;
    }

    final scrapeToken =
        'scrape_${DateTime.now().millisecondsSinceEpoch}_${episode.number}_${Random().nextInt(10000)}';
    final sourceEpisode = DEpisode(
      episodeNumber: episode.number,
      url: episode.url,
      sortMap: episode.effectiveSortMap,
    );

    final methods = source.methods;
    final nativeStream = methods.getVideoListStream(
      sourceEpisode,
      parameters: SourceParams(cancelToken: scrapeToken),
    );
    final stream = nativeStream ??
        () async* {
          try {
            final list = await methods.getVideoList(
              sourceEpisode,
              parameters: SourceParams(cancelToken: scrapeToken),
            );
            for (final video in list) {
              yield video;
            }
          } catch (e) {
            log('getVideoList error: $e');
          }
        }();

    final hasErrorRx = false.obs;
    final epTitleRx = (episode.title ?? '').obs;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      enableDrag: true,
      elevation: 5,
      barrierColor: Colors.black87.withValues(alpha: 0.5),
      builder: (_) {
        return StreamEpisodeSheet(
          stream: stream,
          number: episode.number,
          title: mediaData.value.title ?? '',
          image: mediaData.value.coverImage ?? mediaData.value.image ?? '',
          id: currentAnimeId.toString(),
          episodeList: episodesList,
          episodeTitle: epTitleRx,
          hasError: hasErrorRx,
        );
      },
    ).whenComplete(() {
      source.cancelRequest(scrapeToken);
    });
  }

  void showToast(String message) {
    toastMessage.value = message;
    isToastVisible.value = true;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      isToastVisible.value = false;
    });
  }

  void openSearch() {
    isSearchOpen.value = true;
    searchQuery.value = '';
    searchResults.clear();
    searchHasError.value = false;
  }

  void closeSearch() {
    isSearchOpen.value = false;
    _searchDebounce?.cancel();
  }

  void onSearchInput(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    searchHasError.value = false;

    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final results = await anilistDataController.searchAnilistQuick(q);
        searchResults.assignAll(results);
      } catch (e) {
        searchHasError.value = true;
      } finally {
        isSearching.value = false;
      }
    });
  }

  void scrollToSection(String sectionId) {
    activeTab.value = sectionId;
  }

  void _onScroll() {}

  Future<void> loadData() async {
    if (currentAnimeId != null) {
      await loadAnimeData(currentAnimeId!);
    }
  }

  Future<void> loadExtensionEpisodes() async {
    await fetchEpisodes();
  }

  void switchExtension(Source source) {
    _beginSourceRequest();
    sourceController.setActiveSource(source);
    activeSource.value = source;
    selectedSeason.value = '';
    selectedType.value = '';
    episodeFilter.value = '';
    episodesList.clear();
    filteredEpisodes.clear();
    fetchEpisodes();
  }

  void openSourceSelector(BuildContext context) {
    final installed = sourceController.installedExtensions;
    if (installed.isEmpty) {
      showToast('No extensions installed');
      return;
    }

    CustomSourceDropdown.showSourceSheet(
      context: context,
      items: installed.toList(),
      currentSource: activeSource.value ?? sourceController.activeSource.value,
      labelText: 'Source',
      onChanged: (value) {
        if (value != null) {
          final matched = installed.firstWhere(
            (i) =>
                i.id.toString() == value ||
                '${i.name}_${i.id}' == value ||
                i.name == value,
            orElse: () => installed.first,
          );
          switchExtension(matched);
        }
      },
    );
  }

  void openWrongTitleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WrongTitleSheet(controller: this),
    );
  }
}
