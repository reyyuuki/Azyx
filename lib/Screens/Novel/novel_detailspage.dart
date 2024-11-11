// ignore_for_file: file_names, prefer_const_constructors

import 'dart:developer';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/components/Novel/novel_alldetails.dart';
import 'package:daizy_tv/components/Novel/novel_chapters.dart';
import 'package:daizy_tv/components/Novel/novel_floater.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Extenstions/extract_class.dart';
import 'package:daizy_tv/utils/scraper/Novel/wuxia_novel.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class Noveldetails extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;

  const Noveldetails(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  State<Noveldetails> createState() => _DetailsState();
}

class _DetailsState extends State<Noveldetails> {
  dynamic novelData;
  dynamic wrongTitleSearchData;
  String? mappedId;
  List<Map<String, dynamic>>? chapterList;
  List<Map<String, dynamic>>? filteredChapterList;
  String? value;
  String? cover;
  bool loading = true;
  TextEditingController? _controller;
  late String searchTerm;
  ExtractClass? mangaScarapper;
  List<ExtractClass>? sources;
  String? currentLink;

  @override
  void initState() {
    super.initState();
    scrap();
    log(widget.id);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }


  Future<void> scrap() async {
    final data = await scrapeNovelDetails(widget.id);
    if (data != null) {
      setState(() {
        novelData = data;
        filteredChapterList = data['chapterList'];
        loading = false;
      });
      // log(data.toString());
    }
    continueReading();
  }

  Future<void> continueReading() async {
    try {
      final provider = Provider.of<Data>(context, listen: false);
      final link = provider.getCurrentChapterForNovel(widget.id);
      if (link != null) {
        setState(() {
          currentLink = link;
        });
      } else {
        setState(() {
          currentLink = filteredChapterList!.first['id'];
        });
      }
      log(currentLink ?? "No link available");
    } catch (e) {
      log("Error: ${e.toString()}");
    }
  }


  @override
  Widget build(context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);

    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextScroll(
          loading ? "Loading..." : novelData['title'].toString(),
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
            children: [
              Stack(
                children: [
                  if (novelData == null)
                    const SizedBox.shrink()
                  else
                    CoverImage(
                      imageUrl: novelData['image'] ?? widget.image,
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 220),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(50)),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 150,
                        ),
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: SegmentedTabControl(
                                  height: 60,
                                  barDecoration:  BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  selectedTabTextColor: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  tabTextColor: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  indicatorPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  squeezeIntensity: 2,
                                  textStyle: textStyle,
                                  selectedTextStyle: selectedTextStyle,
                                  indicatorDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  tabs: [
                                    SegmentTab(
                                      label: 'Details',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainer,
                                    ),
                                    SegmentTab(
                                        label: 'Read',
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainer,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              tabs(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Poster(imageUrl: widget.image, id: widget.tagg),
                ],
              ),
            ],
          ),
         novelData != null  && currentLink != null ? NovelFloater(data: novelData, currentLink: currentLink!) : const SizedBox.shrink()
        ],
      ),
    );
  }

  SizedBox tabs(BuildContext context) {
    
    return SizedBox(
      height: 700,
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        children: [
          NovelAlldetails(novelData: novelData),
          Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chapters",
                      style:
                          TextStyle(fontFamily: "Poppins-Bold", fontSize: 22),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            filteredChapterList =
                                filteredChapterList?.reversed.toList();
                          });
                        },
                        icon: const Icon(Iconsax.refresh)),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.pushNamed(context, '/read', arguments: {
              //         "mangaId": widget.id,
              //         "chapterLink": currentLink,
              //         "image": widget.image,
              //       });
              //     },
              //     child: Text("Continue")),
              // const SizedBox(
              //   height: 10,
              // ),
              SizedBox(
                height: 580,
                child: filteredChapterList != null &&
                        filteredChapterList!.isNotEmpty
                    ? ListView(
                        children: filteredChapterList!.map<Widget>((chapter) {
                          return NovelChapters(
                            id: widget.id,
                            chapter: chapter,
                            image: widget.image,
                            title: novelData['title'],
                          );
                        }).toList(),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
