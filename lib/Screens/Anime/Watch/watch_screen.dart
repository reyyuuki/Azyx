import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as max;
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/local_history.dart';
import 'package:azyx/Constants/constants.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/bottom_sheets.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/custom_controls.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/episode_list_drawer.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/indicator.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/api/Mangayomi/Search/getVideo.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/color_profiler.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class WatchScreen extends StatefulWidget {
  final AnimeAllData playerData;
  const WatchScreen({super.key, required this.playerData});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

enum ResizeModes {
  contain,
  cover,
  fill,
}

class _WatchScreenState extends State<WatchScreen> with WidgetsBindingObserver {
  late Player player;
  late VideoController controller;
  final Rx<bool> showControls = true.obs;
  final Rx<bool> isControlsLocked = false.obs;
  final Rx<bool> showEpisodesBox = false.obs;
  final RxList<Episode> filteredEpisodes = RxList();
  final Rx<AnimeAllData> animeData = AnimeAllData().obs;
  final Rx<String> episodeNumber = '1'.obs;
  final Rx<String> episodeTitle = ''.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final Rx<double> selectedSpeed = 1.0.obs;
  final Rx<ResizeModes> currentMode = ResizeModes.contain.obs;
  final Rx<bool> isSeeking = false.obs;
  final Rx<bool> _volumeInterceptEventStream = false.obs;
  final Rx<double> _volumeValue = 0.0.obs;
  final Rx<double> _brightnessValue = 0.0.obs;
  final Rx<bool> isPotraitOrientaion = false.obs;
  final Rx<String> selectedSbt = ''.obs;
  final Rx<LocalHistory> localHistoryData = LocalHistory().obs;
  Timer? updateTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    updateEntry();
    player = Player();
    controller = VideoController(player,
        configuration: const VideoControllerConfiguration(
            androidAttachSurfaceAfterVideoParameters: true));
    if (mounted) {
      intializeData();
      for (var element in widget.playerData.episodeUrls!) {
        log("Headers: ${element.headers} / ${widget.playerData.source!.baseUrl!}");
      }
      log("Headers: ${widget.playerData.episodeUrls!.first.headers} / ${widget.playerData.source!.baseUrl!}");
      player.open(
        Media(
          widget.playerData.url!,
          httpHeaders: {
            'Referer':
                widget.playerData.episodeUrls!.first.headers?['Referer'] ??
                    widget.playerData.source!.baseUrl!,
            'Origin': widget.playerData.episodeUrls!.first.headers?['Origin'] ??
                widget.playerData.source!.baseUrl!,
            'User-Agent': widget
                    .playerData.episodeUrls!.first.headers?['user-agent'] ??
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
        ),
      );

      _handleVolumeAndBrightness();
      updateTimer = Timer.periodic(
          const Duration(minutes: 1), (timer) => localHistoryEntry());
    }
  }

  void localHistoryEntry() {
    localHistoryData.value = LocalHistory(
        animeData: animeData.value,
        progress: episodeNumber.value,
        totalDuration: totalDuration.value,
        currentTime: position.value,
        mediaId: widget.playerData.id,
        link: widget.playerData.url,
        lastTime:
            Duration(seconds: DateTime.now().microsecondsSinceEpoch ~/ 1000));
    localHistoryController.addToWatchingHistory(localHistoryData.value);
  }

  void updateEntry() async {
    await serviceHandler.updateListEntry(anilistAddToListController.anime.value,
        isAnime: true);
  }

  Future<void> _handleVolumeAndBrightness() async {
    final volumeController = VolumeController.instance;

    volumeController.showSystemUI = false;
    _volumeValue.value = await volumeController.getVolume();
    volumeController.addListener((value) {
      if (mounted && !_volumeInterceptEventStream.value) {
        _volumeValue.value = value;
      }
    });
    if (Platform.isAndroid || Platform.isIOS) {
      _brightnessValue.value = await ScreenBrightness.instance.current;
      ScreenBrightness.instance.onCurrentBrightnessChanged.listen((value) {
        if (mounted) {
          _brightnessValue.value = value;
        }
      });
    }
  }

  void intializeData() {
    animeData.value = widget.playerData;
    episodeNumber.value = widget.playerData.number!;
    episodeTitle.value = widget.playerData.episodeTitle!;
    filteredEpisodes.value = widget.playerData.episodeList!;
    localHistoryEntry();
  }

  void changeResizeMode() {
    currentMode.value = ResizeModes.values[
        (ResizeModes.values.indexOf(currentMode.value) + 1) %
            ResizeModes.values.length];
  }

  Future<void> loadEpisodeurl(String url) async {
    log("new ${widget.playerData.source!.name!}");
    try {
      final response =
          await getVideo(source: widget.playerData.source!, url: url);
      if (response.isNotEmpty) {
        final quality = animeData.value.episodeUrls!.firstWhere(
            (i) => i.url == animeData.value.url,
            orElse: () => animeData.value.episodeUrls!.first);
        log("Quality: ${quality.quality}");
        final result = response.firstWhere((i) => i.quality == quality.quality,
            orElse: () => response.first);
        animeData.value.episodeUrls = response;
        animeData.value.url = result.url;
        localHistoryEntry();
        player.open(Media(result.url));
      } else {
        log("extracting error when fetching link");
      }
    } catch (e, stack) {
      log("Error while loading episode url: $e , $stack");
    }
  }

  final currentVisualProfile = 'natural'.obs;

  void applySavedProfile() => ColorProfileManager()
      .applyColorProfile(currentVisualProfile.value, player);
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    player.dispose();
    localHistoryEntry();
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      localHistoryEntry();
    }
  }

  Widget topControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        backButton(),
        const SizedBox(width: 10),
        episodeTitleWidget(),
        topRightControls(),
      ],
    );
  }

  GestureDetector backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: AzyXContainer(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(40)),
        child: const Icon(
          Broken.arrow_left_2,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }

  void showColorProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorProfileBottomSheet(
        currentProfile: currentVisualProfile.value,
        player: player,
        onProfileSelected: (profile) {
          Utils.log('Selected profile: $profile');
          currentVisualProfile.value = profile;
          // settings.preferences.put('currentVisualProfile', profile);
        },
        onCustomSettingsChanged: (settings) {
          Utils.log('Custom settings applied: $settings');
        },
      ),
    );
  }

  AzyXContainer topRightControls() {
    return AzyXContainer(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6)),
          color: Colors.black.withOpacity(0.6)),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showEpisodesBox.value = true;
            },
            icon: const Icon(
              Broken.video,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              showColorProfileSheet(context);
            },
            icon: const Icon(
              Broken.blur,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              showSubtitleSheet(animeData, selectedSbt, context,
                  player: player);
            },
            icon: const Icon(
              Iconsax.subtitle_bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              showQualitySheet(
                  context, animeData, player, position, isPotraitOrientaion);
            },
            icon: const Icon(
              Icons.high_quality,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Expanded episodeTitleWidget() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AzyXContainer(
            alignment: Alignment.topLeft,
            child: Obx(
              () => AzyXText(
                text: "Episode ${episodeNumber.value}: ${episodeTitle.value}",
                fontVariant: FontVariant.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                maxLines: 2,
              ),
            ),
          ),
          AzyXContainer(
            alignment: Alignment.topLeft,
            child: AzyXText(
              text: widget.playerData.title!,
              color: const Color.fromARGB(255, 190, 190, 190),
              fontSize: 13,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Column bottomPotraitControls() {
    return Column(
      children: [
        isControlsLocked.value
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [seek85(true), speedButton(), seek85(false)],
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isControlsLocked.value ? const SizedBox.shrink() : seek10Widget(),
            bottomRightControls()
          ],
        )
      ],
    );
  }

  Widget bottomControls() {
    return isPotraitOrientaion.value
        ? bottomPotraitControls()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              bottomLeftControls(),
              Row(
                children: [
                  isControlsLocked.value
                      ? const SizedBox.shrink()
                      : seek85(false),
                  bottomRightControls(),
                ],
              ),
            ],
          );
  }

  AzyXContainer bottomRightControls() {
    return AzyXContainer(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6)),
          color: Colors.black.withOpacity(0.6)),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              isControlsLocked.value = !isControlsLocked.value;
            },
            icon: Icon(
              isControlsLocked.value
                  ? Icons.lock_rounded
                  : Icons.lock_open_rounded,
              color: Colors.white,
            ),
          ),
          if (Platform.isAndroid || Platform.isIOS)
            isControlsLocked.value
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      isPotraitOrientaion.value = false;
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.landscapeLeft]);
                    },
                    icon: const Icon(
                      Icons.screen_rotation,
                      color: Colors.white,
                    ),
                  ),
          if (Platform.isAndroid || Platform.isIOS)
            isControlsLocked.value
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      isPotraitOrientaion.value = true;
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp]);
                    },
                    icon: const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                    ),
                  ),
          isControlsLocked.value
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    changeResizeMode();
                    azyxSnackBar(currentMode.value.name);
                  },
                  icon: Obx(
                    () => Icon(
                      getModeIcon(currentMode),
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget bottomLeftControls() {
    return isControlsLocked.value
        ? const SizedBox.shrink()
        : Row(
            children: [
              seek85(true),
              speedButton(),
            ],
          );
  }

  AzyXContainer seek10Widget() {
    return AzyXContainer(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.black.withOpacity(0.6)),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              seek10Seconds(true);
            },
            icon: const Icon(
              Broken.backward_10_seconds,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              seek10Seconds(false);
            },
            icon: const Icon(
              Broken.forward_10_seconds,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  AzyXContainer speedButton() {
    return AzyXContainer(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6)),
          color: Colors.black.withOpacity(0.6)),
      child: IconButton(
        onPressed: () {
          showSpeedBottomList(
              context, speedList, selectedSpeed, player, isPotraitOrientaion);
        },
        icon: const Icon(
          Iconsax.speedometer_bold,
          color: Colors.white,
        ),
      ),
    );
  }

  AzyXContainer seek85(bool isLeft) {
    return AzyXContainer(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6)),
          color: Colors.black.withOpacity(0.6)),
      child: IconButton(
        onPressed: () {
          player.pause();
          position.value = isLeft
              ? max.max(0, position.value.inSeconds - 85).seconds
              : max.max(0, position.value.inSeconds + 85).seconds;
          player.seek(Duration(seconds: position.value.inSeconds));
          player.play();
        },
        icon: isLeft
            ? const Row(
                children: [
                  Icon(
                    Broken.backward,
                    color: Colors.white,
                  ),
                  AzyXText(
                    text: " -85",
                    color: Colors.white,
                    fontVariant: FontVariant.bold,
                  )
                ],
              )
            : const Row(
                children: [
                  AzyXText(
                    text: "+85 ",
                    fontVariant: FontVariant.bold,
                    color: Colors.white,
                  ),
                  Icon(
                    Broken.forward,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  void doubleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition;
    final isLeft = tapPosition.dx < screenWidth / 2;
    seek10Seconds(isLeft);
  }

  Rx<int> doubleTapLable = 0.obs;
  Rx<int> skipDuration = 0.obs;
  Rx<bool> isLeftSide = false.obs;
  Timer? doubleTapTimer;
  Timer? hideControlsTimer;

  void seek10Seconds(bool isLeft) {
    player.pause();
    isSeeking.value = true;
    isLeftSide.value = isLeft;
    doubleTapLable.value += 10;
    skipDuration.value += 10;

    final newPosition = isLeft
        ? max.max(0, position.value.inSeconds - skipDuration.value).seconds
        : max
            .min(totalDuration.value.inSeconds,
                position.value.inSeconds + skipDuration.value)
            .seconds;

    position.value = newPosition;
    player.seek(Duration(seconds: newPosition.inSeconds));
    player.play();
    doubleTapTimer?.cancel();
    Future.delayed(
        const Duration(milliseconds: 700), () => isSeeking.value = false);
    doubleTapTimer = Timer(const Duration(milliseconds: 1000), () {
      isSeeking.value = false;
      doubleTapLable.value = 0;
      skipDuration.value = 0;
    });
  }

  Widget buildRippleEffect() {
    return Obx(
      () => AnimatedPositioned(
        left: isLeftSide.value ? 0 : MediaQuery.of(context).size.width / 2,
        height: isPotraitOrientaion.value ? Get.height / 2 : Get.height,
        width: MediaQuery.of(context).size.width / 2,
        top: isPotraitOrientaion.value ? (Get.height - Get.width) / 2 : 0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSeeking.value ? 1.0 : 0.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            alignment: Alignment.center,
            curve: Curves.bounceOut,
            decoration: BoxDecoration(
                borderRadius: isLeftSide.value
                    ? const BorderRadius.horizontal(right: Radius.circular(200))
                    : const BorderRadius.horizontal(left: Radius.circular(200)),
                color: Colors.white.withOpacity(0.5)),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isLeftSide.value ? Broken.backward : Broken.forward,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  AzyXText(
                    text: isLeftSide.value
                        ? "-${skipDuration.value}s"
                        : "+${skipDuration.value}s",
                    fontVariant: FontVariant.bold,
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final Rx<bool> _volumeIndicator = false.obs;
  final Rx<bool> _brightnessIndicator = false.obs;
  Timer? _volumeTimer;
  Timer? _brightnessTimer;

  Future<void> setVolume(double value) async {
    try {
      VolumeController.instance.setVolume(value);
    } catch (_) {}
    _volumeValue.value = value;
    _volumeIndicator.value = true;
    _volumeInterceptEventStream.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _volumeIndicator.value = false;
        _volumeInterceptEventStream.value = false;
      }
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
        if (mounted) {
          _brightnessIndicator.value = false;
        }
      });
    }
  }

  final Rx<bool> isPressed = false.obs;

  AnimatedPositioned preesedBar() {
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
                  borderRadius: BorderRadius.circular(20)),
              duration: const Duration(milliseconds: 300),
              child: const Row(
                children: [
                  AzyXText(
                    text: "2.0x ",
                    fontVariant: FontVariant.bold,
                  ),
                  Icon(Broken.forward)
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTapDown: (t) {
          isControlsLocked.value ? null : doubleTap(t);
        },
        onLongPressStart: (d) async {
          isPressed.value = true;
          player.setRate(2.0);
        },
        onLongPressEnd: (d) {
          player.setRate(selectedSpeed.value);
          isPressed.value = false;
        },
        onTap: () {
          showControls.value = !showControls.value;
          hideControlsTimer?.cancel();
          if (showControls.value) {
            hideControlsTimer = Timer(const Duration(milliseconds: 5000),
                () => showControls.value = false);
          }
        },
        onVerticalDragUpdate: (e) async {
          if (!isControlsLocked.value) {
            final delta = e.primaryDelta ?? 0.0;
            final Offset position = e.localPosition;
            if (position.dx <= MediaQuery.of(context).size.width / 2) {
              final brightness = _brightnessValue - delta / 500;
              final result = brightness.clamp(0.0, 1.0);
              setBrightness(result.toDouble());
            } else {
              final volume = _volumeValue - delta / 500;
              final result = volume.clamp(0.0, 1.0);
              setVolume(result.toDouble());
            }
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Obx(
              () => Video(
                fit: getMode(currentMode),
                controller: controller,
                filterQuality: FilterQuality.low,
              ),
            ),
            Positioned.fill(
              child: Obx(
                () => AnimatedOpacity(
                  opacity: showControls.value ? 0.2 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const AzyXContainer(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            buildRippleEffect(),
            Positioned.fill(
                child: Obx(
              () => IgnorePointer(
                ignoring: !showControls.value,
                child: CustomControls(
                  position: position,
                  duration: totalDuration,
                  player: player,
                  showControls: showControls,
                  isPotraitOrientation: isPotraitOrientaion,
                  topBar: topControls(),
                  bottomBar: bottomControls(),
                  changeEpisode: (isNext) {
                    if (anilistAuthController.userData.value.name != null) {
                      anilistAddToListController.updateAnimeProgress(
                          widget.playerData, (episodeNumber.value.toInt()));
                      azyxSnackBar("Tracking Episode $episodeNumber");
                    }
                    final index = filteredEpisodes
                        .indexWhere((i) => i.number == episodeNumber.value);
                    if (isNext && filteredEpisodes.length > index) {
                      log("Next");
                      player.open(Media(""));
                      episodeTitle.value = filteredEpisodes[index + 1].title!;
                      episodeNumber.value = filteredEpisodes[index + 1].number;
                      animeData.value.episodeTitle =
                          filteredEpisodes[index + 1].title!;
                      animeData.value.number =
                          filteredEpisodes[index + 1].number;
                      loadEpisodeurl(filteredEpisodes[index + 1].url!);
                    } else if (index > 0) {
                      log("previous");
                      player.open(Media(""));
                      episodeTitle.value = filteredEpisodes[index - 1].title!;
                      episodeNumber.value = filteredEpisodes[index - 1].number;
                      animeData.value.episodeTitle =
                          filteredEpisodes[index - 1].title!;
                      animeData.value.number =
                          filteredEpisodes[index - 1].number;
                      loadEpisodeurl(filteredEpisodes[index - 1].url!);
                    } else {
                      log("No episode");
                    }
                  },
                  isControlsLocked: () {
                    return isControlsLocked.value;
                  },
                ),
              ),
            )),
            EpisodeListDrawer(
              ontap: (item) {
                if (anilistAuthController.userData.value.name != null) {
                  anilistAddToListController.updateAnimeProgress(
                      widget.playerData, (episodeNumber.value.toInt()));
                  azyxSnackBar("Tracking Episode $episodeNumber");
                }
                player.open(Media(""));
                episodeTitle.value = item.title!;
                episodeNumber.value = item.number;
                animeData.value.title = item.title!;
                animeData.value.number = item.number;
                showEpisodesBox.value = false;
                loadEpisodeurl(item.url!);
              },
              isPotraitOrientaion: isPotraitOrientaion,
              showEpisodesBox: showEpisodesBox,
              animeData: animeData,
              episodeNumber: episodeNumber,
              filteredEpisodes: filteredEpisodes,
            ),
            Positioned.fill(
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
            ),
            Positioned.fill(
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
            ),
            preesedBar()
          ],
        ),
      ),
    );
  }
}
