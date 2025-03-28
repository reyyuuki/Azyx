import 'dart:developer';

import 'package:azyx/Classes/anime_all_data.dart';
import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Classes/user_anime.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final AnilistAddToListController anilistAddToListController =
    Get.find<AnilistAddToListController>();

class AnilistAddToListController extends GetxController {
  final Rx<UserAnime> anime = UserAnime().obs;
  final Rx<UserAnime> manga = UserAnime().obs;
  TextEditingController? controller;

  void findAnime(AnilistMediaData data) {
    log("Started");
    if (anilistAuthController.userAnimeList.isNotEmpty) {
      anime.value = anilistAuthController.userAnimeList.firstWhere(
        (i) => i.id == data.id,
        orElse: () {
          return UserAnime(
              id: data.id,
              progress: 0,
              episodes: data.episodes,
              tilte: data.title);
        },
      );
      log("status: ${anime.value.status}");
    }
    log("status: ${anime.value.status}");
  }

  void findManga(AnilistMediaData data) {
    if (anilistAuthController.userMangaList.isNotEmpty) {
      manga.value = anilistAuthController.userMangaList.firstWhere(
        (i) => i.id == data.id,
        orElse: () {
          return UserAnime(
              id: data.id,
              progress: 0,
              episodes: data.episodes,
              tilte: data.title);
        },
      );
      log("status: ${manga.value.status}");
    } else {
      log("nothing found");
    }
  }

  void updateAnimeProgress(AnimeAllData data, int number) {
    if (anilistAuthController.userAnimeList.isNotEmpty) {
      try {
        anime.value = anilistAuthController.userAnimeList.firstWhere(
          (i) => i.tilte == data.title,
          orElse: () {
            log("No existing anime found, creating new UserAnime entry.");
            return UserAnime(
              id: data.id,
              status: "CURRENT",
              score: 5,
              progress: number,
            );
          },
        );
        anilistAuthController.addToAniList(
          mediaId: anime.value.id!,
          progress: number,
          status: anime.value.status,
        );
      } catch (e) {
        log("Error in updateAnimeProgress: $e");
      }
    } else {
      log("User anime list is empty.");
    }
  }

  void addToListSheet(
      BuildContext context, String image, String title, int totalEpisodes) {
    controller = TextEditingController(
      text: anime.value.progress?.toString() ?? '1',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 1),
          child: AzyXGradientContainer(
            height: Get.height * 0.5,
            padding: const EdgeInsets.all(15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: ListView(
              children: [
                AzyXText(
                  text: 'Add To List',
                  textAlign: TextAlign.center,
                  fontVariant: FontVariant.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 30,
                ),
                DropdownButtonFormField<String>(
                  value: anime.value.status ?? "CURRENT",
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Choose Status',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerLowest,
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryFixedVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  isDense: true,
                  items: items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      anime.value.status = newValue;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<double>(
                  value: anime.value.score?.toDouble() ?? 5.0,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Choose Score',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerLowest,
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryFixedVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  isDense: true,
                  items:
                      scoresItems.map<DropdownMenuItem<double>>((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    if (newValue != null) {
                      anime.value.score = newValue.toInt();
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                inputbox(context, controller, totalEpisodes,
                    (value) => anime.value.progress = value,"Episode"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: customButton(context, "cancel"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        anilistAuthController.addToAniList(
                            mediaId: anime.value.id!,
                            status: anime.value.status,
                            score: anime.value.score?.toDouble() ?? 5.0,
                            progress: anime.value.progress);
                        Navigator.pop(context);
                        log(anime.value.progress.toString());
                        azyxSnackBar("Sucessfully added ${anime.value.tilte}");
                      },
                      child: customButton(context, "Save"),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void addToMangaListSheet(
      BuildContext context, String image, String title, int totalEpisodes) {
    controller = TextEditingController(
      text: manga.value.progress?.toString() ?? '1',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 1),
          child: AzyXGradientContainer(
            height: Get.height * 0.5,
            padding: const EdgeInsets.all(15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: ListView(
              children: [
                AzyXText(
                  text: 'Add To List',
                  textAlign: TextAlign.center,
                  fontVariant: FontVariant.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 30,
                ),
                DropdownButtonFormField<String>(
                  value: manga.value.status ?? "CURRENT",
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Choose Status',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerLowest,
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryFixedVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  isDense: true,
                  items: items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      manga.value.status = newValue;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<double>(
                  value: manga.value.score?.toDouble() ?? 5.0,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Choose Score',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerLowest,
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryFixedVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  isDense: true,
                  items:
                      scoresItems.map<DropdownMenuItem<double>>((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    if (newValue != null) {
                      manga.value.score = newValue.toInt();
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                inputbox(context, controller, totalEpisodes,
                    (value) => manga.value.progress = value, "Chapter"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: customButton(context, "cancel"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        anilistAuthController.addToAniList(
                            mediaId: manga.value.id!,
                            status: manga.value.status,
                            score: manga.value.score?.toDouble() ?? 5.0,
                            progress: manga.value.progress ?? 0);
                        Navigator.pop(context);
                        azyxSnackBar("Sucessfully added ${manga.value.tilte}");
                      },
                      child: customButton(context, "Save"),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Container customButton(BuildContext context, String buttonText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(
            width: 0.5, color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontFamily: "Poppins-Bold", fontSize: 18),
      ),
    );
  }

  SizedBox inputbox(BuildContext context, controller, int max,
      void Function(int value) onChanged, String label) {
    return SizedBox(
      height: 57,
      child: TextField(
        expands: true,
        maxLines: null,
        controller: controller,
        onChanged: (value) {
          if (value.isNotEmpty) {
            int number = int.tryParse(value) ?? 0;
            onChanged(number);
            if (number > max) {
              controller.value = TextEditingValue(
                text: max.toString(),
              );
              log(anime.value.progress.toString());
            } else if (number < 0) {
              controller.value = const TextEditingValue(
                text: '0',
              );
              anime.value.progress = 1;
            }
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              '/ $max',
              style: const TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
            ),
          ),
          contentPadding: const EdgeInsets.all(10),
          labelText: '$label Progress',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
