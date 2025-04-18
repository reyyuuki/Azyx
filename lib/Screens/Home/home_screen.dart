import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: ListView(
        children: [
          const Header(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                listButton(context, "Animelist", Icons.movie_filter),
                20.width,
                listButton(context, "MangaList", Broken.book)
              ],
            ),
          ),
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
                  anilistAuthController.userSepratedAnimeList.value
                                  ?.currentlyWatching !=
                              null &&
                          anilistAuthController.userSepratedAnimeList.value!
                              .currentlyWatching.isNotEmpty
                      ? AnimeScrollableList(
                          varient: CarousaleVarient.userList,
                          isManga: false,
                          animeList: anilistAuthController
                              .userSepratedAnimeList.value!.currentlyWatching,
                          title: "Currently Watching",
                        )
                      : const SizedBox.shrink(),
                  AnimeScrollableList(
                    animeList: anilistAuthController
                        .animeData.value.topUpcomingAnimes!,
                    isManga: false,
                    title: "TopUpcoming Animes",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AnimeScrollableList(
                    animeList: anilistAuthController.animeData.value.completed!,
                          isManga: false,
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

  listButton(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          5.height,
          AzyXText(
            text: title,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
            fontVariant: FontVariant.bold,
          ),
        ],
      ),
    );
  }
}
