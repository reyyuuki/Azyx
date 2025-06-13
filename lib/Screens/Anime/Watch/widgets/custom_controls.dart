import 'dart:async';

import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

class CustomControls extends StatefulWidget {
  final Player player;
  final Widget topBar;
  final Widget bottomBar;
  final bool Function() isControlsLocked;
  final void Function(bool isNext) changeEpisode;
  final Rx<bool> showControls;
  final Rx<Duration> position;
  final Rx<bool> isPotraitOrientation;
  final Rx<Duration> duration;
  const CustomControls(
      {super.key,
      required this.player,
      required this.topBar,
      required this.bottomBar,
      required this.showControls,
      required this.position,
      required this.duration,
      required this.isPotraitOrientation,
      required this.changeEpisode,
      required this.isControlsLocked});

  @override
  State<CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  final Rx<bool> isPlaying = false.obs;
  final Rx<bool> isBuffering = false.obs;
  final Rx<Duration> buffered = Duration.zero.obs;

  @override
  void initState() {
    super.initState();
    listners();
  }

  Timer? _positionUpdateTimer;
  Duration _lastPosition = Duration.zero;

  void listners() {
    if (mounted) {
      widget.player.stream.playing.listen((p) {
        isPlaying.value = p;
      });

      widget.player.stream.buffering.listen((b) {
        isBuffering.value = b;
      });

      widget.player.stream.buffer.listen((d) {
        buffered.value = d;
      });

      widget.player.stream.position.listen((p) {
        if ((p - _lastPosition).abs().inSeconds >= 1) {
          _lastPosition = p;

          _positionUpdateTimer?.cancel();

          _positionUpdateTimer = Timer(const Duration(milliseconds: 100), () {
            if (mounted) {
              widget.position.value = p;
            }
          });
        }
      });

      widget.player.stream.duration.listen((d) {
        widget.duration.value = d;
      });
    }
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    super.dispose();
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

  Row centerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildIconButton(
            ontap: () {
              widget.changeEpisode(false);
            },
            icon: Broken.previous),
        Obx(() => isBuffering.value
            ? const CircularProgressIndicator()
            : GestureDetector(
                onTap: () => widget.player.playOrPause(),
                child: AzyXContainer(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.primary.withAlpha(80),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(1.glowMultiplier()),
                            blurRadius: 10.blurMultiplier(),
                            spreadRadius: 3.spreadMultiplier())
                      ],
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: isPlaying.value ? 60 : 60,
                    shadows: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          blurRadius: 10.blurMultiplier(),
                          spreadRadius: 2.spreadMultiplier())
                    ],
                  ),
                ))),
        buildIconButton(
            ontap: () {
              widget.changeEpisode(true);
            },
            icon: Broken.next)
      ],
    );
  }

  AzyXContainer lockedCenterControls() {
    return AzyXContainer(
      alignment: Alignment.center,
      child: isBuffering.value
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
    );
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: widget.isPotraitOrientation.value ? 20 : 12,
          horizontal: widget.isPotraitOrientation.value ? 20 : 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => widget.isControlsLocked()
              ? const SizedBox.shrink()
              : AnimatedContainer(
                  height: widget.isPotraitOrientation.value ? 150 : 101,
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(
                      0, widget.showControls.value ? 0 : -Get.height, 0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: widget.topBar)),
          Obx(
            () => Expanded(
                child: AnimatedOpacity(
              opacity: widget.showControls.value ? 1 : 0,
              duration: const Duration(milliseconds: 1000),
              child: widget.isControlsLocked()
                  ? lockedCenterControls()
                  : centerControls(),
            )),
          ),
          AnimatedContainer(
            height: widget.isPotraitOrientation.value ? 150 : 101,
            transform: Matrix4.translationValues(
                0, widget.showControls.value ? 0 : Get.height, 0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubicEmphasized,
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() => AzyXText(
                          text:
                              getFormattedTime(widget.position.value.inSeconds),
                          fontVariant: FontVariant.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    const AzyXText(
                      text: ' / ',
                      fontVariant: FontVariant.bold,
                    ),
                    Obx(() => AzyXText(
                          text:
                              getFormattedTime(widget.duration.value.inSeconds),
                          fontVariant: FontVariant.bold,
                        ))
                  ],
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomSlider(
                        min: 0.0,
                        max: widget.duration.value.inSeconds > 0
                            ? widget.duration.value.inSeconds.toDouble()
                            : 0.0,
                        secondaryTrackValue: widget.duration.value.inSeconds > 0
                            ? buffered.value.inSeconds.toDouble()
                            : 0.0,
                        indiactorTime:
                            getFormattedTime(widget.position.value.inSeconds),
                        value: widget.duration.value.inSeconds > 0.0
                            ? double.parse(widget.position.value.inSeconds
                                .toStringAsFixed(2))
                            : 0.0,
                        onDragEnd: (value) {
                          widget.player.seek(Duration(seconds: value.toInt()));
                          widget.player.play();
                        },
                        isLocked: widget.isControlsLocked(),
                        onChanged: (value) {
                          widget.position.value =
                              Duration(seconds: value.toInt());
                        }),
                  ),
                ),
                widget.bottomBar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
