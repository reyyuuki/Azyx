import 'dart:developer';

import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/custom_text_field.dart';
import 'package:azyx/Widgets/drop_dwon.dart';
import 'package:azyx/utils/constants.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final AnilistAddToListController anilistAddToListController =
    Get.find<AnilistAddToListController>();

class AnilistAddToListController extends GetxController {
  final Rx<UserAnime> anime = UserAnime().obs;
  final Rx<UserAnime> manga = UserAnime().obs;
  final Rx<String> animeStatus = ''.obs;
  final Rx<String> mangaStatus = ''.obs;
  TextEditingController? controller;

  void findAnime(AnilistMediaData data) {
    for (var i in serviceHandler.userAnimeList.value.allList) {
      Utils.log(i.id.toString());
    }
    if (serviceHandler.userAnimeList.value.allList.isNotEmpty) {
      log("id:${serviceHandler.userAnimeList.value.allList.first.id} / ${data.id}");
      anime.value = serviceHandler.userAnimeList.value.allList.firstWhere(
        (i) => i.id == data.id!,
        orElse: () {
          return UserAnime(
              id: data.id,
              progress: 1,
              episodes: data.episodes,
              title: data.title);
        },
      );
      animeStatus.value = anime.value.status ?? '';
    }
    log("status: ${anime.value.status}");
  }

  void findManga(AnilistMediaData data) {
    if (serviceHandler.userMangaList.value.allList.isNotEmpty) {
      manga.value = serviceHandler.userMangaList.value.allList.firstWhere(
        (i) => i.id == data.id,
        orElse: () {
          return UserAnime(
              id: data.id,
              progress: 0,
              episodes: data.episodes,
              title: data.title);
        },
      );
      mangaStatus.value = manga.value.status ?? '';
      log("status: ${manga.value.status}");
    } else {
      log("nothing found");
    }
  }

  void updateAnimeProgress(AnimeAllData data, int number) {
    if (serviceHandler.userAnimeList.value.allList.isNotEmpty) {
      try {
        anime.value = serviceHandler.userAnimeList.value.allList.firstWhere(
          (i) => i.title == data.title,
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
        serviceHandler.updateListEntry(
            UserAnime(
              id: anime.value.id!,
              progress: number,
              status: anime.value.status,
            ),
            isAnime: true);
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
      barrierColor: Colors.black87.withOpacity(0.6),
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadow.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: theme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: theme.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AzyXText(
                                    text: 'Add to Your List',
                                    fontSize: 24,
                                    fontVariant: FontVariant.bold,
                                    color: theme.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  AzyXText(
                                    text: title,
                                    fontSize: 16,
                                    fontVariant: FontVariant.regular,
                                    color: theme.onSurfaceVariant,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AzyXText(
                                      text: '$totalEpisodes Episodes',
                                      fontSize: 12,
                                      fontVariant: FontVariant.bold,
                                      color: theme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        AzyXText(
                          text: 'Watching Status',
                          fontSize: 14,
                          fontVariant: FontVariant.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        Obx(() => CustomDropdown<String>(
                              items: items,
                              selectedValue: anime.value.status ?? "CURRENT",
                              labelText: 'Watching Status',
                              displayText: (value) => value,
                              hintText: 'Select status...',
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  anime.update((val) {
                                    val?.status = newValue;
                                  });
                                }
                                log(anime.value.status.toString());
                              },
                            )),
                        const SizedBox(height: 24),
                        AzyXText(
                          text: 'Your Rating',
                          fontSize: 14,
                          fontVariant: FontVariant.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        Obx(() => CustomDropdown<double>(
                              items: scoresItems,
                              selectedValue:
                                  anime.value.score?.toDouble() ?? 5.0,
                              labelText: 'Rating',
                              displayText: (value) => '${value.toString()} ⭐',
                              hintText: 'Select rating...',
                              onChanged: (double? newValue) {
                                if (newValue != null) {
                                  anime.update((val) {
                                    val?.score = newValue;
                                  });
                                }
                              },
                            )),
                        const SizedBox(height: 24),
                        AzyXText(
                          text: 'Progress',
                          fontSize: 14,
                          fontVariant: FontVariant.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        CustomInputField(
                          controller: controller!,
                          labelText: 'Episode Progress',
                          hintText: 'Enter episode number...',
                          maxValue: totalEpisodes,
                          suffixText: '/ $totalEpisodes',
                          onChanged: (value) {
                            anime.update((val) {
                              val?.progress = value ?? 0;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: AzyXText(
                                      text: 'Cancel',
                                      fontSize: 16,
                                      fontVariant: FontVariant.bold,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  animeStatus.value =
                                      anime.value.status ?? "CURRENT";
                                  serviceHandler.updateListEntry(
                                      UserAnime(
                                          id: anime.value.id!,
                                          status: animeStatus.value,
                                          score: anime.value.score ?? 5,
                                          progress: anime.value.progress),
                                      isAnime: true);
                                  Navigator.pop(context);
                                  log(anime.value.progress.toString());
                                  azyxSnackBar(
                                      "Successfully added ${anime.value.title}");
                                },
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primary,
                                        theme.primary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.playlist_add,
                                          color: theme.onPrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        AzyXText(
                                          text: 'Add to List',
                                          fontSize: 16,
                                          fontVariant: FontVariant.bold,
                                          color: theme.onPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
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
      barrierColor: Colors.black87.withOpacity(0.6),
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadow.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: theme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: theme.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AzyXText(
                                    text: 'Add to Your List',
                                    fontSize: 24,
                                    fontVariant: FontVariant.bold,
                                    color: theme.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  AzyXText(
                                    text: title,
                                    fontSize: 16,
                                    fontVariant: FontVariant.regular,
                                    color: theme.onSurfaceVariant,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AzyXText(
                                      text: '$totalEpisodes Chapters',
                                      fontSize: 12,
                                      fontVariant: FontVariant.bold,
                                      color: theme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        AzyXText(
                          text: 'Reading Status',
                          fontSize: 14,
                          fontVariant: FontVariant.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        Obx(() => CustomDropdown<String>(
                              items: items,
                              selectedValue: mangaStatus.value.isEmpty
                                  ? "CURRENT"
                                  : mangaStatus.value,
                              labelText: 'Reading Status',
                              displayText: (value) => value,
                              hintText: 'Select status...',
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  manga.update((val) {
                                    val?.status = newValue;
                                  });
                                  mangaStatus.value = newValue;
                                }
                              },
                            )),
                        const SizedBox(height: 24),
                        AzyXText(
                          text: 'Your Rating',
                          fontSize: 14,
                          fontVariant: FontVariant.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        Obx(() => CustomDropdown<double>(
                              items: scoresItems,
                              selectedValue:
                                  manga.value.score?.toDouble() ?? 5.0,
                              labelText: 'Rating',
                              displayText: (value) => '${value.toString()} ⭐',
                              hintText: 'Select rating...',
                              onChanged: (double? newValue) {
                                if (newValue != null) {
                                  manga.update((val) {
                                    val?.score = newValue;
                                  });
                                }
                              },
                            )),
                        const SizedBox(height: 24),
                        AzyXText(
                          text: 'Progress',
                          fontSize: 14,
                          fontVariant: FontVariant.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        CustomInputField(
                          controller: controller!,
                          labelText: 'Chapter Progress',
                          hintText: 'Enter chapter number...',
                          maxValue: totalEpisodes,
                          suffixText: '/ $totalEpisodes',
                          onChanged: (value) {
                            manga.update((val) {
                              val?.progress = value ?? 0;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: AzyXText(
                                      text: 'Cancel',
                                      fontSize: 16,
                                      fontVariant: FontVariant.bold,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  mangaStatus.value =
                                      manga.value.status ?? 'CURRENT';
                                  serviceHandler.updateListEntry(
                                      UserAnime(
                                          id: manga.value.id!,
                                          status: manga.value.status,
                                          score: manga.value.score ?? 5,
                                          progress: manga.value.progress ?? 0),
                                      isAnime: false);
                                  Navigator.pop(context);
                                  azyxSnackBar(
                                      "Successfully added ${manga.value.title}");
                                },
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primary,
                                        theme.primary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bookmark_add,
                                          color: theme.onPrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        AzyXText(
                                          text: 'Add to List',
                                          fontSize: 16,
                                          fontVariant: FontVariant.bold,
                                          color: theme.onPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
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
            int number = int.tryParse(value) ?? 1;
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
