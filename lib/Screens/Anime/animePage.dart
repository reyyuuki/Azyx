import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/backupData/anilist_anime.dart';
import 'package:azyx/components/Anime/anime_carousale.dart';
import 'package:azyx/components/Common/check_platform.dart';
import 'package:azyx/components/Desktop/anime/desktop_carousale.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:azyx/components/Common/Header.dart';
import 'package:azyx/components/Anime/reusableList.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Animepage extends StatefulWidget {
  const Animepage({super.key});

  @override
  State<Animepage> createState() => _HomepageState();
}

class _HomepageState extends State<Animepage> {
  dynamic mostPopularAnimes;
  dynamic trendingAnime;
  dynamic latestEpisodesAnime;
  dynamic topUpComingAnime;
  dynamic baseData;
  var box = Hive.box("app-data");

  @override
  void initState() {
    super.initState();
    if(mounted){
    backupData();
    }
  }

  void backupData() {
    setState(() {
      mostPopularAnimes = fallbackAnilistData['data']['popularAnimes']['media'];
      trendingAnime = fallbackAnilistData['data']['trendingAnimes']['media'];
      latestEpisodesAnime =
          fallbackAnilistData['data']['latestAnimes']['media'];
      topUpComingAnime = fallbackAnilistData['data']['top10Today']['media'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<AniListProvider>(
          builder: (context, provider, child) {
            mostPopularAnimes = provider.anilistData['popular'] ?? mostPopularAnimes;
            trendingAnime = provider.anilistData['trending'] ?? trendingAnime;
            latestEpisodesAnime = latestEpisodesAnime;
            topUpComingAnime = trendingAnime;

          return ListView(
            physics: const BouncingScrollPhysics(),
              children: [
                const Header(
                  name: "Anime",
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      onSubmitted: (String value) {
                        Navigator.pushNamed(
                          context,
                          '/searchAnime',
                          arguments: {"name": value},
                        );
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.search_normal),
                        hintText: 'Search Anime...',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                PlatformWidget(androidWidget: AnimeCarousale(
                  animeData: trendingAnime,
                  route: '/detailspage',
                  name: "Play",
                ), windowsWidget: DesktopCarousale(route: '/detailspage', name: "Play", animeData: trendingAnime,)),
               
                const SizedBox(height: 30.0),
                ReusableList(
                  name: 'Popular Animes',
                  data: mostPopularAnimes,
                  taggName: "Carousale1",
                  route: '/detailspage',
                ),
                const SizedBox(height: 10),
                ReusableList(
                  name: 'Top Upcoming',
                  data: topUpComingAnime,
                  taggName: "Carousale3",
                  route: '/detailspage',
                ),
                const SizedBox(height: 10),
                ReusableList(
                  name: 'Latest Episodes',
                  data: latestEpisodesAnime,
                  taggName: "Carousale2",
                  route: '/detailspage',
                ),
              ],
                              );
          }
      )
      )
    );
  }
}
