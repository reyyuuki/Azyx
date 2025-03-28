import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Classes/offline_item.dart';
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
            SizedBox(
                height: 50,
                child: PlatformBuilder(
                  desktopBuilder: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: mediaData.value.genres!
                        .map((i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                          .withOpacity(1.glowMultiplier()),
                                      blurRadius: 10.blurMultiplier(),
                                      spreadRadius: 2.spreadMultiplier())
                                ],
                                borderRadius: BorderRadius.circular(20)),
                            child: AzyXText(
                              text: i,
                              fontVariant: FontVariant.bold,
                              color: Theme.of(context).colorScheme.primary,
                            )))
                        .toList(),
                  ),
                  androidBuilder: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: mediaData.value.genres!
                        .map((i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                          .withOpacity(1.glowMultiplier()),
                                      blurRadius: 10.blurMultiplier(),
                                      spreadRadius: 2.spreadMultiplier())
                                ]),
                            child: AzyXText(
                              text: i,
                              fontVariant: FontVariant.bold,
                              color: Theme.of(context).colorScheme.primary,
                            )))
                        .toList(),
                  ),
                )),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: getResponsiveSize(context,
                      mobileSize: Get.width - 40, dektopSize: 300),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                      color: Get.theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Get.theme.colorScheme.secondaryContainer
                                .withOpacity(1.glowMultiplier()),
                            blurRadius: 10.blurMultiplier(),
                            spreadRadius: 2.spreadMultiplier())
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      detailsItem("Rating", mediaData.value.rating!),
                      detailsItem(
                          "Popular", mediaData.value.popularity.toString()),
                      detailsItem("Status", mediaData.value.status!)
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
                animeList: mediaData.value.relations!, title: "Related Animes"),
            const SizedBox(
              height: 10,
            ),
            AnimeScrollableList(
                animeList: mediaData.value.recommendations!,
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
        iconWithText(data)
      ],
    );
  }

  Row iconWithText(String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AzyXText(
            text: '#$data',
            fontVariant: FontVariant.bold,
            fontSize: 16,
            color: Get.theme.colorScheme.primary)
      ],
    );
  }
}
