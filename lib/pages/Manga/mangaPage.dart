import 'dart:convert';
import 'dart:developer';

import 'package:daizy_tv/backupData/manga.dart';
import 'package:daizy_tv/components/Manga/mangaCarousale.dart';
import 'package:daizy_tv/components/Manga/mangaReusableCarousale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:daizy_tv/components/Header.dart';
import 'package:iconsax/iconsax.dart';


class Mangapage extends StatefulWidget {
  const Mangapage({super.key});

  @override
  State<Mangapage> createState() => _HomepageState();
}

class _HomepageState extends State<Mangapage> {
    dynamic manga_Data;
    dynamic mangaList1;
    dynamic mangaList2;
    dynamic mangaList3;

  @override
  void initState() {
    super.initState();
    backUpData();
    fetchData();
  }

  void backUpData() {
    manga_Data = mangaData['mangaList'];
    mangaList1 = manga_Data!.sublist(0, 8);
    mangaList2 = manga_Data!.sublist(8, 16);
    mangaList3 = manga_Data!.sublist(16, 24);
  }



  Future<void> fetchData() async {
     String url =
        'https://anymey-proxy.vercel.app/cors?url=${dotenv.get("KAKALOT_URL")}api/mangalist';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          manga_Data = data['mangaList'];
          if (manga_Data != null && manga_Data!.length == 24) {
            mangaList1 = manga_Data!.sublist(0, 8);
            mangaList2 = manga_Data!.sublist(8, 16);
            mangaList3 = manga_Data!.sublist(16, 24);
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
    if(mangaData == null){
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Header(name: "Manga",),
            const SizedBox(
              height: 20,
            ),
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
                      focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      filled: true,
                      ),
                ),
             ),
           ),
            const SizedBox(
              height: 30.0,
            ),
            Mangacarousale(
              mangaData: manga_Data,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Mangareusablecarousale(name: 'Popular', data: mangaList1, taggName: "Carosale1",),
            const SizedBox(
              height: 10,
            ),
            Mangareusablecarousale(name: 'Latest Manga', data: mangaList2, taggName: "Carosale2"),
            const SizedBox(
              height: 10,
            ),
            Mangareusablecarousale(name: 'Trending Mnaga', data: mangaList3, taggName: "Carosale3"),
          ],
        ),
      ),
    );
  }
}
