// ignore_for_file: file_names, prefer_const_constructors

import 'dart:developer';

import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/components/Common/check_platform.dart';
import 'package:daizy_tv/components/Desktop/Manga/desktop_chapter_list.dart';
import 'package:daizy_tv/components/Manga/chapterList.dart';
import 'package:daizy_tv/components/Manga/mangaFloater.dart';
import 'package:daizy_tv/utils/sources/Manga/Base/extract_class.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class MangaFavouritePage extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;

  const MangaFavouritePage(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  State<MangaFavouritePage> createState() => _DetailsState();
}

class _DetailsState extends State<MangaFavouritePage> {
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
  Map<String, dynamic>? mangaData;

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
    if (provider.favoriteManga != null) {
      setState(() {
        mangaData = provider.getFavoriteMangaById(widget.id);
        filteredChapterList = List<Map<String, dynamic>>.from(
          mangaData!['chapterList'].map((item) {
            return Map<String, dynamic>.from(item);
          }),
        );
        chapterList = List<Map<String, dynamic>>.from(filteredChapterList!);
      });
    }
    continueReading();
  }

  Future<void> continueReading() async {
    try {
      final progress = Provider.of<AniListProvider>(context, listen: false)
          .userData['mangaList'];
      final manga = progress?.firstWhere(
          (manga) => widget.id == manga['media']['id'].toString(),
          orElse: () => null);
      final index = manga != null
          ? filteredChapterList!.firstWhere((chapter) =>
              chapter['id'].toString().contains(manga['progress'].toString()))
          : null;
      final provider = Provider.of<Data>(context, listen: false);
      final link = provider.getCurrentChapterForManga(widget.id);
      if (link != null && link['currentChapterTitle'] != null) {
        setState(() {
          currentLink = link['currentChapter'];
          currentChapter = link['currentChapterTitle'];
        });
      } else {
        setState(() {
          currentLink = progress != null
              ? index['link']
              : filteredChapterList!.last['link'];
          currentChapter = progress != null
              ? index['title']
              : filteredChapterList!.last['title'];
        });
      }
      log(currentLink ?? "No link available");
    } catch (e) {
      log("Error: ${e.toString()}");
      setState(() {
        currentLink = filteredChapterList?.last['link'];
        currentChapter = filteredChapterList?.last['title'];
      });
    }
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

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextScroll(
          mangaData!['title'].isEmpty ? "Loading..." : mangaData!['title'],
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
                  if (mangaData == null)
                    const SizedBox.shrink()
                  else
                    CoverImage(
                      imageUrl: mangaData!['image'] ?? widget.image,
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Container(
                      margin: EdgeInsets.only(top: 370),
                      child: Column(
                        children: [
                          Text(
                            mangaData!['description'].length > 150
                                ? '${mangaData!['description'].substring(0, 150)}...'
                                : mangaData!['description'],
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
                child: mangaData!['chapterList'] != null
                    ? PlatformWidget(
                        androidWidget: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: chapterList!.map<Widget>((chapter) {
                            return Chapterlist(
                              id: widget.id,
                              chapter: chapter,
                              image: widget.image,
                            );
                          }).toList(),
                        ),
                        windowsWidget: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: chapterList!.map<Widget>((chapter) {
                            return DesktopChapterList(
                              id: widget.id,
                              chapter: chapter,
                              image: widget.image,
                            );
                          }).toList(),
                        ))
                    : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 60,)
            ],
          ),
          mangaData != null
              ? Mangafloater(
                  data: mangaData!,
                  currentLink: mangaData!['currentLink'],
                  chapterList: filteredChapterList!,
                  currentChapter: currentChapter,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
