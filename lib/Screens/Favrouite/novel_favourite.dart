// ignore_for_file: file_names, prefer_const_constructors

import 'dart:developer';

import 'package:azyx/Hive_Data/appDatabase.dart';
import 'package:azyx/components/Anime/poster.dart';
import 'package:azyx/components/Anime/coverImage.dart';
import 'package:azyx/components/Novel/novel_chapters.dart';
import 'package:azyx/components/Novel/novel_floater.dart';
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class NovelFavouritePage extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;

  const NovelFavouritePage(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  State<NovelFavouritePage> createState() => _DetailsState();
}

class _DetailsState extends State<NovelFavouritePage> {
  dynamic wrongTitleSearchData;
  String? mappedId;
  List<Map<String, dynamic>>? chapterList;
  dynamic filteredChapterList;
  String? value;
  String? cover;
  bool loading = true;
  TextEditingController? _controller;
  late String searchTerm;
  ExtractClass? mangaScarapper;
  String? currentLink;
  late String currentChapter;
  Map<String, dynamic>? novelData;

  @override
  void initState() {
    super.initState();
    loadData();
    continueReading();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final provider = Provider.of<Data>(context, listen: false);
    if (provider.favoriteNovel != null) {
      setState(() {
        novelData = provider.getFavouriteNovelById(widget.id);
        filteredChapterList = List<Map<String, dynamic>>.from(
          novelData!['chapterList'].map((item) {
            return Map<String, dynamic>.from(item);
          }),
        );
        chapterList = List<Map<String, dynamic>>.from(filteredChapterList!);
      });
    }
    continueReading();
  }

  void searchChapter(String number) {
    final list = filteredChapterList
        .where((chapter) =>
            (chapter as Map<String, dynamic>)['title'].contains(number) ||
            chapter['index'].toString() == number)
        .toList();
    setState(() {
      chapterList = list;
    });
  }

  Future<void> continueReading() async {
    try {
      final provider = Provider.of<Data>(context, listen: false);
      final link = provider.getCurrentChapterForManga(widget.id);
      if (link != null && link['currentChapterTitle'] != null) {
        setState(() {
          currentLink = link['currentChapter'];
          currentChapter = link['currentChapterTitle'];
        });
      } else {
        setState(() {
          currentLink = filteredChapterList!.last['id'];
          currentChapter = filteredChapterList!.last['title'];
        });
      }
      log(currentLink ?? "No link available");
    } catch (e) {
      log("Error: ${e.toString()}");
      setState(() {
        currentLink = filteredChapterList?.last['id'];
        currentChapter = filteredChapterList?.last['title'];
      });
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextScroll(
          novelData!['title'].isEmpty ? "Loading..." : novelData!['title'],
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
          delayBefore: const Duration(milliseconds: 500),
          pauseBetween: const Duration(milliseconds: 1000),
          textAlign: TextAlign.center,
          selectable: true,
          style: const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
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
            physics: const BouncingScrollPhysics(),
            children: [
              Stack(
                children: [
                  if (novelData == null)
                    const SizedBox.shrink()
                  else
                    CoverImage(
                      imageUrl: novelData!['image'] ?? widget.image,
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Container(
                      margin: EdgeInsets.only(top: 370),
                      child: Column(
                        children: [
                          Text(
                            novelData!['description'].length > 150
                                ? '${novelData!['description'].substring(0, 150)}...'
                                : novelData!['description'],
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextField(
                            onChanged: (String value) {
                              searchChapter(value);
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(Iconsax.search_normal),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                labelText: "Search Chapters",
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    borderRadius: BorderRadius.circular(20)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Poster(imageUrl: widget.image, id: widget.tagg),
                ],
              ),
              SizedBox(
                height: 485,
                child: novelData!['chapterList'] != null
                    ? ListView(
                        physics: const BouncingScrollPhysics(),
                        children: chapterList!.map<Widget>((chapter) {
                          return NovelChapters(
                            id: widget.id,
                            chapter: chapter,
                            image: widget.image,
                            title: novelData!['title'],
                          );
                        }).toList(),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 60,)
            ],
          ),
          novelData != null
              ? NovelFloater(
                  data: novelData!,
                  currentLink: novelData!['currentLink'],
                  currentChapterTitle: currentChapter,
                  image: widget.image,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
