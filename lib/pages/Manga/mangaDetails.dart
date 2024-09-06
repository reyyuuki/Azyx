import 'dart:convert';
import 'dart:developer';

import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/components/Manga/mangaAllDetails.dart';
import 'package:daizy_tv/components/Manga/mangaFloater.dart';
import 'package:daizy_tv/components/Manga/chapterList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:text_scroll/text_scroll.dart';

class Mangadetails extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;

  const Mangadetails(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  State<Mangadetails> createState() => _DetailsState();
}

class _DetailsState extends State<Mangadetails> {
  dynamic mangaData;
  List<Map<String, dynamic>>? chapterList;
  List<Map<String, dynamic>>? filteredChapterList; 
  String? value;
  String? cover;
  bool loading = true;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: value);
    fetchData();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://anymey-proxy.vercel.app/cors?url=https://manga-ryan.vercel.app/api/manga/${widget.id}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          mangaData = jsonData;
          chapterList = List<Map<String, dynamic>>.from(jsonData['chapterList']);
          filteredChapterList = chapterList; 
          loading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      log("Failed to load data");
    }
  }

  void handleChapterList(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredChapterList = chapterList; 
      } else {
        filteredChapterList = chapterList?.where((chapter) {
          final chapters = chapter['name']?.toLowerCase() ?? '';
          return chapters.contains(value.toLowerCase());
        }).toList();
      }
    });
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
                  if (mangaData == null)
                    const SizedBox.shrink()
                  else
                    CoverImage(
                      imageUrl: widget.image,
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 220),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(50)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 120,
                          ),
                          Mangaalldetails(
                            mangaData: mangaData,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextField(
                              controller: _controller,
                              onChanged: (value) {
                                handleChapterList(value);
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Iconsax.search_normal),
                                hintText: 'Search Chapters...',
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
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                filled: true,
                              ),
                            ),
                          ),
                          if (filteredChapterList != null)
                            ...filteredChapterList!.map<Widget>((chapter) {
                              return Chapterlist(
                                id: widget.id,
                                chapter: chapter,
                                image: widget.image,
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  Poster(imageUrl: widget.image, id: widget.tagg),
                ],
              ),
            ],
          ),
          mangaData != null
              ? Mangafloater(
                  chapterList: chapterList!,
                  id: widget.id,
                  image: widget.image,
                  title: mangaData['name'],
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
