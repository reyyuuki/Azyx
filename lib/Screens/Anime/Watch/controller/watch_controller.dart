import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as max;
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/local_history.dart';
import 'package:azyx/Constants/constants.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/bottom_sheets.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/episode_list_drawer.dart';
import 'package:azyx/Screens/Anime/Watch/widgets/indicator.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/color_profiler.dart';
import 'package:azyx/utils/utils.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/DEpisode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

enum ResizeModes {
  contain,
  cover,
  fill,
}

class WatchController extends GetxController with WidgetsBindingObserver {
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
  final Rx<Duration> buffered = Duration.zero.obs;
  final Rx<double> selectedSpeed = 1.0.obs;
  final Rx<ResizeModes> currentMode = ResizeModes.contain.obs;
  final Rx<bool> isSeeking = false.obs;
  final Rx<bool> _volumeInterceptEventStream = false.obs;
  final Rx<double> _volumeValue = 0.0.obs;
  final Rx<double> _brightnessValue = 0.0.obs;
  final Rx<bool> isPotraitOrientaion = false.obs;
  final Rx<String> selectedSbt = ''.obs;
  final Rx<LocalHistory> localHistoryData = LocalHistory().obs;
  final Rx<bool> isPlaying = false.obs;
  final Rx<bool> isBuffering = false.obs;
  final Rx<int> doubleTapLable = 0.obs;
  final Rx<int> skipDuration = 0.obs;
  final Rx<bool> isLeftSide = false.obs;
  final Rx<bool> _volumeIndicator = false.obs;
  final Rx<bool> _brightnessIndicator = false.obs;
  final Rx<bool> isPressed = false.obs;
  final currentVisualProfile = 'natural'.obs;

  Timer? updateTimer;
  Timer? doubleTapTimer;
  Timer? hideControlsTimer;
  Timer? _volumeTimer;
  Timer? _brightnessTimer;
  Timer? _positionUpdateTimer;
  Duration _lastPosition = Duration.zero;

  void initializePlayer(AnimeAllData playerData) {
    WidgetsBinding.instance.addObserver(this);
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

    intializeData(playerData);

    for (var element in playerData.episodeUrls) {
      log("Headers: ${element.headers} / ${sourceController.activeSource.value!.baseUrl!}");
    }

    player.open(
      Media(
        playerData.url!,
        httpHeaders: {
          'Referer': playerData.episodeUrls.first.headers?['Referer'] ??
              sourceController.activeSource.value!.baseUrl!,
          'Origin': playerData.episodeUrls.first.headers?['Origin'] ??
              sourceController.activeSource.value!.baseUrl!,
          'User-Agent': playerData.episodeUrls.first.headers?['user-agent'] ??
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        },
      ),
    );

    _handleVolumeAndBrightness();
    _setupPlayerListeners();
    updateTimer = Timer.periodic(
        const Duration(minutes: 1), (timer) => localHistoryEntry());
  }

  void _setupPlayerListeners() {
    player.stream.playing.listen((p) {
      isPlaying.value = p;
    });

    player.stream.buffering.listen((b) {
      isBuffering.value = b;
    });

    player.stream.buffer.listen((d) {
      buffered.value = d;
    });

    player.stream.position.listen((p) {
      if ((p - _lastPosition).abs().inSeconds >= 1) {
        _lastPosition = p;
        _positionUpdateTimer?.cancel();
        _positionUpdateTimer = Timer(const Duration(milliseconds: 100), () {
          position.value = p;
        });
      }
    });

    player.stream.duration.listen((d) {
      totalDuration.value = d;
    });
  }

  void localHistoryEntry() {}

  void updateEntry() async {
    await serviceHandler.updateListEntry(anilistAddToListController.anime.value,
        isAnime: true);
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
    episodeNumber.value = playerData.number!;
    episodeTitle.value = playerData.episodeTitle!;
    filteredEpisodes.value = playerData.episodeList!;
    localHistoryEntry();
  }

  void changeResizeMode() {
    currentMode.value = ResizeModes.values[
        (ResizeModes.values.indexOf(currentMode.value) + 1) %
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
      final response = await sourceController.activeSource.value!.methods
          .getVideoList(DEpisode(episodeNumber: episodeNumber.value, url: url));
      if (response.isNotEmpty) {
        final quality = animeData.value.episodeUrls.firstWhere(
            (i) => i.url == animeData.value.url,
            orElse: () => animeData.value.episodeUrls.first);
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

  void applySavedProfile() => ColorProfileManager()
      .applyColorProfile(currentVisualProfile.value, player);

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
        },
        onCustomSettingsChanged: (settings) {
          Utils.log('Custom settings applied: $settings');
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
          const Duration(milliseconds: 5000), () => showControls.value = false);
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
    if (anilistAuthController.userData.value.name != null) {
      anilistAddToListController.updateAnimeProgress(
          animeData.value, (episodeNumber.value.toInt()));
      azyxSnackBar("Tracking Episode $episodeNumber");
    }
    final index =
        filteredEpisodes.indexWhere((i) => i.number == episodeNumber.value);
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
    if (anilistAuthController.userData.value.name != null) {
      anilistAddToListController.updateAnimeProgress(
          animeData.value, (episodeNumber.value.toInt()));
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

  Widget backButton(BuildContext context) {
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

  Widget topRightControls(BuildContext context) {
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

  Widget episodeTitleWidget(BuildContext context) {
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
              text: animeData.value.title!,
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

  Widget topControls(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        backButton(context),
        const SizedBox(width: 10),
        episodeTitleWidget(context),
        topRightControls(context),
      ],
    );
  }

  Widget bottomRightControls() {
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

  Widget seek10Widget() {
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

  Widget speedButton(BuildContext context) {
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

  Widget seek85(bool isLeft) {
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

  Widget bottomPotraitControls(BuildContext context) {
    return Column(
      children: [
        isControlsLocked.value
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [seek85(true), speedButton(context), seek85(false)],
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

  Widget bottomLeftControls(BuildContext context) {
    return isControlsLocked.value
        ? const SizedBox.shrink()
        : Row(
            children: [
              seek85(true),
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

  Widget buildIconButton(
      {required VoidCallback ontap, required IconData icon}) {
    return InkWell(
        onTap: ontap,
        child: AzyXContainer(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border:
                  Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            icon,
            color: Colors.white,
            size: 35,
          ),
        ));
  }

  Widget centerControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildIconButton(
            ontap: () {
              changeEpisode(false);
            },
            icon: Broken.previous),
        20.width,
        Obx(() => isBuffering.value
            ? const CircularProgressIndicator()
            : GestureDetector(
                onTap: () => player.playOrPause(),
                child: Icon(
                  isPlaying.value
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                ))),
        20.width,
        buildIconButton(
            ontap: () {
              changeEpisode(true);
            },
            icon: Broken.next)
      ],
    );
  }

  Widget lockedCenterControls() {
    return AzyXContainer(
      alignment: Alignment.center,
      child: isBuffering.value
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
    );
  }

  Widget customControls(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: isPotraitOrientaion.value ? 20 : 12,
          horizontal: isPotraitOrientaion.value ? 20 : 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => isControlsLocked.value
              ? const SizedBox.shrink()
              : AnimatedContainer(
                  height: isPotraitOrientaion.value ? 150 : 101,
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(
                      0, showControls.value ? 0 : -Get.height, 0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: topControls(context))),
          Obx(
            () => Expanded(
                child: AnimatedOpacity(
              opacity: showControls.value ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: isControlsLocked.value
                  ? lockedCenterControls()
                  : centerControls(context),
            )),
          ),
          AnimatedContainer(
            height: isPotraitOrientaion.value ? 150 : 101,
            transform: Matrix4.translationValues(
                0, showControls.value ? 0 : Get.height, 0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubicEmphasized,
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() => AzyXText(
                          text: getFormattedTime(position.value.inSeconds),
                          fontVariant: FontVariant.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    const AzyXText(
                      text: ' / ',
                      fontVariant: FontVariant.bold,
                    ),
                    Obx(() => AzyXText(
                          text: getFormattedTime(totalDuration.value.inSeconds),
                          fontVariant: FontVariant.bold,
                        ))
                  ],
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomSlider(
                        min: 0.0,
                        max: totalDuration.value.inSeconds > 0
                            ? totalDuration.value.inSeconds.toDouble()
                            : 0.0,
                        secondaryTrackValue: totalDuration.value.inSeconds > 0
                            ? buffered.value.inSeconds.toDouble()
                            : 0.0,
                        indiactorTime:
                            getFormattedTime(position.value.inSeconds),
                        value: totalDuration.value.inSeconds > 0.0
                            ? double.parse(
                                position.value.inSeconds.toStringAsFixed(2))
                            : 0.0,
                        onDragEnd: (value) {
                          player.seek(Duration(seconds: value.toInt()));
                          player.play();
                        },
                        isLocked: isControlsLocked.value,
                        onChanged: (value) {
                          position.value = Duration(seconds: value.toInt());
                        }),
                  ),
                ),
                bottomControls(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRippleEffect(BuildContext context) {
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
                  const SizedBox(width: 10),
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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    player.dispose();
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
