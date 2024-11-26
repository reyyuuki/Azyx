import 'dart:developer';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/Provider/sources_provider.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Anime/animeInfo.dart';
import 'package:daizy_tv/components/Anime/floater.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/utils/api/Anilist/Anime/_anime_api.dart';
import 'package:daizy_tv/utils/downloader/downloader.dart';
import 'package:daizy_tv/utils/helper/download.dart';
import 'package:daizy_tv/utils/api/Anilist/Anime/anilist_anime_details.dart';
import 'package:daizy_tv/utils/sources/Anime/SourceHandler/sourcehandler.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class Details extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;
  const Details(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  dynamic animeData;
  String? cover;
  String? description;
  List<dynamic>? streamData;
  String baseUrl = '';
  List<Map<String, dynamic>>? filteredEpisodes;
  dynamic consumetEpisodesList;
  dynamic episodeData;
  String episodeLink = "";
  int? episodeId;
  String? category;
  String server = "megacloud";
  dynamic tracks;
  bool dub = false;
  String? title;
  bool isloading = false;
  bool withPhoto = true;
  bool isScrapper = true;
  bool isWaiting = false;
  double score = 5.0;
  dynamic scrapeData;
  String localSelectedValue = "CURRENT";
  late AnimeSourcehandler sourcehandler;
  List<Map<String, String>> animeSources = [];
  String selectedSource = '';
  String defaultScore = "1.0";
  final TextEditingController _episodeController =
      TextEditingController(text: '1');
  ValueNotifier<List<dynamic>> streamDataNotifier =
      ValueNotifier<List<dynamic>>([]);
  List<Map<String, dynamic>> wrongTitleSearchData = [];
  TextEditingController wrongTitle = TextEditingController();

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
    final sourceProvider = Provider.of<SourcesProvider>(context, listen: false);
    sourcehandler = sourceProvider.getAnimeInstace();
    animeSources = sourcehandler.getAvailableSources();
    selectedSource = sourcehandler.selectedSource;
    scrapedData();
  }

  @override
  void dispose() {
    streamDataNotifier.dispose();
    super.dispose();
  }

  Future<void> scrapedData() async {
    try {
      final data = await fetchAnilistAnimeDetails(widget.id);

      if (data.isNotEmpty && mounted) {
        setState(() {
          animeData = data;
          log(animeData['episodes']);
        });
      } else {
        log("Error: Unexpected data type from scrapDetail");
      }
    } catch (error) {
      log("Error in scrapedData: $error");
    }
    fetchEpisodeList();
  }

  void route() {
    if (episodeLink.toString().isNotEmpty && !isloading) {
      Navigator.pushNamed(
        context,
        '/stream',
        arguments: {
          'episodeSrc': episodeLink,
          'episodeData': filteredEpisodes,
          'currentEpisode': episodeId,
          'episodeTitle': title,
          'subtitleTracks': tracks,
          'animeTitle': animeData['name'],
          'activeServer': server,
          'isDub': dub,
          'animeId': widget.id,
        },
      );
      log(tracks.toString());
    }
  }

  Future<void> wrongTitleSearch() async {
    try {
      final data = await sourcehandler.fetchSearchResults(animeData['name']);
      if (data != null) {
        setState(() {
          wrongTitleSearchData = data;
          wrongTitle.text = animeData['name'];
        });
        Navigator.pop(context);
        wrongTitleSheet(context);
      }
    } catch (e) {
      log('Error in wrongTitle: $e');
    }
  }

  Future<void> fetchm3u8(int episodeNumber) async {
    setState(() {
      isWaiting = true;
      category = dub ? "dub" : "sub";
    });

    try {
      final episodeValue = filteredEpisodes![(episodeNumber - 1)]['episodeId'];
      final streamingLink = await sourcehandler.fetchEpisodesSrcs(
        episodeValue,
        "megacloud",
        category!,
      );

      final trackResponse =
          await fetchStreamingLinksAniwatch(episodeValue, server, "sub");

      if (streamingLink != null) {
        final link = sourcehandler.selectedSource == "Hianime (Scrapper)"
            ? streamingLink.sources[0]['url']
            : streamingLink['sources'][0]['url'];

        final extract = await extractStreams(link);
        log(extract.toString());
        final baselink = makeBaseUrl(link);

        setState(() {
          episodeLink = link;
          streamData = extract;
          baseUrl = baselink;
          isWaiting = false;
          tracks = trackResponse?['tracks'] ?? "";
        });
        Navigator.pop(context);
        showDownloadquality(context, episodeNumber);
      }
    } catch (e) {
      log("When fetching Link: $e");
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  Future<void> continueWatching() async {
    try {
      final dataBase = Provider.of<Data>(context, listen: false);
      final link = dataBase.getCurrentEpisodeForAnime(widget.id);
      log("database: ${link.toString()}");
      if (link != null && link['title'] != null) {
        setState(() {
          episodeId = link['currentEpisode'];
          title = link['episodeTitle'];
          episodeLink = link['episodesrc'];
        });
      } else {
        setState(() {
          episodeId = filteredEpisodes!.first['number'];
          title = filteredEpisodes!.first['title'];
        });
        log('$episodeId /  $title');
      }
      log('$episodeId');
    } catch (e) {
      log("Error: ${e.toString()}");
      setState(() {
        episodeId = filteredEpisodes?.first['number'];
        title = filteredEpisodes?.first['title'];
      });
    }
  }

  Future<void> fetchEpisodeList() async {
    final dataProvider = Provider.of<Data>(context, listen: false);
    log(sourcehandler.selectedSource);
    try {
      final scrapeEpisodes =
          await sourcehandler.mappedSourceId(animeData['name']);

      if (scrapeEpisodes != null) {
        setState(() {
          episodeData = scrapeEpisodes['episodes'] ?? [];
          filteredEpisodes = scrapeEpisodes['episodes'] ?? [];
          scrapeData = scrapeEpisodes;
          final anime = dataProvider
              .getCurrentEpisodeForAnime(animeData['id']?.toString() ?? '1');
          episodeId = anime?['currentEpisode'] ?? 1;
          category = dub ? "dub" : "sub";
        });
        continueWatching();
      } else {
        log('No mapping found for anime search.');
      }
    } catch (e) {
      log('Error while fetching episode list: $e');
    }
  }

  Future<void> fetchEpisodeUrl() async {
    if (filteredEpisodes == null || episodeId == null) return;

    setState(() {
      category = dub ? "dub" : "sub";
    });

    try {
      final episodeIdValue = filteredEpisodes![(episodeId! - 1)]['episodeId'];
      final trackResponse =
          await fetchStreamingLinksAniwatch(episodeIdValue, server, "sub");

      final scraprLink = await sourcehandler.fetchEpisodesSrcs(
          episodeIdValue, server, dub ? "dub" : "sub");
  log("anivibe: ${scraprLink.toString()}");
      if (scraprLink != null) {
        setState(() {
          episodeLink = sourcehandler.selectedSource == "Hianime (Scrapper)"
              ? scraprLink.sources[0]['url']
              : scraprLink['sources'][0]['url'];
          tracks = trackResponse?['tracks'] != null ? trackResponse['tracks'] : [];
          isloading = false;
        });
      } else {
        log("Error: 'sources' key missing or empty in scraprLink response.");
      }

      log("Api call completed");
      log(isScrapper.toString());
      Navigator.pop(context);
      route();
    } catch (e) {
      log("Error in fetchEpisode: $e");
      setState(() {
        isloading = true;
      });
    }
  }

  void showloader() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return const SizedBox(
            height: 100,
            child: Column(
              children: [
                Text(
                  "Getting data",
                  style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
        });
  }

  void wrongTitleSheet(context) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        enableDrag: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child:
                StatefulBuilder(builder: (context, StateSetter setWrongState) {
              return SizedBox(
                height: 400,
                child: Column(
                  children: [
                    const Text(
                      "WrongTitle Serach",
                      style:
                          TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onSubmitted: (value) async {
                        log('Searching for: $value');
                        setWrongState(() {
                          wrongTitleSearchData = [];
                        });
                        final data =
                            await sourcehandler.fetchSearchResults(value);
                        setWrongState(() {
                          wrongTitleSearchData = data;
                        });
                      },
                      controller: wrongTitle,
                      decoration: InputDecoration(
                        labelText: "Search here",
                        prefixIcon: const Icon(Iconsax.search_normal),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: wrongTitleSearchData.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView(
                              children: wrongTitleSearchData.map((item) {
                              final title = item['name'];
                              final image = item['poster'];
                              final id = item['id'];
                              return Padding(
                                padding: const EdgeInsets.all(5),
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      filteredEpisodes = [];
                                      episodeData = [];
                                    });
                                    Navigator.pop(context);
                                    final data =
                                        await sourcehandler.fetchEpisodes(id!);
                                    setState(() {
                                      filteredEpisodes = data['episodes'];
                                      episodeData = data['episodes'];
                                      scrapeData = data;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
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
                                              imageUrl: image!,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        SizedBox(
                                          width: 150,
                                          child: Text(title)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList()),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  void handleEpisode(int? episode, String selectedServer, String getTitle) {
    if (episode != null && selectedServer.isNotEmpty) {
      setState(() {
        episodeId = episode;
        episodeLink = "";
        server = selectedServer;
        title = getTitle;
        isloading = true;
      });
      fetchEpisodeUrl();
    }
  }

  void handleCategory(String newCategory) {
    if (filteredEpisodes != null) {
      setState(() {
        category = newCategory;
        episodeLink = "";
      });
      fetchEpisodeUrl();
    }
  }

  void searchEpisode(String number) {
    final list = filteredEpisodes!
        .where((episode) => episode["number"].toString().contains(number))
        .toList();
    setState(() {
      episodeData = list;
    });
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
                                imageUrl: animeData['coverImage'],
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
                                  imageUrl: animeData['poster'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 55,
                            left: 130,
                            child: Text(
                              animeData['name'].length > 20
                                  ? '${animeData['name'].substring(0, 20)}...'
                                  : animeData['name'],
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
                          inputbox(context, _episodeController,
                              filteredEpisodes!.length),
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

  SizedBox tabs(BuildContext context) {
    return SizedBox(
      height: 750,
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        children: [
          AnimeInfo(animeData: animeData),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: DropdownButtonFormField<String>(
                  value: sourcehandler.selectedSource,
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
                  items: animeSources.map<DropdownMenuItem<String>>((source) {
                    return DropdownMenuItem<String>(
                      value: source['name'],
                      child: Text(source['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (dynamic newValue) {
                    if (newValue.toString().isNotEmpty) {
                      setState(() {
                        selectedSource = newValue;
                        sourcehandler.selectedSource = selectedSource;
                        filteredEpisodes = [];
                        fetchEpisodeList();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 178,
                      child: scrapeData == null ? const SizedBox.shrink() : Text("Found: ${scrapeData?['name']?.length > 20 ? '${scrapeData?['name']?.substring(0,20)}...' : scrapeData?['name'] ?? "Unkonwn"}",style: TextStyle(fontFamily: "Poppins-Bold", color: Theme.of(context).colorScheme.primary), )),
                    Text("Total Episodes: ${scrapeData?['totalEpisodes'] ?? "??"}",style: TextStyle(fontFamily: "Poppins-Bold", color: Theme.of(context).colorScheme.primary), ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Episodes",
                      style:
                          TextStyle(fontFamily: "Poppins-Bold", fontSize: 22),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          withPhoto ? Iconsax.image : Iconsax.menu_board,
                        ),
                        onPressed: () {
                          setState(() {
                            withPhoto = !withPhoto;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 40,
                      child: LiteRollingSwitch(
                        value: !dub,
                        width: 100,
                        textOn: "Sub",
                        textOff: "Dub",
                        textOnColor: Colors.white,
                        colorOn:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        colorOff: Theme.of(context).colorScheme.inversePrimary,
                        iconOn: Icons.closed_caption,
                        iconOff: Icons.mic,
                        animationDuration: const Duration(milliseconds: 300),
                        onChanged: (bool state) {
                          setState(() {
                            dub = !dub;
                          });
                          log(dub.toString());
                        },
                        onDoubleTap: () => {},
                        onSwipe: () => {},
                        onTap: () => {},
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          showloader();
                          wrongTitleSearch();
                        },
                        child: Text(
                          "Wrong Title?",
                          style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary),
                        ))
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextField(
                  onChanged: (String value) {
                    searchEpisode(value);
                  },
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.search_normal),
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
              !withPhoto
                  ? episodeList(context)
                  : Container(
                      height: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: filteredEpisodes != null &&
                                  filteredEpisodes!.isNotEmpty
                              ? ListView(
                                  children: episodeData!.map<Widget>((item) {
                                  final title = item['title'];
                                  final episodeNumber = item['number'];
                                  return GestureDetector(
                                    onTap: () {
                                      displayBottomSheet(
                                          context, episodeNumber, title);
                                    },
                                    child: Container(
                                      height: 100,
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: episodeNumber == episodeId
                                            ? Theme.of(context)
                                                .colorScheme
                                                .inversePrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      ),
                                      child: Stack(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .horizontal(
                                                    left: Radius.circular(10)),
                                                child: SizedBox(
                                                  height: 100,
                                                  width: 150,
                                                  child: CachedNetworkImage(
                                                    imageUrl: widget.image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    title.length > 25
                                                        ? '${title.substring(0, 25)}...'
                                                        : title,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inverseSurface,
                                                      fontFamily:
                                                          "Poppins-Bold",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (episodeNumber == episodeId)
                                                Icon(
                                                  Ionicons.play,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface,
                                                )
                                              else
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Text(
                                                    'Ep- $episodeNumber',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inverseSurface,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                showloader();
                                                fetchm3u8(episodeNumber);
                                              },
                                              child: Container(
                                                height: 27,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: Icon(
                                                    Icons.download_for_offline,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inversePrimary),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList())
                              : const Center(
                                  child: CircularProgressIndicator(),
                                )),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  void showDownloadquality(BuildContext context, int number) async {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: Colors.black87.withOpacity(0.3),
      builder: (context) {
        return SizedBox(
              height: 300,
          child: ListView(
                  children: [
                    const Center(
                      child: Text(
                        "Select quality",
                        style: TextStyle(
                            fontFamily: "Poppins-Bold", fontSize: 25),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ...streamData!.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            Downloader().download('$baseUrl/${item['url']}',
                                "Episode-$number", animeData['name']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['quality'],
                                  style: const TextStyle(
                                      fontFamily: "Poppins-Bold",
                                      fontSize: 18),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.download),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  Container episodeList(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: episodeData == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: episodeData?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = episodeData[index];
                  final title = item['title'];
                  final episodeNumber = item['number'];
                  return GestureDetector(
                    onTap: () {
                      displayBottomSheet(context, episodeNumber, title);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(
                            width: 5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        color: episodeNumber == episodeId
                            ? Theme.of(context).colorScheme.inversePrimary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 220,
                              child: Text(
                                title.length > 25
                                    ? '${title.substring(0, 25)}...'
                                    : title,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontFamily: "Poppins-Bold",
                                ),
                              ),
                            ),
                            episodeNumber == episodeId
                                ? Icon(
                                    Ionicons.play,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                                  )
                                : Text(
                                    'Ep- $episodeNumber',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
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
              contentPadding: const EdgeInsets.all(10),
              labelText: 'Episode Progress',
              filled: true,
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

  void displayBottomSheet(BuildContext context, int number, String setTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              const Text(
                "Select Server",
                style: TextStyle(fontSize: 25, fontFamily: "Poppins-Bold"),
              ),
              const SizedBox(
                height: 10,
              ),
              serverContainer(
                  context, "HD - 1", number, "vidstreaming", setTitle),
              const SizedBox(height: 10),
              serverContainer(context, "HD - 2", number, "megacloud", setTitle),
              const SizedBox(height: 10),
              serverContainer(
                  context, "Vidstream", number, "streamsb", setTitle),
            ],
          ),
        ),
      ),
    );
  }

  void showCenteredLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  GestureDetector serverContainer(BuildContext context, String name, int number,
      String serverType, String setTitle) {
    return GestureDetector(
      onTap: () async {
        handleEpisode(number, serverType, setTitle);
        Navigator.pop(context);
        showCenteredLoader();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 1, color: Theme.of(context).colorScheme.inversePrimary)),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);
    final provider = Provider.of<AniListProvider>(context, listen: false)
        .userData['animeList'];
    final anime = provider?.firstWhere(
        (anime) => widget.id == anime['media']['id'].toString(),
        orElse: () => null);

    localSelectedValue = anime?['status'] ?? "CURRENT";
    String getAnimeStatus(dynamic anime) {
      switch (anime['status']) {
        case 'CURRENT':
          return "Currently Watching";
        case 'COMPLETED':
          return "Completed";
        case 'PAUSED':
          return "Paused";
        case 'DROPPED':
          return "Dropped";
        case 'PLANNING':
          return "Planning to Watch";
        case 'REPEATING':
          return "Repeating";
        default:
          return "Unknown Status";
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextScroll(
          animeData == null ? "Loading..." : animeData['name'].toString(),
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
          ListView(children: [
            Stack(
              children: [
                animeData?['poster'] != null
                    ? CoverImage(imageUrl: animeData['coverImage'])
                    : const SizedBox.shrink(),
                Container(
                  height: 1100,
                  margin: const EdgeInsets.only(top: 220),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(50)),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                Poster(imageUrl: widget.image, id: widget.tagg),
                animeData == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 440,
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      )
                    : Positioned(
                        top: 340,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextScroll(
                                  animeData['name'] ?? "Unknown",
                                  mode: TextScrollMode.bouncing,
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(30, 0)),
                                  delayBefore:
                                      const Duration(milliseconds: 500),
                                  pauseBetween:
                                      const Duration(milliseconds: 1000),
                                  textAlign: TextAlign.center,
                                  selectable: true,
                                  style: const TextStyle(
                                      fontSize: 18, fontFamily: "Poppins-Bold"),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Ionicons.star,
                                    color: Colors.yellow,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    animeData?['rating'].toString() ?? "??",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Poppins-Bold"),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
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
                                              fontFamily: "Poppins-Bold",
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface,
                                            )),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainer,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    if (filteredEpisodes == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 65,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceBright),
                                        child: anime != null
                                            ? Center(
                                                child: Text(
                                                getAnimeStatus(anime),
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
                                                      fontFamily:
                                                          "Poppins-Bold",
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
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
                                        indicatorPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 8),
                                        squeezeIntensity: 2,
                                        textStyle: textStyle,
                                        selectedTextStyle: selectedTextStyle,
                                        indicatorDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20)),
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
                                              label: 'Watch',
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
                      )
              ],
            ),
          ]),
          filteredEpisodes != null
              ? AnimeFloater(
                  id: widget.id,
                  data: animeData,
                  episodeList: filteredEpisodes!,
                  isDub: dub,
                  episodeLink: episodeLink.isNotEmpty ? episodeLink : "",
                  episodeTitle: title ?? "Unkown title",
                  currentEpisode: episodeId ?? 1,
                  tracks: tracks,
                  selectedServer: server.isEmpty ? "megacloud" : server,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
