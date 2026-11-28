import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as max;
import 'package:anymex_extension_runtime_bridge/ExtensionManager.dart';
import 'package:anymex_extension_runtime_bridge/Models/DEpisode.dart';
import 'package:azyx/Constants/constants.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/online_subtitles_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/watchium_model.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/watchium_service.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/widgets/watchium_sheet.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/bottom_sheets.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/episode_list_drawer.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/indicator.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/m3_slider.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/color_profiler.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

enum ResizeModes { contain, cover, fill }

class WatchController extends GetxController with WidgetsBindingObserver {
  late Player player;
  late VideoController controller;
  late WatchiumService watchiumService;
  final Rx<bool> showControls = true.obs;
  final Rx<bool> isControlsLocked = false.obs;
  final Rx<bool> showEpisodesBox = false.obs;
  final RxList<Episode> filteredEpisodes = RxList();
  final Rx<AnimeAllData> animeData = AnimeAllData().obs;
  final Rx<String> episodeNumber = '1'.obs;
  final Rx<String> episodeTitle = ''.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final Rx<Duration> buffered = Duration.zero.obs;
  final Rx<double> selectedSpeed = 1.0.obs;
  final Rx<ResizeModes> currentMode = ResizeModes.contain.obs;
  final Rx<bool> isSeeking = false.obs;
  final Rx<bool> _volumeInterceptEventStream = false.obs;
  final Rx<double> _volumeValue = 0.0.obs;
  final Rx<double> _brightnessValue = 0.0.obs;
  final Rx<bool> isPotraitOrientaion = false.obs;
  final Rx<String> selectedSbt = ''.obs;
  final Rx<bool> isPlaying = false.obs;
  final Rx<bool> isBuffering = false.obs;
  final Rx<int> doubleTapLable = 0.obs;
  final Rx<int> skipDuration = 0.obs;
  final Rx<bool> isLeftSide = false.obs;
  final Rx<bool> _volumeIndicator = false.obs;
  final Rx<bool> _brightnessIndicator = false.obs;
  final Rx<bool> isPressed = false.obs;
  final Rx<bool> isPlayerReady = false.obs;
  final RxList<String> subtitleText = <String>[].obs;
  final Set<String> _failedUrls = {};
  bool _isSwitchingFallback = false;
  final currentVisualProfile = ColorProfileManager.loadSavedProfile().obs;
  Timer? updateTimer;
  Timer? doubleTapTimer;
  Timer? hideControlsTimer;
  Timer? _volumeTimer;
  Timer? _brightnessTimer;
  Timer? _positionUpdateTimer;
  Timer? _heartbeatTimer;
  StreamSubscription? _roomStateSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  DeviceOrientation _currentLandscapeOrientation =
      DeviceOrientation.landscapeLeft;
  DateTime _lastOrientationCheck = DateTime.fromMillisecondsSinceEpoch(0);
  void initializePlayer(AnimeAllData playerData) {
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _initHorizontalAutoRotation();
    if (!Get.isRegistered<WatchiumService>()) {
      watchiumService = Get.put(WatchiumService());
    } else {
      watchiumService = Get.find<WatchiumService>();
    }
    intializeData(playerData);
    int? startSec = playerData.startFromSeconds;
    if (startSec == null || startSec <= 0) {
      final savedEntry = localHistoryController.animeWatchingHistory
          .firstWhereOrNull(
            (item) => item.mediaId == int.tryParse(playerData.id ?? ''),
          );
      if (savedEntry != null &&
          savedEntry.progress == 'EP ${playerData.number}' &&
          savedEntry.currentTimeSeconds != null &&
          savedEntry.currentTimeSeconds! > 0) {
        startSec = savedEntry.currentTimeSeconds;
      }
    }
    final initialStart = (startSec != null && startSec > 0)
        ? Duration(seconds: startSec)
        : Duration.zero;
    position.value = initialStart;

    final selectedVideo =
        playerData.episodeUrls.firstWhereOrNull(
          (v) => v.url == playerData.url,
        ) ??
        (playerData.episodeUrls.isNotEmpty
            ? playerData.episodeUrls.first
            : null);
    final referer =
        selectedVideo?.headers?['referer'] ??
        selectedVideo?.headers?['Referer'] ??
        '';
    final origin =
        selectedVideo?.headers?['origin'] ??
        selectedVideo?.headers?['Origin'] ??
        '';
    final userAgent =
        selectedVideo?.headers?['user-agent'] ??
        selectedVideo?.headers?['User-Agent'] ??
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

    final Map<String, String> headers = {'User-Agent': userAgent};
    if (selectedVideo?.headers != null && selectedVideo!.headers!.isNotEmpty) {
      selectedVideo.headers!.forEach((k, v) => headers[k] = v);
    } else {
      if (referer.isNotEmpty) headers['Referer'] = referer;
      if (origin.isNotEmpty) headers['Origin'] = origin;
    }

    updateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => localHistoryEntry(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (isClosed) return;
        player = Player(
          configuration: const PlayerConfiguration(
            bufferSize: 64 * 1024 * 1024,
          ),
        );
        _configurePlayerStreaming();
        controller = VideoController(
          player,
          configuration: const VideoControllerConfiguration(
            androidAttachSurfaceAfterVideoParameters: true,
          ),
        );
        isPlayerReady.value = true;
        _setupPlayerListeners();
        applySavedProfile();
        if (playerData.url != null && playerData.url!.isNotEmpty) {
          final bool shouldPlay =
              (watchiumService.inRoom && !watchiumService.isHost.value)
              ? (watchiumService.roomState.value?.playback?.isPlaying ?? false)
              : true;
          player.open(
            Media(playerData.url!, start: initialStart, httpHeaders: headers),
            play: shouldPlay,
          );
        }
        updateEntry();
        _handleVolumeAndBrightness();
        if (watchiumService.inRoom && !watchiumService.isHost.value) {
          final pb = watchiumService.roomState.value?.playback;
          if (pb != null) {
            if (pb.positionSec > 0) {
              player.seek(Duration(seconds: pb.positionSec.toInt()));
            }
            if (pb.isPlaying) {
              player.play();
            } else {
              player.pause();
            }
          }
        }
        syncHostContentWithWatchium();
        final currentEpisode = playerData.episodeList?.firstWhereOrNull(
          (e) => e.number == playerData.number,
        );
        if (playerData.episodeUrls.isEmpty &&
            currentEpisode != null &&
            currentEpisode.url != null) {
          _fetchFreshEpisodeUrls(currentEpisode, initialStart: initialStart);
        }
      });
    });
  }

  Future<void> _fetchFreshEpisodeUrls(
    Episode episode, {
    Duration? initialStart,
  }) async {
    final url = episode.url!;
    log("fetching fresh links in background: $url");
    try {
      final response = await sourceController.activeSource.value!.methods
          .getVideoList(
            DEpisode(
              episodeNumber: episodeNumber.value,
              url: url,
              sortMap: episode.effectiveSortMap,
            ),
          );
      if (response.isNotEmpty) {
        final currentPos = position.value > Duration.zero
            ? position.value
            : (initialStart ?? Duration.zero);
        final quality =
            response.firstWhereOrNull((i) => i.url == animeData.value.url) ??
            response.first;
        final isDifferentUrl = quality.url != animeData.value.url;
        animeData.value.episodeUrls = response;
        animeData.value.url = quality.url;
        localHistoryEntry();
        if (isDifferentUrl || player.state.playlist.medias.isEmpty) {
          player.open(
            Media(
              quality.url,
              start: currentPos,
              httpHeaders: {
                'Referer':
                    quality.headers?['referer'] ??
                    quality.headers?['Referer'] ??
                    (sourceController.activeSource.value?.baseUrl ?? ''),
                'Origin':
                    quality.headers?['origin'] ??
                    quality.headers?['Origin'] ??
                    (sourceController.activeSource.value?.baseUrl ?? ''),
                'User-Agent':
                    quality.headers?['user-agent'] ??
                    quality.headers?['User-Agent'] ??
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              },
            ),
          );
        }
      }
    } catch (e, stack) {
      log("Error fetching fresh links in background: $e , $stack");
    }
  }

  void _tryNextFallbackLink(String errorMessage) {
    if (_isSwitchingFallback) return;
    final currentUrl = animeData.value.url;
    if (currentUrl != null && currentUrl.isNotEmpty) {
      _failedUrls.add(currentUrl);
    }
    final nextVideo = animeData.value.episodeUrls.firstWhereOrNull(
      (v) => v.url.isNotEmpty && !_failedUrls.contains(v.url),
    );
    if (nextVideo == null) {
      azyxSnackBar('All stream links failed to play for this episode');
      return;
    }
    _isSwitchingFallback = true;
    final label =
        (nextVideo.title != null &&
            nextVideo.title!.isNotEmpty &&
            nextVideo.title!.toLowerCase() != 'null')
        ? nextVideo.title!
        : nextVideo.quality;
    azyxSnackBar('Stream error — switching to $label');
    animeData.value.url = nextVideo.url;
    final baseUrl = sourceController.activeSource.value?.baseUrl ?? '';
    final headers = <String, String>{
      'Referer':
          nextVideo.headers?['referer'] ??
          nextVideo.headers?['Referer'] ??
          baseUrl,
      'Origin':
          nextVideo.headers?['origin'] ??
          nextVideo.headers?['Origin'] ??
          baseUrl,
      'User-Agent':
          nextVideo.headers?['user-agent'] ??
          nextVideo.headers?['User-Agent'] ??
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    };
    player
        .open(
          Media(nextVideo.url, start: position.value, httpHeaders: headers),
          play: true,
        )
        .whenComplete(() {
          _isSwitchingFallback = false;
        });
  }

  void _setupPlayerListeners() {
    player.stream.error.listen((err) {
      log('[MediaKit Player Error] $err');
      _tryNextFallbackLink(err);
    });
    player.stream.subtitle.listen((lines) {
      subtitleText.assignAll(lines);
    });
    player.stream.log.listen((msg) {
      log('[MediaKit Player Log] $msg');
    });
    player.stream.playing.listen((p) {
      isPlaying.value = p;
      if (watchiumService.inRoom) {
        if (watchiumService.isHost.value) {
          final pos = position.value.inSeconds.toDouble();
          if (p) {
            watchiumService.sendPlay(positionSec: pos);
          } else {
            watchiumService.sendPause(positionSec: pos);
          }
        } else {
          final pb = watchiumService.roomState.value?.playback;
          if (pb != null && !pb.isPlaying && p) {
            player.pause();
          }
        }
      }
    });
    player.stream.buffering.listen((b) {
      isBuffering.value = b;
      if (!b && watchiumService.inRoom && !watchiumService.isHost.value) {
        final pb = watchiumService.roomState.value?.playback;
        if (pb != null && pb.isPlaying) {
          final liveHostPos = pb.positionSec;
          final currentSec = position.value.inSeconds;
          if ((liveHostPos - currentSec).abs() > 1.5) {
            player.seek(Duration(seconds: liveHostPos.toInt()));
          }
        }
      }
    });
    player.stream.buffer.listen((d) {
      buffered.value = d;
    });
    player.stream.position.listen((p) {
      position.value = p;
    });
    player.stream.duration.listen((d) {
      totalDuration.value = d;
    });
    ever(watchiumService.isHost, (isHost) {
      _heartbeatTimer?.cancel();
      if (isHost && watchiumService.inRoom) {
        _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (!watchiumService.inRoom || !watchiumService.isHost.value) {
            timer.cancel();
            return;
          }
          final pos = position.value.inSeconds.toDouble();
          watchiumService.sendHeartbeat(pos, isPlaying.value);
        });
      }
    });
    _heartbeatTimer?.cancel();
    if (watchiumService.inRoom && watchiumService.isHost.value) {
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!watchiumService.inRoom || !watchiumService.isHost.value) {
          timer.cancel();
          return;
        }
        final pos = position.value.inSeconds.toDouble();
        watchiumService.sendHeartbeat(pos, isPlaying.value);
      });
    }
    _roomStateSubscription?.cancel();
    _roomStateSubscription = watchiumService.roomState.listen((state) {
      if (state == null || watchiumService.isHost.value) return;
      final pb = state.playback;
      if (pb != null) {
        if (pb.isPlaying) {
          if (!player.state.playing) {
            player.play();
          }
          final currentSec = position.value.inSeconds;
          final diff = (currentSec - pb.positionSec).abs();
          if (diff > 3.0) {
            player.seek(Duration(seconds: pb.positionSec.toInt()));
          }
        } else {
          if (player.state.playing) {
            player.pause();
          }
        }
      }
      final cnt = state.content;
      if (cnt?.videoUrl != null &&
          cnt!.videoUrl!.isNotEmpty &&
          cnt.videoUrl != animeData.value.url) {
        log('[Watchium] Joiner player opening host videoUrl: ${cnt.videoUrl}');
        animeData.value.url = cnt.videoUrl;
        player.open(
          Media(
            cnt.videoUrl!,
            start: Duration(seconds: pb?.positionSec.toInt() ?? 0),
            httpHeaders: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            },
          ),
        );
        if (pb != null && pb.isPlaying) {
          player.play();
        }
      }
    });
  }

  void syncHostContentWithWatchium() {
    if (!watchiumService.inRoom || !watchiumService.isHost.value) return;
    final data = animeData.value;
    final int epNum = int.tryParse(data.number ?? '') ?? 1;
    log(
      '[Watchium] Host syncing content -> title: ${data.title}, videoUrl: ${data.url}, episodeUrls len: ${data.episodeUrls.length}',
    );

    final servers = data.episodeUrls.asMap().entries.map((entry) {
      final video = entry.value;
      final String u = video.url;
      final String streamType = () {
        final lower = u.toLowerCase();
        if (lower.contains('.m3u8') || lower.contains('m3u8')) return 'hls';
        if (lower.contains('.mp4')) return 'mp4';
        if (lower.contains('.mpd')) return 'dash';
        return 'other';
      }();
      return WatchiumAnimeServer(
        serverId: u,
        serverName: video.quality,
        quality: video.quality,
        type: streamType,
        url: video.url,
        originalUrl: video.url,
        headers: video.headers,
      );
    }).toList();

    if (servers.isEmpty && data.url != null && data.url!.isNotEmpty) {
      final String u = data.url!;
      final String streamType = () {
        final lower = u.toLowerCase();
        if (lower.contains('.m3u8') || lower.contains('m3u8')) return 'hls';
        if (lower.contains('.mp4')) return 'mp4';
        if (lower.contains('.mpd')) return 'dash';
        return 'other';
      }();
      servers.add(
        WatchiumAnimeServer(
          serverId: u,
          serverName: data.source ?? 'Default',
          type: streamType,
          url: u,
          originalUrl: u,
        ),
      );
    }

    final content = WatchiumAnimeContent(
      animeId: data.id ?? '1',
      animeTitle: data.title ?? 'Anime',
      animeCoverImage: data.image,
      episodeNumber: epNum,
      availableServers: servers,
      videoUrl: data.url,
      sourceName: data.source,
    );
    watchiumService.setContent(content);
    final pos = position.value.inSeconds.toDouble();
    if (pos > 0) {
      watchiumService.sendSeek(pos);
    }
  }

  void localHistoryEntry() {
    final data = animeData.value;
    final resolvedId = data.id ?? serviceHandler.currentMedia.value.id;
    if (resolvedId == null) return;
    final resolvedTitle = data.title ?? serviceHandler.currentMedia.value.title;
    final resolvedImage = data.image ?? serviceHandler.currentMedia.value.image;

    final String episodeUrlsJson = jsonEncode(
      data.episodeUrls.map((e) => e.toJson()).toList(),
    );
    final activeSource = sourceController.activeSource.value;
    final entry = LocalHistoryItem()
      ..mediaId = int.tryParse(resolvedId)
      ..title = resolvedTitle
      ..image = resolvedImage
      ..link = data.url
      ..sourceName = data.source ?? activeSource?.name
      ..sourceId = activeSource?.id?.toString()
      ..progress = 'EP ${data.number ?? episodeNumber.value}'
      ..currentTimeSeconds = position.value.inSeconds
      ..totalDurationSeconds = totalDuration.value.inSeconds > 0
          ? totalDuration.value.inSeconds
          : null
      ..mediaType = HistoryMediaType.anime
      ..episodeList = data.episodeList
      ..episodeUrlsJson = episodeUrlsJson;
    Future.microtask(() => localHistoryController.addToWatchingHistory(entry));
  }

  void updateEntry() async {
    if (animeData.value.id != null) {
      if (serviceHandler.currentMedia.value.id == null ||
          serviceHandler.currentMedia.value.id != animeData.value.id) {
        serviceHandler.currentMedia.value.id = animeData.value.id;
        serviceHandler.currentMedia.value.title ??= animeData.value.title;
        serviceHandler.currentMedia.value.image ??= animeData.value.image;
      }
    }
    if (serviceHandler.currentMedia.value.id == null) return;
    Utils.log(
      'aando: ${animeData.value.id}  ${serviceHandler.currentMedia.value.id ?? ''}',
    );
    await serviceHandler.updateListEntry(
      serviceHandler.currentMedia.value,
      isAnime: true,
    );
  }

  void _initHorizontalAutoRotation() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      _accelerometerSub = accelerometerEventStream().listen((event) {
        final now = DateTime.now();
        if (now.difference(_lastOrientationCheck).inMilliseconds < 250) {
          return;
        }
        _lastOrientationCheck = now;
        if (isControlsLocked.value || isPotraitOrientaion.value) return;

        DeviceOrientation? target;
        if (event.x > 2.5) {
          target = DeviceOrientation.landscapeLeft;
        } else if (event.x < -2.5) {
          target = DeviceOrientation.landscapeRight;
        }

        if (target != null && target != _currentLandscapeOrientation) {
          _currentLandscapeOrientation = target;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          SystemChrome.setPreferredOrientations([target]);
        }
      });
    } catch (_) {}
  }

  Future<void> _handleVolumeAndBrightness() async {
    final volumeController = VolumeController.instance;
    volumeController.showSystemUI = false;
    _volumeValue.value = await volumeController.getVolume();
    volumeController.addListener((value) {
      if (!_volumeInterceptEventStream.value) {
        _volumeValue.value = value;
      }
    });
    if (Platform.isAndroid || Platform.isIOS) {
      _brightnessValue.value = await ScreenBrightness.instance.current;
      ScreenBrightness.instance.onCurrentBrightnessChanged.listen((value) {
        _brightnessValue.value = value;
      });
    }
  }

  void intializeData(AnimeAllData playerData) {
    animeData.value = playerData;
    episodeNumber.value = playerData.number ?? '1';
    episodeTitle.value =
        playerData.episodeTitle ?? 'Episode ${playerData.number ?? '1'}';
    filteredEpisodes.value = playerData.episodeList ?? [];
    if (playerData.id != null) {
      if (serviceHandler.currentMedia.value.id == null ||
          serviceHandler.currentMedia.value.id != playerData.id) {
        serviceHandler.currentMedia.value.id = playerData.id;
        serviceHandler.currentMedia.value.title ??= playerData.title;
        serviceHandler.currentMedia.value.image ??= playerData.image;
      }
    }
  }

  void changeResizeMode() {
    currentMode.value =
        ResizeModes.values[(ResizeModes.values.indexOf(currentMode.value) + 1) %
            ResizeModes.values.length];
  }

  BoxFit getMode(Rx<ResizeModes> mode) {
    switch (mode.value) {
      case ResizeModes.contain:
        return BoxFit.contain;
      case ResizeModes.cover:
        return BoxFit.cover;
      case ResizeModes.fill:
        return BoxFit.fill;
    }
  }

  IconData getModeIcon(Rx<ResizeModes> mode) {
    switch (mode.value) {
      case ResizeModes.contain:
        return Icons.fit_screen;
      case ResizeModes.cover:
        return Icons.zoom_out_map;
      case ResizeModes.fill:
        return Icons.fullscreen;
    }
  }

  Future<void> loadEpisodeurl(String url) async {
    log("new ${sourceController.activeSource.value!.name!}");
    try {
      final episode = animeData.value.episodeList?.firstWhereOrNull(
        (e) => e.url == url,
      );
      final response = await sourceController.activeSource.value!.methods
          .getVideoList(
            DEpisode(
              episodeNumber: episodeNumber.value,
              url: url,
              sortMap: episode?.effectiveSortMap,
            ),
          );
      if (response.isNotEmpty) {
        final quality = animeData.value.episodeUrls.firstWhere(
          (i) => i.url == animeData.value.url,
          orElse: () => animeData.value.episodeUrls.first,
        );
        log("Quality: ${quality.quality}");
        final result = response.firstWhere(
          (i) => i.quality == quality.quality,
          orElse: () => response.first,
        );
        animeData.value.episodeUrls = response;
        animeData.value.url = result.url;
        localHistoryEntry();
        player.open(
          Media(
            result.url,
            httpHeaders: {
              'Referer':
                  result.headers?['referer'] ??
                  result.headers?['Referer'] ??
                  sourceController.activeSource.value!.baseUrl!,
              'Origin':
                  result.headers?['origin'] ??
                  result.headers?['Origin'] ??
                  sourceController.activeSource.value!.baseUrl!,
              'User-Agent':
                  result.headers?['user-agent'] ??
                  result.headers?['User-Agent'] ??
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            },
          ),
        );
      } else {
        log("extracting error when fetching link");
      }
    } catch (e, stack) {
      log("Error while loading episode url: $e , $stack");
    }
  }

  Future<void> _configurePlayerStreaming() async {
    final platform = player.platform;
    if (platform == null) return;
    const props = <String, String>{
      'cache': 'yes',
      'cache-on-disk': 'no',
      'demuxer-max-bytes': '134217728',
      'demuxer-max-back-bytes': '33554432',
      'cache-secs': '120',
      'demuxer-readahead-secs': '30',
      'network-timeout': '15',
      'hls-bitrate': 'max',
    };
    for (final entry in props.entries) {
      try {
        await (platform as dynamic).setProperty(entry.key, entry.value);
      } catch (_) {}
    }
  }

  void applySavedProfile() => ColorProfileManager().applySavedProfile(player);
  void showColorProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorProfileBottomSheet(
        currentProfile: currentVisualProfile.value,
        player: player,
        videoController: controller,
        onProfileSelected: (profile) {
          Utils.log('Selected profile: $profile');
          currentVisualProfile.value = profile;
        },
        onCustomSettingsChanged: (settings) {
          Utils.log('Custom settings applied: $settings');
          currentVisualProfile.value = 'custom';
        },
      ),
    );
  }

  void doubleTap(TapDownDetails details, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition;
    final isLeft = tapPosition.dx < screenWidth / 2;
    seek10Seconds(isLeft);
  }

  void seekTo(Duration pos) {
    player.seek(pos);
    if (watchiumService.inRoom && watchiumService.isHost.value) {
      watchiumService.sendSeek(pos.inSeconds.toDouble());
    }
  }

  void seek10Seconds(bool isLeft) {
    isSeeking.value = true;
    isLeftSide.value = isLeft;
    doubleTapLable.value += 10;
    skipDuration.value += 10;
    final newPosition = isLeft
        ? max.max(0, position.value.inSeconds - 10).seconds
        : max
              .min(totalDuration.value.inSeconds, position.value.inSeconds + 10)
              .seconds;
    position.value = newPosition;
    seekTo(Duration(seconds: newPosition.inSeconds));
    doubleTapTimer?.cancel();
    doubleTapTimer = Timer(const Duration(milliseconds: 750), () {
      isSeeking.value = false;
      doubleTapLable.value = 0;
      skipDuration.value = 0;
    });
  }

  Future<void> setVolume(double value) async {
    try {
      VolumeController.instance.setVolume(value);
    } catch (_) {}
    _volumeValue.value = value;
    _volumeIndicator.value = true;
    _volumeInterceptEventStream.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      _volumeIndicator.value = false;
      _volumeInterceptEventStream.value = false;
    });
  }

  Future<void> setBrightness(double value) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await ScreenBrightness.instance.setScreenBrightness(value);
      }
    } catch (_) {}
    if (Platform.isAndroid || Platform.isIOS) {
      _brightnessIndicator.value = true;
      _brightnessTimer?.cancel();
      _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
        _brightnessIndicator.value = false;
      });
    }
  }

  void handleControlsTap() {
    showControls.value = !showControls.value;
    hideControlsTimer?.cancel();
    if (showControls.value) {
      hideControlsTimer = Timer(
        const Duration(milliseconds: 5000),
        () => showControls.value = false,
      );
    }
  }

  void handleVerticalDrag(DragUpdateDetails e, BuildContext context) async {
    if (!isControlsLocked.value) {
      final delta = e.primaryDelta ?? 0.0;
      final Offset position = e.localPosition;
      if (position.dx <= MediaQuery.of(context).size.width / 2) {
        final brightness = _brightnessValue.value - delta / 500;
        final result = brightness.clamp(0.0, 1.0);
        setBrightness(result.toDouble());
      } else {
        final volume = _volumeValue.value - delta / 500;
        final result = volume.clamp(0.0, 1.0);
        setVolume(result.toDouble());
      }
    }
  }

  void changeEpisode(bool isNext) {
    _failedUrls.clear();
    if (anilistAuthController.userData.value.name != null) {
      anilistAddToListController.updateAnimeProgress(
        animeData.value,
        double.tryParse(episodeNumber.value)?.toInt() ?? 1,
      );
      azyxSnackBar("Tracking Episode $episodeNumber");
    }
    final index = filteredEpisodes.indexWhere(
      (i) => i.number == episodeNumber.value,
    );
    if (isNext && filteredEpisodes.length > index) {
      log("Next");
      player.open(Media(""));
      episodeTitle.value = filteredEpisodes[index + 1].title!;
      episodeNumber.value = filteredEpisodes[index + 1].number;
      animeData.value.episodeTitle = filteredEpisodes[index + 1].title!;
      animeData.value.number = filteredEpisodes[index + 1].number;
      loadEpisodeurl(filteredEpisodes[index + 1].url!);
    } else if (index > 0) {
      log("previous");
      player.open(Media(""));
      episodeTitle.value = filteredEpisodes[index - 1].title!;
      episodeNumber.value = filteredEpisodes[index - 1].number;
      animeData.value.episodeTitle = filteredEpisodes[index - 1].title!;
      animeData.value.number = filteredEpisodes[index - 1].number;
      loadEpisodeurl(filteredEpisodes[index - 1].url!);
    } else {
      log("No episode");
    }
  }

  void onEpisodeSelected(Episode item) {
    _failedUrls.clear();
    if (anilistAuthController.userData.value.name != null) {
      anilistAddToListController.updateAnimeProgress(
        animeData.value,
        double.tryParse(episodeNumber.value)?.toInt() ?? 1,
      );
      azyxSnackBar("Tracking Episode $episodeNumber");
    }
    player.open(Media(""));
    episodeTitle.value = item.title!;
    episodeNumber.value = item.number;
    animeData.value.title = item.title!;
    animeData.value.number = item.number;
    showEpisodesBox.value = false;
    loadEpisodeurl(item.url!);
  }

  String getFormattedTime(int timeInSeconds) {
    String formatTime(int val) {
      return val.toString().padLeft(2, '0');
    }

    int hours = timeInSeconds ~/ 3600;
    int minutes = (timeInSeconds % 3600) ~/ 60;
    int seconds = timeInSeconds % 60;
    String formattedHours = hours == 0 ? '' : formatTime(hours);
    String formattedMins = formatTime(minutes);
    String formattedSeconds = formatTime(seconds);
    return "${formattedHours.isNotEmpty ? "$formattedHours:" : ''}$formattedMins:$formattedSeconds";
  }

  BoxDecoration _playerPillDecoration(
    BuildContext context, {
    double radius = 24,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surface.withOpacity(0.76),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        width: 0.8,
        color: colorScheme.outlineVariant.withOpacity(0.28),
      ),
    );
  }

  Widget _playerIconButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    double size = 20,
    Color? color,
  }) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      splashRadius: 18,
      icon: Icon(icon, color: resolvedColor, size: size),
    );
  }

  Widget backButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: _playerPillDecoration(context, radius: 20),
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget topRightControls(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: _playerPillDecoration(context, radius: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _playerIconButton(
            context: context,
            onPressed: () {
              showEpisodesBox.value = true;
            },
            icon: Icons.playlist_play_rounded,
            size: 22,
          ),
          _playerIconButton(
            context: context,
            onPressed: () {
              showColorProfileSheet(context);
            },
            icon: Icons.tune_rounded,
            size: 19,
          ),
          _playerIconButton(
            context: context,
            onPressed: () {
              showEnhancedSubtitleSheet(
                animeData,
                selectedSbt,
                context,
                player: player,
              );
            },
            icon: Icons.subtitles_rounded,
            size: 19,
          ),
          // _playerIconButton(
          //   context: context,
          //   onPressed: () {
          //     showWatchiumSheet(context, animeData: animeData.value);
          //   },
          //   icon: Icons.group_rounded,
          //   size: 19,
          // ),
          _playerIconButton(
            context: context,
            onPressed: () {
              showQualitySheet(
                context,
                animeData,
                player,
                position,
                isPotraitOrientaion,
                onLinkSelected: () => _failedUrls.clear(),
              );
            },
            icon: Icons.hd_rounded,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget episodeTitleWidget(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => AzyXText(
                    text:
                        "Episode ${episodeNumber.value}: ${episodeTitle.value}",
                    fontVariant: FontVariant.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() {
                  final state = watchiumService.roomState.value;
                  final code = watchiumService.roomCode.value;
                  if (state == null || code.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.white,
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        AzyXText(
                          text: 'LIVE • $code',
                          color: Colors.white,
                          fontSize: 10,
                          fontVariant: FontVariant.bold,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          AzyXText(
            text: animeData.value.title ?? '',
            color: const Color.fromARGB(255, 190, 190, 190),
            fontSize: 13,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget topControls(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        backButton(context),
        const SizedBox(width: 12),
        episodeTitleWidget(context),
        const SizedBox(width: 12),
        topRightControls(context),
      ],
    );
  }

  Widget bottomRightControls(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _playerPillDecoration(context, radius: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _playerIconButton(
            context: context,
            onPressed: () {
              isControlsLocked.value = !isControlsLocked.value;
            },
            icon: isControlsLocked.value
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
            size: 18,
          ),
          if ((Platform.isAndroid || Platform.isIOS) && !isControlsLocked.value)
            _playerIconButton(
              context: context,
              onPressed: () {
                isPotraitOrientaion.value = !isPotraitOrientaion.value;
                SystemChrome.setPreferredOrientations(
                  isPotraitOrientaion.value
                      ? [DeviceOrientation.portraitUp]
                      : [
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ],
                );
              },
              icon: isPotraitOrientaion.value
                  ? Icons.screen_rotation_rounded
                  : Icons.stay_current_portrait_rounded,
              size: 18,
            ),
          if (!isControlsLocked.value)
            Obx(
              () => _playerIconButton(
                context: context,
                onPressed: () {
                  changeResizeMode();
                  azyxSnackBar(currentMode.value.name);
                },
                icon: getModeIcon(currentMode),
                size: 19,
              ),
            ),
        ],
      ),
    );
  }

  Widget seek10Widget(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _playerPillDecoration(context, radius: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _playerIconButton(
            context: context,
            onPressed: () {
              seek10Seconds(true);
            },
            icon: Icons.replay_10_rounded,
            size: 20,
          ),
          _playerIconButton(
            context: context,
            onPressed: () {
              seek10Seconds(false);
            },
            icon: Icons.forward_10_rounded,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget speedButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showSpeedBottomList(
            context,
            speedList,
            selectedSpeed,
            player,
            isPotraitOrientaion,
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: _playerPillDecoration(context, radius: 18),
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed_rounded,
                  color: colorScheme.onSurface,
                  size: 17,
                ),
                const SizedBox(width: 5),
                AzyXText(
                  text: '${selectedSpeed.value}x',
                  fontSize: 12,
                  fontVariant: FontVariant.bold,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget seek85(BuildContext context, bool isLeft) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final target = isLeft
              ? max.max(0, position.value.inSeconds - 85)
              : max.min(
                  totalDuration.value.inSeconds,
                  position.value.inSeconds + 85,
                );
          position.value = Duration(seconds: target);
          seekTo(Duration(seconds: target));
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: _playerPillDecoration(context, radius: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    Icon(
                      Icons.fast_rewind_rounded,
                      color: colorScheme.onSurface,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    AzyXText(
                      text: '-85s',
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontVariant: FontVariant.bold,
                    ),
                  ]
                : [
                    AzyXText(
                      text: '+85s',
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontVariant: FontVariant.bold,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.fast_forward_rounded,
                      color: colorScheme.onSurface,
                      size: 16,
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget bottomPotraitControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isControlsLocked.value) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              seek85(context, true),
              speedButton(context),
              seek85(context, false),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isControlsLocked.value
                ? const SizedBox.shrink()
                : seek10Widget(context),
            bottomRightControls(context),
          ],
        ),
      ],
    );
  }

  Widget bottomLeftControls(BuildContext context) {
    return isControlsLocked.value
        ? const SizedBox.shrink()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              seek85(context, true),
              const SizedBox(width: 8),
              speedButton(context),
            ],
          );
  }

  Widget bottomControls(BuildContext context) {
    return isPotraitOrientaion.value
        ? bottomPotraitControls(context)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              bottomLeftControls(context),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isControlsLocked.value) ...[
                    seek85(context, false),
                    const SizedBox(width: 8),
                  ],
                  bottomRightControls(context),
                ],
              ),
            ],
          );
  }

  Widget buildIconButton({
    required BuildContext context,
    required VoidCallback ontap,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 46,
          height: 46,
          decoration: _playerPillDecoration(context, radius: 23),
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.onSurface, size: 26),
        ),
      ),
    );
  }

  Widget centerControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildIconButton(
          context: context,
          ontap: () {
            changeEpisode(false);
          },
          icon: Icons.skip_previous_rounded,
        ),
        const SizedBox(width: 28),
        Obx(
          () => isBuffering.value
              ? const SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(child: LoadingIndicatorM3E()),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => player.playOrPause(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.35),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: colorScheme.onPrimary,
                        size: 36,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 28),
        buildIconButton(
          context: context,
          ontap: () {
            changeEpisode(true);
          },
          icon: Icons.skip_next_rounded,
        ),
      ],
    );
  }

  Widget lockedCenterControls() {
    return Center(
      child: isBuffering.value
          ? const LoadingIndicatorM3E()
          : const SizedBox.shrink(),
    );
  }

  Widget customControls(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 110,
          child: IgnorePointer(
            child: Obx(
              () => AnimatedOpacity(
                opacity: showControls.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: IgnorePointer(
            child: Obx(
              () => AnimatedOpacity(
                opacity: showControls.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isPotraitOrientaion.value ? 14 : 12,
                horizontal: isPotraitOrientaion.value ? 16 : 24,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Obx(
                      () => isControlsLocked.value
                          ? const SizedBox.shrink()
                          : AnimatedOpacity(
                              opacity: showControls.value ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              child: AnimatedSlide(
                                offset: showControls.value
                                    ? Offset.zero
                                    : const Offset(0, -0.15),
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                child: topControls(context),
                              ),
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Obx(
                        () => AnimatedOpacity(
                          opacity: showControls.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: isControlsLocked.value
                              ? lockedCenterControls()
                              : centerControls(context),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Obx(
                      () => AnimatedOpacity(
                        opacity: showControls.value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: AnimatedSlide(
                          offset: showControls.value
                              ? Offset.zero
                              : const Offset(0, 0.15),
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  AzyXText(
                                    text: getFormattedTime(
                                      position.value.inSeconds,
                                    ),
                                    fontVariant: FontVariant.bold,
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const AzyXText(
                                    text: ' / ',
                                    fontVariant: FontVariant.bold,
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                  AzyXText(
                                    text: getFormattedTime(
                                      totalDuration.value.inSeconds,
                                    ),
                                    fontVariant: FontVariant.bold,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              CustomSlider(
                                min: 0.0,
                                max: totalDuration.value.inSeconds > 0
                                    ? totalDuration.value.inSeconds.toDouble()
                                    : 0.0,
                                secondaryTrackValue:
                                    totalDuration.value.inSeconds > 0
                                    ? buffered.value.inSeconds.toDouble()
                                    : 0.0,
                                indiactorTime: getFormattedTime(
                                  position.value.inSeconds,
                                ),
                                value: totalDuration.value.inSeconds > 0.0
                                    ? double.parse(
                                        position.value.inSeconds
                                            .toStringAsFixed(2),
                                      )
                                    : 0.0,
                                theme: const M3SliderTheme(
                                  height: 18,
                                  trackHeight: 6,
                                  outerRadius: 6,
                                  innerRadius: 2,
                                  thumbGap: 6,
                                  edgeInset: 2,
                                  thumbWidth: 4,
                                  thumbHeight: 20,
                                  thumbCornerRadius: 2,
                                ),
                                onDragEnd: (value) {
                                  seekTo(Duration(seconds: value.toInt()));
                                  player.play();
                                },
                                isLocked: isControlsLocked.value,
                                onChanged: (value) {
                                  position.value = Duration(
                                    seconds: value.toInt(),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              bottomControls(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRippleEffect(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          final isLeft = isLeftSide.value;
          final seeking = isSeeking.value;
          final skip = skipDuration.value;
          return Align(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              height: double.infinity,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                opacity: seeking ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isLeft
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      end: isLeft
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: isLeft
                        ? const BorderRadius.horizontal(
                            right: Radius.circular(180),
                          )
                        : const BorderRadius.horizontal(
                            left: Radius.circular(180),
                          ),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: seeking ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.58),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.16),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLeft
                                ? Icons.fast_rewind_rounded
                                : Icons.fast_forward_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          AzyXText(
                            text: isLeft ? '-${skip}s' : '+${skip}s',
                            fontVariant: FontVariant.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget preesedBar() {
    return AnimatedPositioned(
      top: isPotraitOrientaion.value ? 100 : 40,
      duration: const Duration(milliseconds: 300),
      child: Obx(
        () => AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isPressed.value ? 1.0 : 0.0,
          child: AnimatedContainer(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            duration: const Duration(milliseconds: 300),
            child: const Row(
              children: [
                AzyXText(text: "2.0x ", fontVariant: FontVariant.bold),
                Icon(Broken.forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget volumeIndicator() {
    return Positioned.fill(
      child: Obx(
        () => AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: _volumeIndicator.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: MediaIndicatorBuilder(
            value: _volumeValue.value,
            isVolumeIndicator: true,
          ),
        ),
      ),
    );
  }

  Widget brightnessIndicator() {
    return Positioned.fill(
      child: Obx(
        () => AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: _brightnessIndicator.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: MediaIndicatorBuilder(
            value: _brightnessValue.value,
            isVolumeIndicator: false,
          ),
        ),
      ),
    );
  }

  Widget episodeListDrawer() {
    return EpisodeListDrawer(
      ontap: onEpisodeSelected,
      isPotraitOrientaion: isPotraitOrientaion,
      showEpisodesBox: showEpisodesBox,
      animeData: animeData,
      episodeNumber: episodeNumber,
      filteredEpisodes: filteredEpisodes,
    );
  }

  Widget buildSubtitleOverlay(BuildContext context) {
    return Obx(() {
      final rawLines = subtitleText.toList();
      if (rawLines.isEmpty) return const SizedBox.shrink();
      final htmlRx = RegExp(r'<[^>]*>');
      final assRx = RegExp(r'\{[^}]*\}');
      final newlineRx = RegExp(r'\\[nN]');
      final cleaned = rawLines
          .where((l) => l.trim().isNotEmpty)
          .join('\n')
          .replaceAll(htmlRx, '')
          .replaceAll(assRx, '')
          .replaceAll(newlineRx, '\n')
          .trim();
      if (cleaned.isEmpty) return const SizedBox.shrink();
      final fontSize = settingsController.subtitleFontSize.value;
      final textColor = settingsController.resolveSubtitleTextColor();
      final bgColor = settingsController.resolveSubtitleBgColor();
      final outlineColor = settingsController.resolveSubtitleOutlineColor();
      final outlineWidth = settingsController.subtitleOutlineWidth.value;
      final baseOffset = showControls.value ? 72.0 : 0.0;
      final bottomPos =
          baseOffset + settingsController.subtitleBottomMargin.value;
      final opacity = settingsController.subtitleOpacity.value.clamp(0.1, 1.0);
      return AnimatedPositioned(
        left: 24,
        right: 24,
        bottom: bottomPos,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (outlineWidth > 0)
                      Text(
                        cleaned,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = outlineWidth * 2
                            ..color = outlineColor,
                        ),
                      ),
                    Text(
                      cleaned,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildReactionsOverlay() {
    return Obx(() {
      final state = watchiumService.roomState.value;
      final rxList = watchiumService.reactions;
      if (state == null || rxList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Positioned(
        bottom: 110,
        right: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: rxList.map((r) {
            return Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AzyXText(
                    text: '${r.username}: ',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  Text(r.emoji, style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      localHistoryEntry();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    _roomStateSubscription?.cancel();
    _roomStateSubscription = null;
    _accelerometerSub?.cancel();
    _accelerometerSub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    if (isPlayerReady.value) {
      player.dispose();
    }
    localHistoryEntry();
    updateTimer?.cancel();
    doubleTapTimer?.cancel();
    hideControlsTimer?.cancel();
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    _positionUpdateTimer?.cancel();
    super.onClose();
  }
}
