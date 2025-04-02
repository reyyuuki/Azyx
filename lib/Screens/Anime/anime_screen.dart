import 'dart:developer';

import 'package:azyx/Classes/anilist_anime_data.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/anime/main_carousale.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Widgets/common/search_bar.dart';

class AnimeScreen extends StatelessWidget {
  const AnimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: ListView(
        children: [
          const Header(),
          Obx(() {
            if (anilistAuthController.animeData.value.spotLightAnimes == null) {
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
                      animeData: anilistAuthController
                          .animeData.value.spotLightAnimes!),
                  const SizedBox(
                    height: 20,
                  ),
                  AnimeScrollableList(
                    animeList:
                        anilistAuthController.animeData.value.popularAnimes!,
                    title: "Popular Animes",
                  ),
                  AnimeScrollableList(
                    animeList: anilistAuthController
                        .animeData.value.topUpcomingAnimes!,
                    title: "TopUpcoming Animes",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AnimeScrollableList(
                    animeList: anilistAuthController.animeData.value.completed!,
                    title: "Completed Animes",
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
