import 'dart:convert';

import 'package:daizy_tv/components/Anime/Poster.dart';
import 'package:daizy_tv/components/Anime/CoverImage.dart';
import 'package:daizy_tv/components/Manga/MangaAllDetails.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:text_scroll/text_scroll.dart';

class Mangadetails extends StatefulWidget {
  final String id;
  final String image;

  const Mangadetails({super.key, required this.id, required this.image});

  @override
  State<Mangadetails> createState() => _DetailsState();
}

class _DetailsState extends State<Mangadetails> {
  dynamic mangaData;
  String? cover;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://anymey-proxy.vercel.app/cors?url=https://manga-ryan.vercel.app/api/manga/${widget.id}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          mangaData = jsonData;
          loading = false;
        });
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
          loading ? "Loading" : mangaData['name'].toString(),
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
          icon: const Icon(Ionicons.play_back),
        ),
      ),
      body: Stack(
        children: [
          ListView(children: [
            Stack(
              children: [
                if (loading)
                  Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  CoverImage(imageUrl: mangaData['imageUrl']),
                Expanded(
                  child: Container(
                    height: 870,
                    margin: const EdgeInsets.only(top: 220),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(50)),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                Poster(imageUrl: widget.image, id: widget.id),
                Mangaalldetails(mangaData: mangaData,)
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
