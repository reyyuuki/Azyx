import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DesktopControls extends StatefulWidget {
  final VideoController controller;
  final Player player;
  final Widget bottomControls;
  final Widget topControls;
  final void Function() hideControlsOnTimeout;
  final bool Function() isControlsLocked;
  final bool isControlsVisible;

  const DesktopControls(
      {super.key,
      required this.controller,
      required this.bottomControls,
      required this.topControls,
      required this.hideControlsOnTimeout,
      required this.isControlsLocked,
      required this.isControlsVisible,
      required this.player});

  @override
  State<DesktopControls> createState() => _ControlsState();
}

class _ControlsState extends State<DesktopControls> {
  IconData? playPause;
  String currentTime = "0:00";
  String maxTime = "0:00";
  int? skipDuration;
  bool alreadySkipped = false;
  int? megaSkipDuration;
  bool buffering = false;
  bool wakelockEnabled = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    wakelockEnabled = true;

    if (mounted) {
      widget.player.streams.position.listen((position) {
        if (mounted) {
          updatePlayerState();
        }
      });
      widget.player.streams.duration.listen((duration) {
        if (mounted) {
          updatePlayerState();
        }
      });
      widget.player.streams.buffering.listen((isBuffering) {
        if (mounted) {
          setState(() {
            buffering = isBuffering;
          });
        }
      });
      widget.player.streams.playing.listen((isPlaying) {
        if (mounted) {
          log(isPlaying.toString());
          setState(() {
            playPause =
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;
            handleWakelock(isPlaying);
          });
        }
      });

      assignSettings();
    }
  }

  void updatePlayerState() {
  if (mounted) {
    setState(() {
      currentTime = getFormattedTime(widget.player.state.position.inSeconds);
      maxTime = getFormattedTime(widget.player.state.duration?.inSeconds ?? 0);
    });
  }
  if (widget.isControlsVisible) {
    widget.hideControlsOnTimeout();
  }
  if (widget.player.state.playing) {
    setState(() {
      playPause = Icons.pause_rounded;
    });
  } else {
    setState(() {
      playPause = Icons.play_arrow_rounded;
    });
  }
}


  void handleWakelock(bool isPlaying) {
    if (isPlaying && !wakelockEnabled) {
      WakelockPlus.enable();
      wakelockEnabled = true;
    } else if (!isPlaying && wakelockEnabled) {
      WakelockPlus.disable();
      wakelockEnabled = false;
    }
  }

  Future<void> assignSettings() async {
    setState(() {
      skipDuration = 10;
      megaSkipDuration = 85;
    });
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

  void fastForward(int seekDuration) {
    final newPosition =
        widget.player.state.position + Duration(seconds: seekDuration);
    final duration = widget.player.state.duration;
    if (newPosition < Duration.zero) {
      widget.player.seek(Duration.zero);
    } else if (newPosition > duration) {
      widget.player.seek(duration - const Duration(milliseconds: 500));
    } else {
      widget.player.seek(newPosition);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Duration currentPosition =
        widget.controller.player.state.position ?? Duration.zero;
    final Duration totalDuration =
        widget.controller.player.state.duration ?? Duration.zero;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.topControls,
            Expanded(
              child: widget.isControlsLocked()
                  ? lockedCenterControls()
                  : Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: centerControls(context),
                  ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(currentTime),
                        const Text(" / "),
                        Text(maxTime),
                      ],
                    ),
                    if (megaSkipDuration != null &&
                        !widget.isControlsLocked() &&
                        !alreadySkipped)
                      megaSkipButton(),
                  ],
                ),
                Slider(
                  value: currentPosition.inMilliseconds.toDouble(),
                  max: totalDuration.inMilliseconds.toDouble(),
                  min: 0.0,
                  onChanged: (value) {
                    widget.controller.player
                        .seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                widget.bottomControls,
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton megaSkipButton() {
    return ElevatedButton(
      onPressed: () {
        fastForward(megaSkipDuration!);
        alreadySkipped = true;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              "+$megaSkipDuration",
              style: const TextStyle(fontSize: 17),
            ),
          ),
          const Icon(Icons.fast_forward_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Container lockedCenterControls() {
    return Container(
      alignment: Alignment.center,
      child: buffering
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
    );
  }

  Row centerControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildControlButton(
          icon: Icons.fast_rewind_rounded,
          onTap: () {
            fastForward(skipDuration != null ? -skipDuration! : -10);
          },
        ),
        buildControlButton(
          icon: playPause ?? Icons.play_arrow_rounded,
          size: 45,
          onTap: () {
            widget.player.playOrPause();
          },
        ),
        buildControlButton(
          icon: Icons.fast_forward_rounded,
          onTap: () {
            fastForward(skipDuration ?? 10);
          },
        ),
      ],
    );
  }

  Widget buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 40,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 65,
          width: 65,
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ),
    );
  }
}

class EdgeToEdgeTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackWidth = parentBox.size.width;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(offset.dx, trackTop, trackWidth, trackHeight);
  }
}