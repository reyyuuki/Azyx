import 'dart:convert';

import 'package:daizy_tv/components/Anime/Poster.dart';
import 'package:daizy_tv/components/Anime/CoverImage.dart';
import 'package:daizy_tv/components/Manga/MangaAllDetails.dart';
import 'package:daizy_tv/components/Manga/MangaFloater.dart';
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
        body: ListView(
          children: [
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    CoverImage(
                      imageUrl: widget.image,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 220),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(50)),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                              ),
                              Mangaalldetails(
                                mangaData: mangaData,
                              ),
                              if (mangaData != null)
                                ...mangaData['chapterList']
                                    .map<Widget>((chapter) => ChapterList(context, chapter))
                                    .toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Poster(imageUrl: widget.image, id: widget.id),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  GestureDetector ChapterList(BuildContext context, chapter) {
    return GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/read',
                                          arguments: {"mangaId" : widget.id , "chapterId": chapter['id']}
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Container(
                                            height: 55,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TextScroll(
                                                    chapter['name'],
                                                    mode: TextScrollMode
                                                        .bouncing,
                                                    velocity: const Velocity(
                                                        pixelsPerSecond:
                                                            Offset(30, 0)),
                                                    delayBefore:
                                                        const Duration(
                                                            milliseconds:
                                                                500),
                                                    pauseBetween:
                                                        const Duration(
                                                            milliseconds:
                                                                1000),
                                                    textAlign:
                                                        TextAlign.center,
                                                    selectable: true,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Ionicons.eye,
                                                        size: 16,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        chapter['view'],
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    8),
                                                        child: Center(
                                                            child: Row(
                                                          children: [
                                                            Icon(
                                                              Ionicons.book,
                                                              size: 16,
                                                            ),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text('Read'),
                                                          ],
                                                        )),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
  }
}
