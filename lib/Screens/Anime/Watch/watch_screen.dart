import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/controller/watch_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

class WatchScreen extends StatefulWidget {
  final AnimeAllData playerData;
  const WatchScreen({super.key, required this.playerData});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  late WatchController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WatchController());
    controller.initializePlayer(widget.playerData);
  }

  @override
  void dispose() {
    Get.delete<WatchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTapDown: (t) {
          controller.isControlsLocked.value
              ? null
              : controller.doubleTap(t, context);
        },
        onLongPressStart: (d) async {
          controller.isPressed.value = true;
          controller.player.setRate(2.0);
        },
        onLongPressEnd: (d) {
          controller.player.setRate(controller.selectedSpeed.value);
          controller.isPressed.value = false;
        },
        onTap: () {
          controller.handleControlsTap();
        },
        onVerticalDragUpdate: (e) async {
          controller.handleVerticalDrag(e, context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Obx(
              () => Video(
                fit: controller.getMode(controller.currentMode),
                controller: controller.controller,
                filterQuality: FilterQuality.low,
              ),
            ),
            Positioned.fill(
              child: Obx(
                () => AnimatedOpacity(
                  opacity: controller.showControls.value ? 0.2 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const AzyXContainer(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            controller.buildRippleEffect(context),
            Positioned.fill(
                child: Obx(
              () => IgnorePointer(
                ignoring: !controller.showControls.value,
                child: controller.customControls(context),
              ),
            )),
            controller.episodeListDrawer(),
            controller.volumeIndicator(),
            controller.brightnessIndicator(),
            controller.preesedBar()
          ],
        ),
      ),
    );
  }
}
