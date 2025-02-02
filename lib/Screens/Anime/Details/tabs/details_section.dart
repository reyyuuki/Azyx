import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/characters_list.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsSection extends StatelessWidget {
  final UiSettingController settings;
  final Rx<DetailsData> mediaData;
  const DetailsSection(
      {super.key, required this.mediaData, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      physics: const BouncingScrollPhysics(),
      children: [
        AzyXText(
          mediaData.value.title!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: "Poppins-Bold", fontSize: 18),
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
              size: 30,
              shadows: [
                BoxShadow(
                    color: Colors.yellow,
                    blurRadius: 10 * settings.blurMultiplier,
                    spreadRadius: 2 * settings.spreadMultiplier)
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            AzyXText(
              mediaData.value.rating!,
              style: const TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
            )
          ],
        ),
        const SizedBox(height: 10,),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          children: mediaData.value.genres!
              .map((i) => Chip(elevation: 10, label: AzyXText(i)))
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText("Japanese: ",
                    style: TextStyle(fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                AzyXText("Aired: ", style: TextStyle(fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                AzyXText("Premiered: ",
                    style: TextStyle(fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                AzyXText("Duration: ",
                    style: TextStyle(fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                AzyXText("Status: ",
                    style: TextStyle(fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                AzyXText("Rating: ",
                    style: TextStyle(fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                AzyXText("Quality: ",
                    style: TextStyle(fontFamily: "Poppins-Bold")),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AzyXText(
                    mediaData.value.japaneseTitle ?? "??",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: "Poppins-Bold"),
                  ),
                  const SizedBox(height: 5),
                  AzyXText(
                    mediaData.value.aired ?? "??",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: "Poppins-Bold"),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  AzyXText(mediaData.value.premiered ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  AzyXText(mediaData.value.duration ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  AzyXText(mediaData.value.status ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  AzyXText(mediaData.value.rating ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  AzyXText(mediaData.value.quality ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        AzyXText(
          mediaData.value.description ?? "??",
          style: const TextStyle(
              fontFamily: "Poppins", fontStyle: FontStyle.italic),
        ),
        const SizedBox(
          height: 20,
        ),
        CharactersList(
            characterList: mediaData.value.characters!, title: "Characters"),
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
    );
  }
}
