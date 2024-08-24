import 'dart:convert';

import 'package:daizy_tv/components/Anime/animeDetails.dart';
import 'package:daizy_tv/components/Anime/floater.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:text_scroll/text_scroll.dart';

class Details extends StatefulWidget {
  final String id;
  final String image;
  const Details({super.key, required this.id,required this.image});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  dynamic AnimeData;
  String? cover;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://aniwatch-ryan.vercel.app/anime/info?id=${widget.id}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newResponse = await http.get(Uri.parse(
            'https://consumet-api-two-nu.vercel.app/meta/anilist/info/${jsonData['anime']['info']['anilistId']}'));

        if (newResponse.statusCode == 200) {
          final newData = jsonDecode(newResponse.body);
          setState(() {
            AnimeData = jsonData['anime'];
            cover = newData['cover'];
          });
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      // ignore: avoid_print
      print("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextScroll(
          AnimeData == null ? "Loading" :
          AnimeData['info']['name'].toString(),
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
          delayBefore: const Duration(milliseconds: 500),
          pauseBetween: const Duration(milliseconds: 1000),
          textAlign: TextAlign.center,
          selectable: true,
          style: const TextStyle(fontSize: 18),
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
                CoverImage(imageUrl: cover),
                Container(
                  height: 870,
                  margin: const EdgeInsets.only(top: 220),
                  decoration:  BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(50)),
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Poster(imageUrl: widget.image, id : widget.id),
                AnimeDetails(AnimeData: AnimeData),
              ],
            ),
          ]),
          Floater(AnimeData: AnimeData,),
        ],
      ),
    );
  }

}