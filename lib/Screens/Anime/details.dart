import 'dart:convert';
import 'dart:developer';

import 'package:daizy_tv/components/Anime/animeDetails.dart';
import 'package:daizy_tv/components/Anime/floater.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/utils/scraper/Anilist/anilist_anime_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:text_scroll/text_scroll.dart';

class Details extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;
  const Details({super.key, required this.id,required this.image, required this.tagg});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  dynamic animeData;
  String? cover;
  String? description;

  @override
  void initState() {
    super.initState();
    fetchData();
    scrapedData();
  }

Future<void> scrapedData() async {
  try {
    final data = await fetchAnilistAnimeDetails(widget.id);

    if (data.isNotEmpty) {
      setState(() {
        animeData = data; 
        log(animeData['episodes']);
      });
      
    } else {
      log("Error: Unexpected data type from scrapDetail");
    }
  } catch (error) {
    log("Error in scrapedData: $error");
  }
}

 
  Future<void> fetchData() async {
    String aniwatchUrl = dotenv.get("HIANIME_URL");
    String consumetUrl = dotenv.get("CONSUMET_URL");
    String proxy = "https://goodproxy.goodproxy.workers.dev/fetch?url=";
    try {
      final response = await http.get(Uri.parse(
          '$proxy${aniwatchUrl}anime/info?id=${widget.id}'));
          log('$proxy${aniwatchUrl}anime/info?id=${widget.id}');
          
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newResponse = await http.get(Uri.parse(
            '$proxy${consumetUrl}meta/anilist/info/${jsonData['anime']['info']['anilistId']}'));

          log('$proxy${consumetUrl}meta/anilist/info/${jsonData['anime']['info']['anilistId']}');
        if (newResponse.statusCode == 200) {
          final newData = jsonDecode(newResponse.body);
          setState(() {
            // animeData = jsonData['anime'];
            log("data anilist : ${jsonData['anime']['info']['anilistId']}");
            cover = newData['cover'];
            description = newData['description'];
          });
        }
      }
    } catch (error) {
      log("Failed to load data : $error");
    }
  }

  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 0,
        title: TextScroll(
          animeData == null ? "Loading..." :
          animeData['name'].toString(),
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
          delayBefore: const Duration(milliseconds: 500),
          pauseBetween: const Duration(milliseconds: 1000),
          textAlign: TextAlign.center,
          selectable: true,
          style: const TextStyle(fontSize: 18,fontFamily: "Poppins-Bold"),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        children: [
          ListView(children: [
            Stack(
              children: [
               animeData?['poster'] != null ? CoverImage(imageUrl: animeData['coverImage']) : const SizedBox.shrink(),
                Container(
                  height: 870,
                  margin: const EdgeInsets.only(top: 220),
                  decoration:  BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(50)),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                ),
                Poster(imageUrl: widget.image, id : widget.tagg),
                AnimeDetails(animeData: animeData, id: widget.id,),
              ],
            ),
          ]),
        ],
      ),
    );
  }

}

