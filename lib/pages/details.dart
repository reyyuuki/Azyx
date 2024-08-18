import 'dart:convert';
import 'dart:ui';

import 'package:daizy_tv/components/AnimeDetails.dart';
import 'package:daizy_tv/components/Poster.dart';
import 'package:daizy_tv/components/CoverImage.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:text_scroll/text_scroll.dart';

class Details extends StatefulWidget {
  final String id;
  const Details({super.key, required this.id});

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
    if (AnimeData == null || cover == null) {
      return const Center(child: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextScroll(
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
          icon: const Icon(Ionicons.play_back),
        ),
      ),
      body: Stack(
        children: [
          ListView(children: [
            Stack(
              children: [
                CoverImage(imageUrl: cover),
                Expanded(
                  child: Container(
                    height: 1000,
                    margin: const EdgeInsets.only(top: 200),
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40)),
                      color: Color.fromARGB(255, 18, 18, 18),
                    ),
                  ),
                ),
                Poster(imageUrl: AnimeData['info']['poster']),
                AnimeDetails(AnimeData: AnimeData),
              ],
            ),
          ]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              margin: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: TextScroll(
                                AnimeData['info']['name'],
                                mode: TextScrollMode.bouncing,
                                velocity: const Velocity(
                                    pixelsPerSecond: Offset(20, 0)),
                                delayBefore: const Duration(milliseconds: 500),
                                pauseBetween:
                                    const Duration(milliseconds: 1000),
                                textAlign: TextAlign.center,
                                selectable: true,
                              ),
                            ),
                            const Text(
                              'Episode 1',
                              style: TextStyle(
                                  color: Color.fromARGB(187, 141, 135, 135)),
                            ),
                          ],
                        ),
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/stream',
                                  arguments: {"id": AnimeData['info']['id']});
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Ionicons.planet,
                                  color: Colors.white, // Icon color
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Watch',
                                  style: TextStyle(
                                    color: Colors.white, // Text color
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
