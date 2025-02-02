import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
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
  final UiSettingController settingController;
  const CustomControls(
      {super.key,
      required this.player,
      required this.topBar,
      required this.bottomBar,
      required this.showControls,
      required this.position,
      required this.duration,
      required this.isPotraitOrientation,
      required this.settingController,
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
        widget.position.value = p;
      });
      widget.player.stream.duration.listen((d) {
        widget.duration.value = d;
      });
    }
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
            icon: Broken.backward),
        Obx(() => isBuffering.value
            ? const CircularProgressIndicator()
            : GestureDetector(
                onTap: () => widget.player.playOrPause(),
                child: AzyXContainer(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(
                                    widget.settingController.glowMultiplier),
                            blurRadius:
                                10 * widget.settingController.blurMultiplier,
                            spreadRadius:
                                3 * widget.settingController.spreadMultiplier)
                      ],
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    isPlaying.value ? Icons.pause : Ionicons.play,
                    color: Colors.black,
                    size: isPlaying.value ? 50 : 45,
                    shadows: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5)
                    ],
                  ),
                ))),
        buildIconButton(
            ontap: () {
              widget.changeEpisode(true);
            },
            icon: Broken.forward)
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
                  height: widget.isPotraitOrientation.value ? 150 : 100,
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(
                      0, widget.showControls.value ? 0 : -Get.height, 0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: widget.topBar)),
          Obx(
            () => Expanded(
                child: AnimatedContainer(
              transform: Matrix4.translationValues(
                  widget.showControls.value ? 0 : -Get.width, 0, 0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubicEmphasized,
              child: widget.isControlsLocked()
                  ? lockedCenterControls()
                  : centerControls(),
            )),
          ),
          AnimatedContainer(
            height: widget.isPotraitOrientation.value ? 150 : 100,
            transform: Matrix4.translationValues(
                0, widget.showControls.value ? 0 : Get.height, 0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubicEmphasized,
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() => AzyXText(
                          getFormattedTime(widget.position.value.inSeconds),
                          style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              color: Theme.of(context).colorScheme.primary),
                        )),
                    const AzyXText(
                      ' / ',
                      style: TextStyle(fontFamily: "Poppins-Bold"),
                    ),
                    Obx(() => AzyXText(
                          getFormattedTime(widget.duration.value.inSeconds),
                          style: const TextStyle(fontFamily: "Poppins-Bold"),
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
                        secondaryTrackValue: buffered.value.inSeconds > 0.0
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
                          widget.player.pause();
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
