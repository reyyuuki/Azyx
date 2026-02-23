import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:dartotsu_extension_bridge/Models/Video.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return AzyXGradientContainer(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      height: 350,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          AzyXText(
            text: "Select Quality",
            fontSize: 25,
            fontVariant: FontVariant.bold,
            color: Theme.of(context).colorScheme.primary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Obx(() => hasError.value
              ? Image.asset(
                  'assets/images/sticker.png',
                  fit: BoxFit.contain,
                )
              : episodeUrls.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      height: 250,
                      child: const CircularProgressIndicator(),
                    )
                  : Column(
                      children: episodeUrls.map<Widget>((item) {
                        return serverAzyXContainer(
                            context, item.quality, item.url, number);
                      }).toList(),
                    )),
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
    Function(BuildContext, String, String, String) serverAzyXContainer) {
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
