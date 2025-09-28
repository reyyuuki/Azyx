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
  @override
  void initState() {
    super.initState();
    watchController.initializePlayer(widget.playerData);
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
          watchController.isControlsLocked.value
              ? null
              : watchController.doubleTap(t, context);
        },
        onLongPressStart: (d) async {
          watchController.isPressed.value = true;
          watchController.player.setRate(2.0);
        },
        onLongPressEnd: (d) {
          watchController.player.setRate(watchController.selectedSpeed.value);
          watchController.isPressed.value = false;
        },
        onTap: () {
          watchController.handleControlsTap();
          watchController.updateEntry();
        },
        onVerticalDragUpdate: (e) async {
          watchController.handleVerticalDrag(e, context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Obx(
              () => Video(
                fit: watchController.getMode(watchController.currentMode),
                controller: watchController.controller,
                filterQuality: FilterQuality.low,
                controls: null,
              ),
            ),
            Positioned.fill(
              child: Obx(
                () => AnimatedOpacity(
                  opacity: watchController.showControls.value ? 0.2 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const AzyXContainer(color: Colors.black),
                ),
              ),
            ),
            watchController.buildRippleEffect(context),
            Positioned.fill(
              child: Obx(
                () => IgnorePointer(
                  ignoring: !watchController.showControls.value,
                  child: watchController.customControls(context),
                ),
              ),
            ),
            watchController.episodeListDrawer(),
            watchController.volumeIndicator(),
            watchController.brightnessIndicator(),
            watchController.preesedBar(),
          ],
        ),
      ),
    );
  }
}
