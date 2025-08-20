import 'package:azyx/Screens/Anime/Watch/controller/watch_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

class CustomControls extends StatelessWidget {
  final Player player;
  final Widget topBar;
  final Widget bottomBar;
  final bool Function() isControlsLocked;
  final void Function(bool isNext) changeEpisode;

  const CustomControls({
    super.key,
    required this.player,
    required this.topBar,
    required this.bottomBar,
    required this.changeEpisode,
    required this.isControlsLocked,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WatchController>();

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: controller.isPotraitOrientaion.value ? 20 : 12,
          horizontal: controller.isPotraitOrientaion.value ? 20 : 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => controller.isControlsLocked.value
              ? const SizedBox.shrink()
              : AnimatedContainer(
                  height: controller.isPotraitOrientaion.value ? 150 : 101,
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(
                      0, controller.showControls.value ? 0 : -Get.height, 0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: topBar)),
          Obx(
            () => Expanded(
                child: AnimatedOpacity(
              opacity: controller.showControls.value ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: controller.isControlsLocked.value
                  ? _lockedCenterControls(controller)
                  : _centerControls(controller, context),
            )),
          ),
          AnimatedContainer(
            height: controller.isPotraitOrientaion.value ? 150 : 101,
            transform: Matrix4.translationValues(
                0, controller.showControls.value ? 0 : Get.height, 0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubicEmphasized,
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() => AzyXText(
                          text: controller.getFormattedTime(
                              controller.position.value.inSeconds),
                          fontVariant: FontVariant.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    const AzyXText(
                      text: ' / ',
                      fontVariant: FontVariant.bold,
                    ),
                    Obx(() => AzyXText(
                          text: controller.getFormattedTime(
                              controller.totalDuration.value.inSeconds),
                          fontVariant: FontVariant.bold,
                        ))
                  ],
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomSlider(
                        min: 0.0,
                        max: controller.totalDuration.value.inSeconds > 0
                            ? controller.totalDuration.value.inSeconds
                                .toDouble()
                            : 0.0,
                        secondaryTrackValue:
                            controller.totalDuration.value.inSeconds > 0
                                ? controller.buffered.value.inSeconds.toDouble()
                                : 0.0,
                        indiactorTime: controller.getFormattedTime(
                            controller.position.value.inSeconds),
                        value: controller.totalDuration.value.inSeconds > 0.0
                            ? double.parse(controller.position.value.inSeconds
                                .toStringAsFixed(2))
                            : 0.0,
                        onDragEnd: (value) {
                          controller.player
                              .seek(Duration(seconds: value.toInt()));
                          controller.player.play();
                        },
                        isLocked: controller.isControlsLocked.value,
                        onChanged: (value) {
                          controller.position.value =
                              Duration(seconds: value.toInt());
                        }),
                  ),
                ),
                bottomBar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
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

  Widget _centerControls(WatchController controller, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconButton(
            ontap: () {
              changeEpisode(false);
            },
            icon: Broken.previous),
        20.width,
        Obx(() => controller.isBuffering.value
            ? const CircularProgressIndicator()
            : GestureDetector(
                onTap: () => controller.player.playOrPause(),
                child: Icon(
                  controller.isPlaying.value
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                ))),
        20.width,
        _buildIconButton(
            ontap: () {
              changeEpisode(true);
            },
            icon: Broken.next)
      ],
    );
  }

  Widget _lockedCenterControls(WatchController controller) {
    return AzyXContainer(
      alignment: Alignment.center,
      child: controller.isBuffering.value
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
    );
  }
}
