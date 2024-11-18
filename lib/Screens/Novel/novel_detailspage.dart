// ignore_for_file: file_names, prefer_const_constructors

import 'dart:developer';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/Provider/manga_sources.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/components/Novel/novel_alldetails.dart';
import 'package:daizy_tv/components/Novel/novel_chapters.dart';
import 'package:daizy_tv/components/Novel/novel_floater.dart';
import 'package:daizy_tv/utils/helper/jaro_winkler.dart';
import 'package:daizy_tv/utils/scraper/Novel/base/base_class.dart';
import 'package:daizy_tv/utils/scraper/Novel/novel_buddy.dart';
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
  NovelSourceBase? novelSource;
  List<NovelSourceBase>? sources;
  String? currentLink;
  String? currentChapterTitle;
  String? localSource;

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
    final data = await NovelBuddy().scrapeNovelDetails(widget.id);
    if (data != null && data.isNotEmpty) {
      setState(() {
        novelData = data;
        filteredChapterList = data['chapterList'];
        chapterList = data['chapterList'];
        loading = false;
      });
    }
    continueReading();
  }

  Future<void> mappingData() async {
    try {
      final searchData = await searchMostSimilarNovel(
          novelData['title'], novelSource!.scrapeNovelSearchData);
      if (searchData!.isNotEmpty) {
        final chaptersData =
            await novelSource!.scrapeNovelDetails(searchData['id']);
        if (chaptersData != null) {
          setState(() {
            mappedId = searchData['id'];
            filteredChapterList = chaptersData['chapterList'];
            chapterList = chaptersData['chapterList'];
          });
          // wrongTittle.text = novelData['name'];
          // wrongTitleSearch(wrongTittle.text);
        }
        continueReading();
      }
    } catch (e) {
      log("Errors: $e");
    }
  }

  Future<void> continueReading() async {
    try {
      final provider = Provider.of<Data>(context, listen: false);
      final link = provider.getCurrentChapterForNovel(widget.id);
      log(link.toString());
      if (link!.isNotEmpty && link != null) {
        setState(() {
          currentLink = link['currentChapter'];
          currentChapterTitle = link['currentChapterTitle'];
        });
      } else {
        setState(() {
          currentLink = filteredChapterList!.last['id'];
          currentChapterTitle = filteredChapterList!.last['title'];
        });
      }
      log(filteredChapterList!.last['id'] + currentLink.toString());
    } catch (e) {
      log("Error: ${e.toString()}");
    }
  }

  void searchChapter(String number) {
    final list =
        filteredChapterList!.where((chapter) => chapter["title"].contains(number)).toList();
    setState(() {
      chapterList = list;
    });
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
                                  barDecoration: BoxDecoration(
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
          novelData != null &&
                  currentLink != null &&
                  currentChapterTitle != null
              ? NovelFloater(
                  data: novelData,
                  currentLink: currentLink!,
                  currentChapterTitle: currentChapterTitle!,
                  image: widget.image,
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  SizedBox tabs(BuildContext context) {
    final sourceProvider = Provider.of<MangaSourcesProvider>(context,listen: false);
    return SizedBox(
      height: 600,
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        children: [
          NovelAlldetails(novelData: novelData),
          Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: DropdownButtonFormField<String>(
                  value: sourceProvider.novelInstance.sourceName,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Choose Source',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryFixedVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  isDense: true,
                  items: sourceProvider.novelSource
                          ?.map<DropdownMenuItem<String>>((source) {
                        return DropdownMenuItem<String>(
                          value: source.sourceName,
                          child: Text(source.sourceName),
                        );
                      }).toList() ??
                      [],
                  onChanged: (dynamic newValue) {
                    if (newValue.toString().isNotEmpty) {
                      setState(() {
                        localSource = newValue;
                        sourceProvider
                            .setNovelInstance(sourceProvider.novelSource!.firstWhere(
                          (source) => source.sourceName == newValue,
                        ));
                        novelSource = sourceProvider.novelInstance;
                        chapterList = [];
                      });
                      mappingData();
                    }
                  },
                ),
              ),
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
                            chapterList =
                                chapterList?.reversed.toList();
                          });
                        },
                        icon: const Icon(Iconsax.arrow_down)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  onChanged: (String value){
                    searchChapter(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.search_normal),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                      labelText: "Search Chapters",
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(20)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 350,
                child: chapterList != null &&
                        chapterList!.isNotEmpty
                    ? ListView(
                        children: chapterList!.map<Widget>((chapter) {
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
