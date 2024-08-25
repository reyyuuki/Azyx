import 'dart:convert';

import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/components/Manga/mangaAllDetails.dart';
import 'package:daizy_tv/components/Manga/mangaFloater.dart';
import 'package:daizy_tv/components/Manga/chapterList.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 0,
          title: TextScroll(
            loading ? "Loading..." : mangaData['name'].toString(),
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
            ListView(
              children: [
                Stack(
                  children: [
                    if(mangaData == null)
                    const SizedBox.shrink()
                    else
                    CoverImage(
                      imageUrl: widget.image,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 220),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(50)),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 120,
                          ),
                          Mangaalldetails(
                            mangaData: mangaData,
                          ),
                          if (mangaData != null)
                            ...mangaData['chapterList']
                                .map<Widget>((chapter) => Chapterlist(id: widget.id, chapter: chapter,))
                                .toList(),
                        ],
                      ),
                    ),
                    Poster(imageUrl: widget.image, id: widget.id),
                  ],
                ),
              ],
            ),
            Mangafloater(mangaData: mangaData, id: widget.id,),
          ],
        ));
  }

  
}
