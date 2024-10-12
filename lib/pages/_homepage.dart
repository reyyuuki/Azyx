import 'dart:developer';

import 'package:daizy_tv/backupData/anime.dart';
import 'package:daizy_tv/backupData/manga.dart';
import 'package:daizy_tv/components/Anime/reusableList.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:daizy_tv/components/Manga/mangaReusableCarousale.dart';
import 'package:daizy_tv/components/Recently-added/animeCarousale.dart';
import 'package:daizy_tv/components/Recently-added/mangaCarousale.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic recomendAnime;
  dynamic recomendManga;

  @override
  void initState() {
    super.initState();
    data();
  }



  void data() {
    setState(() {
      recomendAnime = animeData["mostPopularAnimes"];
      recomendManga = mangaData["mangaList"];
    });
  }



  @override
  Widget build(BuildContext context) {
    var box = Hive.box("app-data");
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Header(
              name: "Fun",
            ),
            const SizedBox(
              height: 20,
            ),
      // Row(
      //   children: [
      //     ElevatedButton(onPressed: () {
      //       Navigator.pushNamed(context, './animelist');
      //     }, child: const Text("AnimeList")),
      //     const SizedBox(width: 20,),
      //     ElevatedButton(onPressed: () {
      //       Navigator.pushNamed(context, './mangalist');
      //     }, child: const Text("MangaList"))
      //   ],
      // ),
            ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<dynamic> box, _) {
                final List<dynamic>? animeWatches =
                    box.get("currently-Watching");
                return Animecarousale(carosaleData: animeWatches);
              },
            ),

            const SizedBox(
              height: 5,
            ),

            ValueListenableBuilder(
              valueListenable: box.listenable(), // Listens to Hive box changes
              builder: (context, Box<dynamic> box, _) {
                final List<dynamic>? readsmanga = box.get("currently-Reading");
                return Mangacarousale(carosaleData: readsmanga);
              },
            ),

            // No need for ValueListenableBuilder for static data
            ReusableList(
                name: "Recommend Animes",
                taggName: "recommended",
                data: recomendAnime),
                const SizedBox(height: 20,),
            Mangareusablecarousale(
                name: "Recommend Mangas",
                taggName: "recommended",
                data: recomendManga),
          ],
        ),
      ),
    );
  }
}

