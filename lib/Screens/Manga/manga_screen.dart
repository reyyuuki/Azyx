import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MangaScreen extends StatelessWidget {
  const MangaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: ListView(
        children: [
          const Header(),
          Obx(() {
            return SingleChildScrollView(
              child: ListView(
                  padding: const EdgeInsets.all(10),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: serviceHandler.mangaWidgets(context)
                  // buildSearchButton(context, () {
                  //   Get.to(() => const SearchScreen(
                  //         isManga: true,
                  //       ));
                  // }),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // MainCarousale(
                  //     isManga: true,
                  //     data: anilistAuthController
                  //         .mangaData.value.spotLightAnimes!),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // AnimeScrollableList(
                  //   animeList:
                  //       anilistAuthController.mangaData.value.popularAnimes!,
                  //   isManga: true,
                  //   title: "Popular Mangas",
                  // ),
                  // AnimeScrollableList(
                  //   isManga: true,
                  //   animeList: anilistAuthController
                  //       .mangaData.value.topUpcomingAnimes!,
                  //   title: "TopUpcoming Manga",
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // AnimeScrollableList(
                  //   animeList: anilistAuthController.mangaData.value.completed!,
                  //   isManga: true,
                  //   title: "Completed Manga",
                  // ),

                  ),
            );
          }),
        ],
      ),
    );
  }
}
