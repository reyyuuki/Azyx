
import 'package:daizy_tv/backupData/anime.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daizy_tv/components/Anime/carousel.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:daizy_tv/components/Anime/reusableList.dart';
import 'package:iconsax/iconsax.dart';

class Animepage extends StatefulWidget {
  const Animepage({super.key});

  @override
  State<Animepage> createState() => _HomepageState();
}

class _HomepageState extends State<Animepage> {
  dynamic spotlightAnime;
  dynamic trendingAnime;
  dynamic latestEpisodesAnime;
  dynamic topUpComingAnime;
  dynamic baseData;
  var box = Hive.box("app-data");
  bool isConsumet = true;

  @override
  void initState() {
    super.initState();
    backUpData();
  }

  void backUpData() {
      setState(() {
        spotlightAnime = animeData['spotlightAnimes'];
        trendingAnime = animeData['trendingAnimes'];
        latestEpisodesAnime = animeData['latestEpisodeAnimes'];
        topUpComingAnime = animeData['topUpcomingAnimes'];
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
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
                            color: Theme.of(context).colorScheme.primary)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Carousel(
              animeData: trendingAnime,
            ),
            const SizedBox(height: 30.0),
            ReusableList(
              name: 'Popular',
              data: spotlightAnime,
              taggName: "Carousale1",
            ),
            const SizedBox(height: 10),
            ReusableList(
              name: 'Latest Episodes',
              data: latestEpisodesAnime,
              taggName: "Carousale2",
            ),
            const SizedBox(height: 10),
            ReusableList(
              name: 'Top Upcoming',
              data: topUpComingAnime,
              taggName: "Carousale3",
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
