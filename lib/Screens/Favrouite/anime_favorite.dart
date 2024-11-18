// ignore_for_file: file_names, prefer_const_constructors

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/components/Anime/floater.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/coverImage.dart';
import 'package:daizy_tv/utils/api/_anime_api.dart';
import 'package:daizy_tv/utils/downloader/downloader.dart';
import 'package:daizy_tv/utils/helper/download.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class AnimeFavouritePage extends StatefulWidget {
  final String id;
  final String image;
  final String tagg;

  const AnimeFavouritePage(
      {super.key, required this.id, required this.image, required this.tagg});

  @override
  State<AnimeFavouritePage> createState() => _DetailsState();
}

class _DetailsState extends State<AnimeFavouritePage> {
  dynamic wrongTitleSearchData;
  List<Map<String, dynamic>>? episodeList;
  dynamic filteredEpisodes;
  String? value;
  String? cover;
  String episodeTitle = '';
  String episodeLink = '';
  List<Map<String, dynamic>>? streamdata;
  int? episodeNumber;
  dynamic tracks;
  bool loading = true;
  TextEditingController? _controller;
  Map<String, dynamic>? animeData;
  bool isDub = false;
  bool isloading = false;
  String server = "vidstream";
  String? downloadBaseUrl;

  @override
  void initState() {
    super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {
    loadData();
    continueWatching();
  });
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
        animeData = provider.getFavoritesAnimeById(widget.id);
        filteredEpisodes = List<Map<String, dynamic>>.from(
          animeData!['episodeList'].map((item) {
            return Map<String, dynamic>.from(item);
          }),
        );
      });
    }
  }

  void route() {
    if (episodeLink.toString().isNotEmpty && !isloading) {
      Navigator.pushNamed(
        context,
        '/stream',
        arguments: {
          'episodeSrc': episodeLink,
          'episodeData': filteredEpisodes,
          'currentEpisode': episodeNumber,
          'episodeTitle': episodeTitle,
          'subtitleTracks': tracks,
          'animeTitle': animeData!['name'],
          'activeServer': server,
          'isDub': isDub,
          'animeId': widget.id,
        },
      );
      log(tracks.toString());
    }
  }

  Future<void> contineEpisode(int number) async {
    if (filteredEpisodes == null) return;
    log("restart");
    try {
      final episodeIdValue = filteredEpisodes[number - 1]['episodeId'];
      final trackResponse =
          await fetchStreamingLinksAniwatch(episodeIdValue, server, "sub");

      final scraprLink = await fetchStreamingLinksAniwatch(
          episodeIdValue, server, isDub ? "dub" : "sub");

      if (scraprLink != null) {
        setState(() {
          episodeLink = scraprLink['sources'][0]['url'];
          tracks = trackResponse['tracks'];
          episodeNumber = number;
          episodeTitle = filteredEpisodes[number - 1]['title'];
        });
      } else {
        log("Error: 'sources' key missing or empty in scraprLink response.");
      }
    } catch (e) {
      log("Error in fetchEpisode: $e");
    }
  }

  Future<void> fetchEpisodeUrl(int number) async {
    if (filteredEpisodes == null) return;

    try {
      final episodeIdValue = filteredEpisodes[number - 1]['episodeId'];
      final trackResponse =
          await fetchStreamingLinksAniwatch(episodeIdValue, server, "sub");

      final scraprLink = await fetchStreamingLinksAniwatch(
          episodeIdValue, server, isDub ? "dub" : "sub");

      if (scraprLink != null) {
        setState(() {
          episodeLink = scraprLink['sources'][0]['url'];
          tracks = trackResponse['tracks'];
          episodeTitle = filteredEpisodes[number - 1]['title'];
          episodeNumber = number;
          isloading = false;
        });
      } else {
        log("Error: 'sources' key missing or empty in scraprLink response.");
      }
      log("Api call completed");
      Navigator.pop(context);
      route();
    } catch (e) {
      log("Error in fetchEpisode: $e");
      setState(() {
        isloading = true;
      });
    }
  }

  Future<void> fetchm3u8(int episodeNumber) async {
    try {
      final episodeValue = filteredEpisodes![(episodeNumber - 1)]['episodeId'];
      final streamingLink = await fetchStreamingLinksAniwatch(
        episodeValue,
        "vidstream",
        isDub ? "dub" : "sub",
      );

      final trackResponse =
          await fetchStreamingLinksAniwatch(episodeValue, "vidstream", "sub");

      if (streamingLink != null) {
        final link = streamingLink['sources'][0]['url'];
        final extract = await extractStreams(link);
        final baselink = makeBaseUrl(link);
        setState(() {
          episodeLink = link;
          tracks = trackResponse['tracks'];
          episodeNumber = episodeNumber;
          streamdata = extract;
          downloadBaseUrl = baselink;
        });
        Navigator.pop(context);
        showDownloadquality(context, episodeNumber);
        log(episodeLink.toString());
      }
    } catch (e) {
      log("When fetching Link: $e");
    }
  }

  Future<void> continueWatching() async {
  try {
    final dataBase = Provider.of<Data>(context, listen: false);
    final animestoredData = dataBase.getCurrentEpisodeForAnime(widget.id);

    if (animestoredData != null &&
        animestoredData.isNotEmpty &&
        animestoredData['episodesrc'] != null &&
        animestoredData['episodesrc'].toString().isNotEmpty) {

      // Use stored episode data if it's valid
      setState(() {
        episodeNumber = animestoredData['currentEpisode'] ?? 1;
        episodeTitle = animestoredData['episodeTitle'] ?? 'Episode 1';
        tracks = animestoredData['tracks'] ?? [];
        episodeLink = animestoredData['episodesrc'] ?? '';
      });
      log('Loaded from database: $animestoredData');

    } else {
      // If no valid data, use `contineEpisode` with a fallback of episode 1
      log('No valid stored data, defaulting to episode 1.');
      contineEpisode(animestoredData?['currentEpisode'] ?? 1);
    }

    log('Episode link after loading: $episodeLink');

  } catch (e) {
    log("Error: ${e.toString()}");
    setState(() {
      episodeNumber = filteredEpisodes?.first['number'] ?? 1;
      episodeTitle = filteredEpisodes?.first['title'] ?? 'Episode 1';
    });
  }
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
                    "Getting Link",
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
          height: 250,
          child: Column(
            children: [
              const Text(
                "Select quality",
                style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              ...streamdata!.map<Widget>((item) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Downloader().download('$downloadBaseUrl/${item['url']}',
                          "Episode-$number", animeData!['name']);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).colorScheme.inversePrimary,
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
                                fontFamily: "Poppins-Bold", fontSize: 18),
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

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: TextScroll(
          animeData?['name'] ?? "Loading...",
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
                  if (animeData == null)
                    const SizedBox.shrink()
                  else
                    CoverImage(
                      imageUrl: animeData!['image'] ?? widget.image,
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 370),
                          child: Text(
                            animeData?['description'] != null ?
                            (animeData?['description']?.length > 150
                                ? '${animeData?['description'].substring(0, 150)}...'
                                : animeData?['description']) : "N/A",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Episodes",
                              style: TextStyle(
                                  fontFamily: "Poppins-Bold", fontSize: 22),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: LiteRollingSwitch(
                                    value: !isDub,
                                    width: 100,
                                    textOn: "Sub",
                                    textOff: "Dub",
                                    textOnColor: Colors.white,
                                    colorOn: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    colorOff: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    iconOn: Icons.closed_caption,
                                    iconOff: Icons.mic,
                                    animationDuration:
                                        const Duration(milliseconds: 300),
                                    onChanged: (bool state) {
                                      setState(() {
                                        isDub = !isDub;
                                      });
                                      log(isDub.toString());
                                    },
                                    onDoubleTap: () => {},
                                    onSwipe: () => {},
                                    onTap: () => {},
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceBright,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Poster(imageUrl: widget.image, id: widget.tagg),
                ],
              ),
              SizedBox(
                height: 485,
                child: Container(
                  height: 450,
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
                              children: filteredEpisodes!.map<Widget>((item) {
                              final title = item['title'];
                              final episodeNumber = item['number'];
                              return GestureDetector(
                                onTap: () {
                                  fetchEpisodeUrl(episodeNumber);
                                  showCenteredLoader();
                                },
                                child: Container(
                                  height: 100,
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: episodeNumber ==
                                            animeData!['currentEpisode']
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
                                            borderRadius:
                                                const BorderRadius.horizontal(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
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
                                          ),
                                          if (episodeNumber ==
                                              animeData!['currentEpisode'])
                                            Icon(
                                              Ionicons.play,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface,
                                            )
                                          else
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Text(
                                                'Ep- $episodeNumber',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface,
                                                  fontWeight: FontWeight.w500,
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
                                            fetchm3u8(episodeNumber);
                                            showBottomLoader();
                                          },
                                          child: Container(
                                            height: 27,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                            ),
                                            child: const Icon(
                                                Icons.download_for_offline),
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
              ),
            ],
          ),
          animeData != null
              ? AnimeFloater(
                  data: animeData!,
                  episodeLink: episodeLink,
                  episodeList: filteredEpisodes,
                  isDub: isDub,
                  episodeTitle: episodeTitle,
                  currentEpisode: episodeNumber!,
                  selectedServer: "vidstream",
                  id: widget.id,
                  tracks: tracks,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
