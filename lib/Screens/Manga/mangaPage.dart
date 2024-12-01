import 'dart:convert';
import 'dart:developer';

import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/backupData/anilist_manga.dart';
import 'package:azyx/components/Anime/anime_carousale.dart';
import 'package:azyx/components/Anime/reusableList.dart';
import 'package:azyx/components/Common/check_platform.dart';
import 'package:azyx/components/Desktop/anime/desktop_carousale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:azyx/components/Common/Header.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Mangapage extends StatefulWidget {
  const Mangapage({super.key});

  @override
  State<Mangapage> createState() => _MangapageState();
}

class _MangapageState extends State<Mangapage> {
  dynamic mangaData;
  dynamic trendingManga;
  dynamic latestManga;
  dynamic topOngoing;

  @override
  void initState() {
    super.initState();
    backUpData();
  }

  void backUpData() {
    setState(() {
    mangaData = fallbackMangaData['data']['popularMangas']['media'];
    trendingManga = fallbackMangaData['data']['trendingManga']['media'];
    latestManga = fallbackMangaData['data']['latestMangas']['media'];
    topOngoing = fallbackMangaData['data']['topOngoing']['media'];
    });
    
  }

  Future<void> fetchData() async {
    String url =
        'https://anymey-proxy.vercel.app/cors?url=${dotenv.get("KAKALOT_URL")}api/mangalist';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mangaData = data['mangaList'];
          if (mangaData != null && mangaData!.length == 24) {
            trendingManga = mangaData!.sublist(0, 8);
            latestManga = mangaData!.sublist(8, 16);
            topOngoing = mangaData!.sublist(16, 24);
          } else {
            throw Exception('Data is not found');
          }
        });
      } else {
        throw Exception('Manga data is not available');
      }
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
         Consumer<AniListProvider>(
          builder: (context, provider, child) {
            mangaData = provider.mangalistData['popular'] ?? mangaData;
            trendingManga = trendingManga;
            latestManga =  provider.mangalistData['trending'];
            topOngoing =  topOngoing;

           return  ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const Header(name: "Manga"),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      onSubmitted: (String value) {
                        Navigator.pushNamed(
                          context,
                          '/searchManga',
                          arguments: {"name": value},
                        );
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.search_normal),
                        hintText: 'Search Manga',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
                PlatformWidget(androidWidget: AnimeCarousale(animeData: trendingManga, route: '/mangaDetail',name: "Read",),
                 windowsWidget: DesktopCarousale(animeData: trendingManga, route: '/mangaDetail',name: "Read",),
                ),
                const SizedBox(height: 30.0),
                ReusableList(
                  name: 'Popular',
                  data: mangaData,
                  taggName: "Carosale1",
                  route: '/mangaDetail',
                ),
                const SizedBox(height: 10),
                ReusableList(
                  name: 'Latest Manga',
                  data: latestManga,
                  taggName: "Carosale2",
                  route: '/mangaDetail',
                ),
                const SizedBox(height: 10),
                ReusableList(
                  name: 'Trending Manga',
                  data: topOngoing,
                  taggName: "Carosale3",
                  route: '/mangaDetail',
                ),
              ],
            );
          }
         )
      ),
    );
  }
}
