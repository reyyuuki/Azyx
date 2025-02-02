import 'dart:async';

import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/components/Anime/indicator.dart';
import 'package:azyx/components/Desktop/anime/desktop_controls.dart';
import 'dart:developer' as r;
import 'dart:math';
import 'package:azyx/Hive_Data/appDatabase.dart';
import 'package:azyx/Provider/sources_provider.dart';
import 'package:azyx/api/Mangayomi/Search/getVideo.dart';
import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/utils/sources/Anime/SourceHandler/sourcehandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as v;
import 'package:provider/provider.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/video.dart' as videoModel;
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class WatchPage extends StatefulWidget {
  final dynamic episodeData;
  final String episodeTitle;
  final int currentEpisode;
  final String episodeSrc;
  final dynamic subtitleTracks;
  final String animeTitle;
  final int animeId;
  final Source source;
  final List<videoModel.Video> episodeUrls;
  const WatchPage({
    super.key,
    required this.episodeSrc,
    required this.episodeData,
    required this.currentEpisode,
    required this.episodeTitle,
    required this.subtitleTracks,
    required this.animeTitle,
    required this.animeId,
    required this.source,
    required this.episodeUrls,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> with TickerProviderStateMixin {
  late Player player;
  v.VideoController? controller;
  bool showControls = true;
  bool showSubs = true;
  bool isLandScapeRight = false;
  bool isControlsLocked = false;
  String? episodeSrc;
  dynamic tracks;
  String? episodeTitle;
  int? currentEpisode;
  late AnimeSourcehandler sourcehandler;
  late AnimationController _leftAnimationController;
  late AnimationController _rightAnimationController;
  List<BoxFit> resizeModes = [
    BoxFit.contain,
    BoxFit.fill,
    BoxFit.cover,
  ];
  int index = 0;
  double currentSpeed = 1.0;
  var _volumeInterceptEventStream = false;
  double _volumeValue = 0.0;
  double _brightnessValue = 0.0;
  late List<videoModel.Video> episodeUrls;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    episodeUrls = widget.episodeUrls;
    player = Player();
    controller = v.VideoController(player);
    player.open(Media(widget.episodeSrc));
    _initVars();
    if (mounted) {
      Provider.of<Data>(context, listen: false).addWatchedAnimes(
          animeId: widget.animeId.toString(),
          animeTitle: widget.animeTitle,
          currentEpisode: currentEpisode!,
          episodeTitle: widget.episodeTitle,
          episodesrc: episodeSrc!,
          tracks: tracks);
      sourcehandler = Provider.of<SourcesProvider>(context, listen: false)
          .getAnimeInstace();
      final anilist = Provider.of<AniListProvider>(context, listen: false);
      anilist.userData?['name'] != null
          ? anilist.addToAniList(
              mediaId: widget.animeId, progress: widget.currentEpisode)
          : [];
    }
    _leftAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _rightAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _handleVolumeAndBrightness();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
    player.dispose();
    _leftAnimationController.dispose();
    _rightAnimationController.dispose();
  }

  void _updateSpeed(double speed) {
    setState(() {
      currentSpeed = speed;
    });
    player.setRate(currentSpeed);
  }

  void changeResizeMode(int index) {
    setState(() {
      index = (index + 1) % resizeModes.length;
    });
  }

  void _initVars() {
    setState(() {
      episodeSrc = widget.episodeSrc;
      tracks = widget.subtitleTracks;
      episodeTitle = widget.episodeTitle;
      currentEpisode = widget.currentEpisode;
    });
  }

  Future<void> _handleVolumeAndBrightness() async {
    VolumeController().showSystemUI = false;
    _volumeValue = await VolumeController().getVolume();
    VolumeController().listener((value) {
      if (mounted && !_volumeInterceptEventStream) {
        _volumeValue = value;
      }
    });

    _brightnessValue = await ScreenBrightness().current;
    ScreenBrightness().onCurrentBrightnessChanged.listen((value) {
      if (mounted) {
        _brightnessValue = value;
      }
    });
  }

  Future<void> fetchSrcHelper(String url) async {
    episodeSrc = null;
    player.open(Media(""));
    try {
      final response = await getVideo(source: widget.source, url: url);
      if (response.isNotEmpty) {
        final index = widget.episodeData.indexWhere((i) => i['url'] == url);
        setState(() {
          tracks = response.first.subtitles ?? [];
          episodeSrc = response.first.url;
          currentEpisode = index;
          episodeUrls = response.toList();
        });
        player.open(Media(episodeSrc!));

        Provider.of<Data>(context, listen: false).addWatchedAnimes(
            animeId: widget.animeId.toString(),
            animeTitle: widget.animeTitle,
            currentEpisode: currentEpisode!,
            episodeTitle: episodeTitle!,
            episodesrc: episodeSrc!,
            tracks: tracks);
        final anilist = Provider.of<AniListProvider>(context, listen: false);
        anilist.userData?['name'] != null
            ? anilist.addToAniList(
                mediaId: widget.animeId, progress: widget.currentEpisode)
            : [];
      } else {
        r.log("not complete");
      }
    } catch (e) {
      r.log('Error fetching episode sources: $e');
    }
  }

  Row topControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "Episode $currentEpisode: $episodeTitle",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.animeTitle,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 190, 190, 190),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            episodesDialog();
          },
          icon: const Icon(
            Icons.video_collection,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              isControlsLocked = !isControlsLocked;
            });
          },
          icon: Icon(
            isControlsLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Row bottomControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                qualityDialog();
              },
              icon: const Icon(
                Icons.high_quality_rounded,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                subtitleDialog();
              },
              icon: const Icon(
                Iconsax.subtitle5,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                showPlaybackSpeedDialog(context, _updateSpeed);
              },
              icon: const Icon(
                Icons.speed_rounded,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                index++;
                if (index > 2) {
                  index = 0;
                  changeResizeMode(index);
                } else {
                  changeResizeMode(index);
                }
              },
              icon: const Icon(
                Icons.fullscreen_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showPlaybackSpeedDialog(
      BuildContext context, Function(double) onSpeedChange) {
    Player playerController = Player();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Playback Speed'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSpeedOption(context, playerController, 0.5, currentSpeed,
                    onSpeedChange),
                _buildSpeedOption(context, playerController, 0.75, currentSpeed,
                    onSpeedChange),
                _buildSpeedOption(context, playerController, 1.0, currentSpeed,
                    onSpeedChange),
                _buildSpeedOption(context, playerController, 1.25, currentSpeed,
                    onSpeedChange),
                _buildSpeedOption(context, playerController, 1.5, currentSpeed,
                    onSpeedChange),
                _buildSpeedOption(context, playerController, 2.0, currentSpeed,
                    onSpeedChange),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedOption(BuildContext context, Player playerController,
      double speed, double currentSpeed, Function(double) onSpeedChange) {
    return RadioListTile<double>(
      value: speed,
      groupValue: currentSpeed,
      onChanged: (value) {
        if (value != null) {
          playerController.setRate(speed);
          onSpeedChange(speed);
          r.log(currentSpeed.toString());
          Navigator.of(context).pop();
        }
      },
      title: Text('${speed}x'),
    );
  }

  void episodesDialog() {
    ScrollController scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentEpisode != null &&
          currentEpisode! > 0 &&
          widget.episodeData.isNotEmpty) {
        final episodeIndex = widget.episodeData
            .indexWhere((episode) => episode['name'] == episodeTitle);
        if (episodeIndex != -1) {
          double positionToScroll = (episodeIndex) * 77.0;
          scrollController.jumpTo(positionToScroll);
        }
      }
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Episodes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.episodeData.length,
                  itemBuilder: (context, index) {
                    final episode = widget.episodeData[index];
                    final isSelected = episode['name'] == episodeTitle;
                    return Container(
                      height: 65,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        onPressed: () async {
                          setState(() {
                            episodeTitle = episode['name'];
                          });
                          Navigator.pop(context);
                          await fetchSrcHelper(episode['url']!);
                        },
                        child: Text(
                          'Episode ${index + 1}: ${episode['name']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  qualityDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      builder: (context) {
        return Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Video Quality",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: episodeUrls.length,
                  itemBuilder: (context, index) {
                    final item = episodeUrls[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: episodeSrc == item.url
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        onPressed: () {
                          episodeSrc = item.url;
                          player.open(
                              Media(item.url, start: player.state.position));
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          item.quality,
                          style: TextStyle(
                              fontSize: 16,
                              color: episodeSrc == item.url
                                  ? Colors.black
                                  : Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

int selectedSub = -1;

  void subtitleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 400,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Subtitles",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      itemCount: episodeUrls.first.subtitles!.length +
                          1, // +1 for "None" option
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: selectedSub == -1
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                minimumSize: const Size(double.infinity, 0),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedSub = -1;
                                  player.setSubtitleTrack(const SubtitleTrack(
                                      '', '', '')); // Disable subtitles
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                "None",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedSub == -1
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        }

                        final item = episodeUrls
                            .first.subtitles![index - 1]; // Adjust index
                        final isSelected = selectedSub == index - 1;
                        final subtitleLabel = item.label ?? "Unknown";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedSub = index - 1;
                                
                                player.setSubtitleTrack(
                                  SubtitleTrack.uri(item.file!),
                                );
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              subtitleLabel,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  AnimatedOpacity overlay() {
    return AnimatedOpacity(
      opacity: !showControls ? 0.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
      ),
    );
  }

  bool _volumeIndicator = false;
  bool _brightnessIndicator = false;
  Timer? _volumeTimer;
  Timer? _brightnessTimer;

  Future<void> setVolume(double value) async {
    try {
      VolumeController().setVolume(value);
    } catch (_) {}
    _volumeValue = value;
    _volumeIndicator = true;
    _volumeInterceptEventStream = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _volumeIndicator = false;
        _volumeInterceptEventStream = false;
      }
    });
  }

  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
    } catch (_) {}
    _brightnessIndicator = true;
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _brightnessIndicator = false;
      }
    });
  }

  int doubleTapLabel = 0;
  Timer? doubleTapTimeout;
  bool isLeftSide = false;
  int skipDuration = 0;

  void _handleDoubleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition;
    final isLeft = tapPosition.dx < screenWidth / 2;
    _skipSegments(isLeft);
  }

  void _skipSegments(bool isLeft) {
    if (isLeftSide != isLeft) {
      doubleTapLabel = 0;
      skipDuration = 0;
    }
    isLeftSide = isLeft;
    doubleTapLabel += 10;
    skipDuration += 10;
    isLeft
        ? _leftAnimationController.forward(from: 0)
        : _rightAnimationController.forward(from: 0);

    doubleTapTimeout?.cancel();

    doubleTapTimeout = Timer(const Duration(milliseconds: 1000), () {
      final currentPosition = player.state.position;
      if (currentPosition == const Duration(seconds: 0)) return;
      if (isLeft) {
        player.seek(
          Duration(
            seconds: max(0, currentPosition.inSeconds - skipDuration),
          ),
        );
      } else {
        player.seek(
          Duration(
            seconds: currentPosition.inSeconds + skipDuration,
          ),
        );
      }
      _leftAnimationController.stop();
      _rightAnimationController.stop();
      doubleTapLabel = 0;
      skipDuration = 0;
    });
  }

  Widget _buildRippleEffect() {
    if (doubleTapLabel == 0) {
      return const SizedBox();
    }
    return AnimatedPositioned(
      left: isLeftSide ? 0 : MediaQuery.of(context).size.width / 1.5,
      width: MediaQuery.of(context).size.width / 2.5,
      top: 0,
      bottom: 0,
      duration: const Duration(milliseconds: 1000),
      child: AnimatedBuilder(
        animation:
            isLeftSide ? _leftAnimationController : _rightAnimationController,
        builder: (context, child) {
          final scale = Tween<double>(begin: 1.5, end: 1).animate(
            CurvedAnimation(
              parent: isLeftSide
                  ? _leftAnimationController
                  : _rightAnimationController,
              curve: Curves.bounceInOut,
            ),
          );

          return GestureDetector(
            onDoubleTapDown: (t) => _handleDoubleTap(t),
            child: Opacity(
              opacity: 1.0 -
                  (isLeftSide
                      ? _leftAnimationController.value
                      : _rightAnimationController.value),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isLeftSide ? 0 : 500),
                    topRight: Radius.circular(isLeftSide ? 500 : 0),
                    bottomLeft: Radius.circular(isLeftSide ? 0 : 500),
                    bottomRight: Radius.circular(isLeftSide ? 500 : 0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: scale,
                      child: Icon(
                        isLeftSide
                            ? Icons.fast_rewind_rounded
                            : Icons.fast_forward_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        "${doubleTapLabel}s",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          });
        },
        onDoubleTapDown: (t) => _handleDoubleTap(t),
        onVerticalDragUpdate: (e) async {
          r.log("Start scrolling");
          final delta = e.primaryDelta ?? 0.0;
          final Offset position = e.localPosition;
          r.log("Scrolling: $position");
          setState(() {
            if (position.dx <= MediaQuery.of(context).size.width / 2) {
              final brightness = _brightnessValue - delta / 500;
              final result = brightness.clamp(0.0, 1.0);
              setBrightness(result);
            } else {
              final volume = _volumeValue - delta / 500;
              final result = volume.clamp(0.0, 1.0);
              setVolume(result);
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            v.Video(
              controller: controller!,
              fit: resizeModes[index],
              subtitleViewConfiguration:  v.SubtitleViewConfiguration(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                  height: 2,
                  fontFamily: "Poppins-Bold",
                  backgroundColor: Colors.black.withOpacity(0.5)
                )
              ),
            ),
            Positioned.fill(child: overlay()),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !showControls,
                child: AnimatedOpacity(
                  opacity: showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: DesktopControls(
                    player: player,
                    bottomControls: bottomControls(),
                    topControls: topControls(),
                    hideControlsOnTimeout: () {},
                    isControlsLocked: () {
                      return isControlsLocked;
                    },
                    isControlsVisible: showControls,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              curve: Curves.easeInOut,
              opacity: _volumeIndicator ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: MediaIndicatorBuilder(
                value: _volumeValue,
                isVolumeIndicator: true,
              ),
            ),
            AnimatedOpacity(
              curve: Curves.easeInOut,
              opacity: _brightnessIndicator ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: MediaIndicatorBuilder(
                value: _brightnessValue,
                isVolumeIndicator: false,
              ),
            ),
            _buildRippleEffect(),
          ],
        ),
      ),
    );
  }
}
