import 'dart:developer';

import 'package:azyx/Classes/anilist_anime_data.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/manga/main_carousale.dart';
import 'package:azyx/Widgets/manga/manga_scrollable_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Widgets/common/search_bar.dart';

class MangaScreen extends StatefulWidget {
  const MangaScreen({super.key});

  @override
  State<MangaScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<MangaScreen> {
  final AnilistAuth anilistController = Get.put(AnilistAuth());
  Rx<AnilistAnimeData> animeData = Rx<AnilistAnimeData>(AnilistAnimeData());

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await anilistController.fetchAnilistManga();
      if (response.isBlank!) {
        log("Error: Failed to fetch Anilist data. Response is null.");
        return;
      }
      animeData.value = response;
      log("Anime data fetched successfully: ${animeData.value.spotLightAnimes!.first.id.toString()}");
    } catch (e, stackTrace) {
      log("Exception occurred in loadData: $e", stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (animeData.value.spotLightAnimes == null) {
        return const Center(
          child: CircularProgressIndicator(),
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
            MangaMainCarousale(data: animeData.value.spotLightAnimes!),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 10,
            ),
            MangaScrollableList(
              managaList: animeData.value.popularAnimes!,
              title: "Popular Animes",
            ),
            MangaScrollableList(
              managaList: animeData.value.topUpcomingAnimes!,
              title: "TopUpcoming Manga",
            ),
            const SizedBox(
              height: 10,
            ),
            MangaScrollableList(
              managaList: animeData.value.completed!,
              title: "Completed Manga",
            ),
          ],
        ),
      );
    });
  }
}
