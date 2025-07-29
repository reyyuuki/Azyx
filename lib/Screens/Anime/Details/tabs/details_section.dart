import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Screens/Anime/Details/tabs/add_to_list_floater.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/manga_add_to_list.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/characters_list.dart';
import 'package:azyx/Widgets/helper/platform_builder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsSection extends StatelessWidget {
  final Rx<AnilistMediaData> mediaData;
  final int index;
  final List<Episode>? episodesList;
  final List<Chapter>? chapterList;
  final String animeTitle;
  final bool isManga;
  const DetailsSection(
      {super.key,
      required this.mediaData,
      required this.index,
      required this.animeTitle,
      required this.isManga,
      this.chapterList,
      this.episodesList});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          physics: const BouncingScrollPhysics(),
          children: [
            AzyXText(
              text: mediaData.value.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              fontSize: 18,
              fontVariant: FontVariant.bold,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Broken.star,
                  color: Colors.yellow,
                  shadows: [
                    BoxShadow(
                        color: Colors.yellow,
                        blurRadius: 10.blurMultiplier(),
                        spreadRadius: 2.spreadMultiplier())
                  ],
                ),
                const SizedBox(
                  width: 5,
                ),
                AzyXText(
                  text: mediaData.value.rating!,
                  fontSize: 16,
                  fontVariant: FontVariant.bold,
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (mediaData.value.genres != null ||
                mediaData.value.genres!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: mediaData.value.genres!.map((genre) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: getResponsiveSize(context,
                      mobileSize: Get.width - 40, dektopSize: 600),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Get.theme.colorScheme.secondaryContainer
                            .withOpacity(0.95),
                        Get.theme.colorScheme.secondaryContainer
                            .withOpacity(0.8),
                        Get.theme.colorScheme.secondaryContainer
                            .withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Get.theme.colorScheme.primary.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      // Main glow shadow
                      BoxShadow(
                        color: Get.theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      // Inner highlight
                      BoxShadow(
                        color: Get.theme.colorScheme.surface.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: -4,
                        offset: const Offset(0, -2),
                      ),
                      // Ambient shadow
                      BoxShadow(
                        color: Get.theme.colorScheme.shadow.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: detailsItem("Rating", mediaData.value.rating!),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Stack(
                          children: [
                            // Background glow
                            Positioned(
                              left: -3.5,
                              child: Container(
                                width: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.0),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.6),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.9),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.6),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Get.theme.colorScheme.primary
                                        .withOpacity(0.4),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 22,
                              left: -1.5,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Get.theme.colorScheme.primary
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Get.theme.colorScheme.primary
                                          .withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: detailsItem(
                              "Popular", mediaData.value.popularity.toString()),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Stack(
                          children: [
                            Positioned(
                              left: -3.5,
                              child: Container(
                                width: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.0),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      Get.theme.colorScheme.primary
                                          .withOpacity(0.0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.6),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.9),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.6),
                                    Get.theme.colorScheme.primary
                                        .withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Get.theme.colorScheme.primary
                                        .withOpacity(0.4),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 22,
                              left: -1.5,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Get.theme.colorScheme.primary
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Get.theme.colorScheme.primary
                                          .withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: detailsItem("Status", mediaData.value.status!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            AzyXText(
              text: mediaData.value.description ?? "??",
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              fontStyle: FontStyle.italic,
            ),
            const SizedBox(
              height: 20,
            ),
            CharactersList(
                characterList: mediaData.value.characters!,
                title: "Characters"),
            const SizedBox(
              height: 10,
            ),
            AnimeScrollableList(
                isManga: isManga,
                animeList: mediaData.value.relations ?? [],
                title: "Related Animes"),
            const SizedBox(
              height: 10,
            ),
            AnimeScrollableList(
                isManga: isManga,
                animeList: mediaData.value.recommendations ?? [],
                title: "Recommendations")
          ],
        ),
        isManga
            ? MangaAddToList(
                index: index,
                mediaData: mediaData.value,
                data: OfflineItem(
                    mediaData: mediaData.value,
                    number: '1',
                    animeTitle: animeTitle,
                    chaptersList: chapterList ?? []))
            : AddToListFloater(
                index: index,
                mediaData: mediaData.value,
                data: OfflineItem(
                    mediaData: mediaData.value,
                    number: '1',
                    animeTitle: animeTitle,
                    episodesList: episodesList ?? []),
              )
      ],
    );
  }

  Column detailsItem(String name, String data) {
    return Column(
      children: [
        AzyXText(
          text: name,
        ),
        const SizedBox(
          height: 10,
        ),
        AzyXText(
          text: '#$data',
          fontVariant: FontVariant.bold,
          fontSize: 16,
          color: Get.theme.colorScheme.primary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
