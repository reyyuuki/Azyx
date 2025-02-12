import 'package:azyx/Classes/anime_all_data.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

void showSubtitleSheet(Rx<AnimeAllData> animeData,Rx<String> selectedSbt) {
  showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      context: Get.context!,
      builder: (context) {
        return animeData.value.episodeUrls!.first.subtitles == null
            ? AzyXContainer(
                alignment: Alignment.center,
                width: 400,
                height: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    gradient: LinearGradient(
                        colors: Get.isDarkMode
                            ? [
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withAlpha(20),
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(90),
                              ]
                            : [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.surface
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: const AzyXText(
                  "Sorry, no subtitles found.",
                  style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              )
            : AzyXContainer(
                padding: const EdgeInsets.all(10),
                height: 300,
                width: 400,
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    gradient: LinearGradient(
                        colors: Get.isDarkMode
                            ? [
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withAlpha(20),
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(90),
                              ]
                            : [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.surface
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const AzyXText(
                      "Select Subtitle",
                      style:
                          TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                              onTap: () {},
                              child: AzyXContainer(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: selectedSbt.value.isEmpty ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 0.4,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                                child: const AzyXText(
                                  "None",
                                  style: TextStyle(
                                    color: Colors.black,
                                      fontFamily: "Poppins-Bold", fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    SingleChildScrollView(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: animeData
                              .value.episodeUrls!.first.subtitles!.length,
                          itemBuilder: (context, index) {
                            final item = animeData
                                .value.episodeUrls!.first.subtitles![index];
                            return GestureDetector(
                              onTap: () {},
                              child: AzyXContainer(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 0.4,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                                child: AzyXText(
                                  item.label!,
                                  style: const TextStyle(
                                      fontFamily: "Poppins", fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                ));
      });
}

void showQualitySheet(BuildContext context, Rx<AnimeAllData> animeData,
    Player player, Rx<Duration> position, Rx<bool> isPotraitOrientaion) {
  showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      context: context,
      builder: (context) {
        return AzyXContainer(
            padding: const EdgeInsets.all(10),
            height: isPotraitOrientaion.value ? Get.height / 2 : 300,
            width: 400,
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(
                    colors: Get.isDarkMode
                        ? [
                            Theme.of(context).colorScheme.surface.withAlpha(20),
                            Theme.of(context).colorScheme.primary.withAlpha(90),
                          ]
                        : [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: ListView(
              padding: const EdgeInsets.all(10),
              physics: const BouncingScrollPhysics(),
              children: [
                const AzyXText(
                  "Select Quality",
                  style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: animeData.value.episodeUrls!.length,
                      itemBuilder: (context, index) {
                        final item = animeData.value.episodeUrls![index];
                        return GestureDetector(
                          onTap: () {
                            animeData.value.url = item.url;
                            player.open(Media(item.url, start: position.value));
                            Get.back();
                          },
                          child: AzyXContainer(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: item.url == animeData.value.url
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 0.4,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer)),
                            child: AzyXText(
                              item.quality,
                              style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontSize: 18,
                                  color: item.url == animeData.value.url
                                      ? Colors.black
                                      : Theme.of(context)
                                          .colorScheme
                                          .inverseSurface),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                )
              ],
            ));
      });
}

void showSpeedBottomList(context, RxList<double> speedList,
    Rx<double> selectedSpeed, Player player, Rx<bool> isPotraitOrientaion) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter speedState) {
          return AzyXContainer(
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(
                    colors: Get.isDarkMode
                        ? [
                            Theme.of(context).colorScheme.surface.withAlpha(20),
                            Theme.of(context).colorScheme.primary.withAlpha(90),
                          ]
                        : [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            padding: const EdgeInsets.all(16),
            width: isPotraitOrientaion.value ? Get.width : Get.width * 0.5,
            height:
                isPotraitOrientaion.value ? Get.height * 0.5 : Get.height - 20,
            child: Column(
              children: [
                const AzyXText(
                  "Select Speed",
                  style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: speedList.length,
                    itemBuilder: (context, index) {
                      final Rx<bool> isSelected =
                          (speedList[index] == selectedSpeed.value).obs;
                      return GestureDetector(
                        onTap: () {
                          speedState(() {
                            selectedSpeed.value = speedList[index];
                            isSelected.value = true;
                            player.setRate(speedList[index]);
                            Future.delayed(const Duration(milliseconds: 500),
                                () => Get.back());
                          });
                        },
                        child: AzyXContainer(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Broken.main_component,
                                size: 24,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AzyXText(
                                  '${speedList[index]}x',
                                  style: TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                ),
                              ),
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CheckMark(
                                  strokeWidth: 2,
                                  activeColor: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  inactiveColor: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  duration: const Duration(milliseconds: 400),
                                  active: isSelected.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      });
}
