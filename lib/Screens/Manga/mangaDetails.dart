// ignore_for_file: file_names

import 'dart:developer';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/Provider/manga_sources.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/components/Manga/mangaAllDetails.dart';
import 'package:daizy_tv/components/Manga/chapterList.dart';
import 'package:daizy_tv/utils/api/Anilist/Manga/manga_details_anilist.dart';
import 'package:daizy_tv/utils/helper/jaro_winkler.dart';
import 'package:daizy_tv/utils/scraper/Anilist/anilist_add.dart';
import 'package:daizy_tv/utils/scraper/Manga/Manga_Sources/extract_class.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
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
  String? mappedId;
  List<Map<String, dynamic>>? chapterList;
  List<Map<String, dynamic>>? filteredChapterList;
  String? value;
  String? cover;
  bool loading = true;
  TextEditingController? _controller;
  ExtractClass? mangaScarapper;
  List<ExtractClass>? sources;

  String localSource = "MangaKakalot Unofficial";
  String localSelectedValue = "CURRENT";
  String defaultScore = "1.0";
  final TextEditingController _episodeController =
      TextEditingController(text: '1');

  final List<String> _items = [
    "CURRENT",
    "PLANNING",
    "COMPLETED",
    "REPEATING",
    "PAUSED",
    "DROPPED"
  ];

  final List<String> _scoresItems = [
    "0.5",
    "1.0",
    "1.5",
    "2.0",
    "2.5",
    "3.0",
    "3.5",
    "4.0",
    "4.5",
    "5.5",
    "6.0",
    "6.5",
    "7.0",
    "7.5",
    "8.0",
    "8.5",
    "9.0",
    "10.0"
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: value);
    scrap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> test() async {
    try {
      final searchData = await searchMostSimilarManga(
          mangaData['name'], mangaScarapper!.fetchSearchsManga);
      log("name: ${searchData.toString()}");
      if (searchData!.isNotEmpty) {
        final chaptersData =
            await mangaScarapper!.fetchChapters(searchData['id']);
        if (chaptersData != null) {
          setState(() {
            mappedId = searchData['id'];
            filteredChapterList = chaptersData['chapterList'];
          });
          log(mappedId!);
        }
      }
    } catch (e) {
      log("Errors: $e");
    }
  }

  Future<void> scrap() async {
    final data = await getMangaDetails(widget.id);
    final provider = Provider.of<MangaSourcesProvider>(context, listen: false);
    mangaScarapper = provider.instance;
    log("perfect: ${mangaScarapper.toString()}");

    if (data != null) {
      setState(() {
        mangaData = data;
        loading = false;
      });
      test();
    }
  }

  @override
  Widget build(context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);
    final provider = Provider.of<AniListProvider>(context, listen: false)
        .userData['mangaList'];
    final manga = provider?.firstWhere(
        (manga) => widget.id == manga['media']['id'].toString(),
        orElse: () => null);
    log(provider.toString());

    localSelectedValue = manga?['status'] ?? "CURRENT";
    String getMangaStatus(dynamic manga) {
      switch (manga['status']) {
        case 'CURRENT':
          return "Currently Reading";
        case 'COMPLETED':
          return "Completed";
        case 'PAUSED':
          return "Paused";
        case 'DROPPED':
          return "Dropped";
        case 'PLANNING':
          return "Planning to Read";
        case 'REPEATING':
          return "Repeating";
          default:
          return "Unkown";
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextScroll(
          loading ? "Loading..." : mangaData['name'].toString(),
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
                  if (mangaData == null)
                    const SizedBox.shrink()
                  else
                    CoverImage(
                      imageUrl: mangaData['coverImage'] ?? widget.image,
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
                        GestureDetector(
                          onTap: () {
                            if (Provider.of<AniListProvider>(context,
                                        listen: false)
                                    .userData['name'] ==
                                null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Whoa there! 🛑 You’re not logged in! Let’s fix that 😜",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                      )),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              if (filteredChapterList == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text(
                                        '🍿 Hold tight! like a ninja... 🥷',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "Poppins-Bold",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface,
                                        ),
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                addToList(context);
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 65,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  border: Border(
                                      bottom: BorderSide(
                                          color: const Color.fromARGB(
                                                  255, 71, 70, 70)
                                              .withOpacity(0.8))),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright),
                                  child: manga != null
                                      ? Center(
                                          child: Text(
                                          getMangaStatus(manga),
                                          style: const TextStyle(
                                              fontFamily: "Poppins-Bold",
                                              fontSize: 16),
                                        ))
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Iconsax.add),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Add to list",
                                              style: TextStyle(
                                                fontFamily: "Poppins-Bold",
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
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
                                  barDecoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10))),
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
        ],
      ),
    );
  }

  SizedBox tabs(BuildContext context) {
    final sourceProvider =
        Provider.of<MangaSourcesProvider>(context, listen: false);
    log('source: ${mangaScarapper.toString()}');
    sourceProvider.allMangaSources;
    return SizedBox(
      height: 700,
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        children: [
          Mangaalldetails(mangaData: mangaData),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: DropdownButtonFormField<String>(
                  value: sourceProvider.instance.sourceName,
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
                  items: sourceProvider.sources
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
                            .setInstance(sourceProvider.sources!.firstWhere(
                          (source) => source.sourceName == newValue,
                        ));
                        mangaScarapper = sourceProvider.instance;
                        filteredChapterList = [];
                        test();
                      });
                    }
                  },
                ),
              ),
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
              SizedBox(
                height: 545,
                child: filteredChapterList != null &&
                        filteredChapterList!.isNotEmpty
                    ? ListView(
                        children: filteredChapterList!.map<Widget>((chapter) {
                          return Chapterlist(
                            id: mappedId,
                            chapter: chapter,
                            image: widget.image,
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

  void addToList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 1),
              child: SizedBox(
                height: 600,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(30)),
                              child: CachedNetworkImage(
                                imageUrl: mangaData['coverImage'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 25,
                            child: SizedBox(
                              width: 85,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 55,
                            left: 130,
                            child: Text(
                              mangaData['name'].length > 20
                                  ? '${mangaData['name'].substring(0, 20)}...'
                                  : mangaData['name'],
                              style: const TextStyle(
                                fontFamily: "Poppins-Bold",
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: localSelectedValue,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Choose Status',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryFixedVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            isDense: true,
                            items: _items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  localSelectedValue = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          DropdownButtonFormField<String>(
                            value: defaultScore,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Choose Score',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryFixedVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            isDense: true,
                            items: _scoresItems
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  defaultScore = newValue;
                                });
                              }
                            },
                          ),
                          inputbox(context,
                              _episodeController, filteredChapterList!.length),
                          const SizedBox(height: 30),
                          saveAnime(localSelectedValue, context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Column inputbox(BuildContext context, _controller, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 57,
          child: TextField(
            expands: true,
            maxLines: null,
            controller: _controller,
            onChanged: (value) {
              if (value.isNotEmpty) {
                int number = int.tryParse(value) ?? 0;
                if (number > max) {
                  _controller.value = TextEditingValue(
                    text: max.toString(),
                  );
                } else if (number < 0) {
                  _controller.value = const TextEditingValue(
                    text: '0',
                  );
                }
              }
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '/ $max',
                  style:
                      const TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
                ),
              ),
              labelText: "Chapter Progress",
              filled: true,
              isDense: true,
              fillColor: Theme.of(context).colorScheme.surface,
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        )
      ],
    );
  }

  GestureDetector saveAnime(String localSelectedValue, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<AniListProvider>(context, listen: false).addToAniList(
          mediaId: int.parse(widget.id),
          status: localSelectedValue,
          score: double.tryParse(defaultScore),
          progress: int.parse(_episodeController.text),
        );
        Navigator.pop(context);
      },
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Save",
            style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
          ),
        ),
      ),
    );
  }
}
