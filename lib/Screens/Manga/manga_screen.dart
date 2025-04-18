import 'dart:developer';

import 'package:azyx/Models/anilist_anime_data.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/main_carousale.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:azyx/Widgets/manga/main_carousale.dart';
import 'package:azyx/Widgets/manga/manga_scrollable_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Widgets/common/search_bar.dart';

class MangaScreen extends StatelessWidget {
  const MangaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: ListView(
        children: [
          const Header(),
          Obx(() {
            if (anilistAuthController.mangaData.value.spotLightAnimes == null) {
              return Container(
                alignment: Alignment.center,
                height: Get.height * 0.8,
                child: const CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: ListView(
                padding: const EdgeInsets.all(10),
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  const SearchWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  MainCarousale(
                    isManga: true,
                      data: anilistAuthController
                          .mangaData.value.spotLightAnimes!),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AnimeScrollableList(
                    animeList:
                        anilistAuthController.mangaData.value.popularAnimes!,
                    isManga: true,
                    title: "Popular Animes",
                  ),
                  AnimeScrollableList(
                    isManga: true,
                    animeList: anilistAuthController
                        .mangaData.value.topUpcomingAnimes!,
                    title: "TopUpcoming Manga",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AnimeScrollableList(
                    animeList: anilistAuthController.mangaData.value.completed!,
                    isManga: true,
                    title: "Completed Manga",
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
