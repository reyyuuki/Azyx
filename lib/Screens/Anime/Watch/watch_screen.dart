import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/controller/watch_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:media_kit_video/media_kit_video.dart';
class WatchScreen extends StatefulWidget {
  final AnimeAllData playerData;
  const WatchScreen({super.key, required this.playerData});
  @override
  State<WatchScreen> createState() => _WatchScreenState();
}
class _WatchScreenState extends State<WatchScreen> {
  final WatchController watchController = Get.put(WatchController());
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
          if (!watchController.isPlayerReady.value) return;
          watchController.isPressed.value = true;
          watchController.player.setRate(2.0);
        },
        onLongPressEnd: (d) {
          if (!watchController.isPlayerReady.value) return;
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
              () => watchController.isPlayerReady.value
                  ? Video(
                      fit: watchController.getMode(watchController.currentMode),
                      controller: watchController.controller,
                      filterQuality: FilterQuality.low,
                      subtitleViewConfiguration:
                          const SubtitleViewConfiguration(visible: false),
                      controls: null,
                    )
                  : const ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: LoadingIndicatorM3E(),
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: Obx(
                () => AnimatedOpacity(
                  opacity: watchController.showControls.value ? 0.38 : 0.0,
                  duration: const Duration(milliseconds: 220),
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
            watchController.buildSubtitleOverlay(context),
            watchController.episodeListDrawer(),
            watchController.volumeIndicator(),
            watchController.brightnessIndicator(),
            watchController.preesedBar(),
            // watchController.buildReactionsOverlay(),
          ],
        ),
      ),
    );
  }
}
