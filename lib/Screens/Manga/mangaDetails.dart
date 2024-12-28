// ignore_for_file: file_names, prefer_const_constructors

import 'dart:developer';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:azyx/api/Mangayomi/Extensions/extensions_provider.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/get_detail.dart';
import 'package:azyx/api/Mangayomi/Search/get_pages_list.dart';
import 'package:azyx/api/Mangayomi/Search/search.dart';
import 'package:azyx/components/Common/_palceholder.dart';
import 'package:azyx/utils/helper/jaro_winkler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Hive_Data/appDatabase.dart';
import 'package:azyx/Provider/sources_provider.dart';
import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/components/Anime/poster.dart';
import 'package:azyx/components/Anime/coverImage.dart';
import 'package:azyx/components/Manga/mangaAllDetails.dart';
import 'package:azyx/components/Manga/chapterList.dart';
import 'package:azyx/utils/api/Anilist/Manga/manga_details_anilist.dart';
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:azyx/utils/sources/Manga/SourceHandler/sourcehandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as r;
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class Mangadetails extends r.ConsumerStatefulWidget {
  final String id;
  final String image;
  final String tagg;

  const Mangadetails(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  r.ConsumerState<Mangadetails> createState() => _DetailsState();
}

class _DetailsState extends r.ConsumerState<Mangadetails> {
  dynamic mangaData;
  dynamic wrongTitleSearchData;
  String? mappedId;
  List<Map<String, dynamic>>? chapterList;
  List<Map<String, dynamic>>? filteredChapterList;
  dynamic mangaAllDetails;
  String? value;
  String? cover;
  bool loading = true;
  TextEditingController? _controller;
  late String searchTerm;
  ExtractClass? mangaScarapper;
  List<ExtractClass>? sources;
  late MangaSourcehandler sourcehandler;
  List<Map<String, String>> mangaSources = [];
  String selectedSource = '';
  String? currentLink;
  late String currentChapter;

  String localSource = "MangaKakalot Unofficial";
  String localSelectedValue = "CURRENT";
  String defaultScore = "1.0";
  final TextEditingController _chapterController =
      TextEditingController(text: '1');
  TextEditingController wrongTittle = TextEditingController();
  List<Source>? installedExtensions;
  Source? currentSource;

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
    sourcehandler =
        Provider.of<SourcesProvider>(context, listen: false).getMangaInstance();
    mangaSources = sourcehandler.getAvailableSources();
    selectedSource = sourcehandler.selectedSource;
    scrap();
    _initExtenstions();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> mappingData(Source? source) async {
    final activeSource = source ?? currentSource;
    try {
      final chaptersData = await search(
          source: activeSource!,
          query: mangaData['name'],
          page: 1,
          filterList: []);
      if (chaptersData != null) {
        final mappedData = await mappingHelper(
          mangaData['name'],
          chaptersData.toJson()['list'],
        );
        if (mappedData != null && mappedData.isNotEmpty) {
          final episodesList = await getDetail(
            url: mappedData['link'],
            source: activeSource,
          );
          setState(() {
            filteredChapterList = episodesList.toJson()['chapters'];
            chapterList = filteredChapterList;
            mangaAllDetails = episodesList.toJson();
          });
          log("List: ${episodesList.toJson()}");
        }
        wrongTittle.text = mangaData['name'];
      }
      // continueReading();
    } catch (e) {
      log("Errors: $e");
    }
  }

  Future<void> _initExtenstions() async {
    final container = r.ProviderContainer();
    final extensions =
        await container.read(getExtensionsStreamProvider(true).future);

    installedExtensions =
        extensions.where((source) => source.isAdded!).toList();
    if (installedExtensions!.isNotEmpty) {
      currentSource = installedExtensions?.first ?? Source();
    }
  }

  Future<void> wrongTitleSearch(String name, context) async {
    try {
      wrongTittle.text = name;
      final response = await search(
          source: currentSource!, query: name, page: 1, filterList: []);
      if (response.toString().isNotEmpty) {
        setState(() {
          wrongTitleSearchData = response!.toJson()['list'];
        });
        Navigator.pop(context);
        wrongTitle(context);
      }
      log(wrongTitleSearchData);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> changeChapterData(String url) async {
    chapterList = [];
    final response = await getDetail(url: url, source: currentSource!);
    if (response != null) {
      setState(() {
        filteredChapterList = response.toJson()['chapters'];
        chapterList = filteredChapterList;
      });
    } else {
      log('not scrapped');
    }
  }

  void searchChapter(String number) {
    final list = filteredChapterList!
        .where((chapter) => chapter['title'].contains(number))
        .toList();
    setState(() {
      chapterList = list;
    });
  }

  Future<void> scrap() async {
    final data = await getMangaDetails(widget.id);
    if (data != null) {
      setState(() {
        mangaData = data;
        loading = false;
      });
      if (installedExtensions != null && installedExtensions!.isNotEmpty) {
        mappingData(installedExtensions!.first);
      }
    }
  }

  void showBottomLoader() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        enableDrag: true,
        builder: (context) => SizedBox(
              height: 100,
              child: Column(
                children: const [
                  Text(
                    "Getting data",
                    style: TextStyle(fontSize: 20, fontFamily: "Poppins-Bold"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ));
  }

  Future<void> continueReading() async {
    try {
      final progress = Provider.of<AniListProvider>(context, listen: false)
          .userData['mangaList'];
      final manga = progress?.firstWhere(
          (manga) => widget.id == manga['media']['id'].toString(),
          orElse: () => null);
      final index = filteredChapterList!.firstWhere((chapter) =>
          chapter['id'].toString().contains(manga['progress'].toString()));
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

  void wrongTitle(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return StatefulBuilder(builder: (context, setWrongState) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 400,
              child: Column(
                children: [
                  TextField(
                    onSubmitted: (value) async {
                      log('Searching for: $value');
                      setWrongState(() {
                        wrongTitleSearchData = null;
                      });

                      final data = await search(
                          source: currentSource!,
                          query: value,
                          page: 1,
                          filterList: []);
                      setWrongState(() {
                        wrongTitleSearchData = data!.toJson()['list'];
                      });
                    },
                    controller: wrongTittle,
                    decoration: InputDecoration(
                      labelText: "Search here",
                      prefixIcon: Icon(Iconsax.search_normal),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 280,
                    child: wrongTitleSearchData == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: wrongTitleSearchData.length,
                            itemBuilder: (context, index) {
                              final title = wrongTitleSearchData[index]['name'];
                              return Padding(
                                padding: const EdgeInsets.all(5),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      chapterList = null;
                                      filteredChapterList = null;
                                    });
                                    changeChapterData(
                                        wrongTitleSearchData[index]['link']);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh),
                                    height: 90,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 90,
                                          width: 140,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                              left: Radius.circular(5),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  wrongTitleSearchData[index]
                                                      ['imageUrl'],
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(title.length > 15
                                            ? '${title.substring(0, 15)}...'
                                            : title),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
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
          loading ? "Loading..." : mangaData['name'],
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
          // mangaData != null && currentLink != null && currentChapter.isNotEmpty
          //     ? Mangafloater(
          //         data: mangaData,
          //         currentLink: currentLink!,
          //         chapterList: filteredChapterList!,
          //         currentChapter: currentChapter,
          //       )
          //     : const SizedBox.shrink(),
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
          Mangaalldetails(mangaData: mangaData),
          installedExtensions != null && installedExtensions!.isNotEmpty
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: DropdownButtonFormField<Source>(
                        value: currentSource,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Choose Source',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
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
                        items: installedExtensions!
                            .map<DropdownMenuItem<Source>>((source) {
                          return DropdownMenuItem<Source>(
                            value: source,
                            child: Text(source.name!),
                          );
                        }).toList(),
                        onChanged: (dynamic newValue) {
                          if (newValue.toString().isNotEmpty) {
                            setState(() {
                              chapterList = [];
                              currentSource = newValue;
                              mappingData(newValue);
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
                            style: TextStyle(
                                fontFamily: "Poppins-Bold", fontSize: 22),
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      chapterList =
                                          chapterList?.reversed.toList();
                                    });
                                  },
                                  icon: const Icon(Iconsax.arrow_down)),
                              GestureDetector(
                                onTap: () {
                                  wrongTitleSearch(mangaData['name'], context);
                                  showBottomLoader();
                                },
                                child: Text(
                                  "Wrong title?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Poppins-Bold",
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: TextField(
                        onChanged: (String value) {
                          searchChapter(value);
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Iconsax.search_normal),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            labelText: "Search Chapters",
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(20)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary))),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 460,
                      child: chapterList != null && chapterList!.isNotEmpty
                          ? ListView(
                              physics: const BouncingScrollPhysics(),
                              children: chapterList!.map<Widget>((chapter) {
                                return Chapterlist(
                                  id: widget.id,
                                  chapter: chapter,
                                  image: widget.image,
                                  source: currentSource!,
                                  chapterList: chapterList,
                                  title: mangaData['name'],
                                );
                              }).toList(),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                )
              : PlaceholderExtensions()
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
                          inputbox(context, _chapterController,
                              filteredChapterList!.length),
                          const SizedBox(height: 30),
                          saveManga(localSelectedValue, context),
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
              labelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
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

  GestureDetector saveManga(String localSelectedValue, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<AniListProvider>(context, listen: false).addToAniList(
          mediaId: int.parse(widget.id),
          status: localSelectedValue,
          score: double.tryParse(defaultScore),
          progress: int.parse(_chapterController.text),
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
