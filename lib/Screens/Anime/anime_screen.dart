import 'dart:developer';

import 'package:azyx/Classes/anilist_anime_data.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/anime/main_carousale.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Widgets/common/search_bar.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  final AnilistAuth anilistController = Get.put(AnilistAuth());
  Rx<AnilistAnimeData> animeData = Rx<AnilistAnimeData>(AnilistAnimeData());

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await anilistController.fetchAnilistAnimes();
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
            const SizedBox(height: 10,),
            MainCarousale(
                animeData: animeData.value.spotLightAnimes!),
                const SizedBox(height: 20,),
                AnimeScrollableList(
                  animeList: animeData.value.popularAnimes!,
                  title: "Popular Animes",
                ),
                AnimeScrollableList(
                  animeList: animeData.value.topUpcomingAnimes!,
                  title: "TopUpcoming Animes",
                ),
                const SizedBox(height: 10,),
                AnimeScrollableList(
                  animeList: animeData.value.completed!,
                  title: "Completed Animes",
                ),
          ],
        ),
      );
    });
  }
}
