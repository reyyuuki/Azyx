import 'package:anymex_extension_runtime_bridge/Models/Video.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
class EpisodeBottomSheet extends StatelessWidget {
  final List<Video> episodeUrls;
  final Rx<bool> hasError;
  final String number;
  final Function(BuildContext, String, String, String) serverAzyXContainer;
  const EpisodeBottomSheet({
    super.key,
    required this.episodeUrls,
    required this.hasError,
    required this.number,
    required this.serverAzyXContainer,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      height: 360,
      child: Column(
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AzyXText(
            text: "Select Server / Quality",
            fontSize: 18,
            fontVariant: FontVariant.bold,
            color: colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () => hasError.value
                  ? Center(
                      child: Image.asset(
                        'assets/images/sticker.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : episodeUrls.isEmpty
                  ? const Center(child: LoadingIndicatorM3E())
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      children: episodeUrls.map<Widget>((item) {
                        return serverAzyXContainer(
                          context,
                          item.title ?? 'Unknown',
                          item.url,
                          number,
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
void showEpisodeBottomSheet(
  BuildContext context,
  String number,
  List<Video> episodeUrls,
  Rx<bool> hasError,
  Function(BuildContext, String, String, String) serverAzyXContainer,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    isScrollControlled: true,
    enableDrag: true,
    elevation: 5,
    barrierColor: Colors.black87.withOpacity(0.5),
    builder: (context) => EpisodeBottomSheet(
      episodeUrls: episodeUrls,
      hasError: hasError,
      number: number,
      serverAzyXContainer: serverAzyXContainer,
    ),
  );
}
