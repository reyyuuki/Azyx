// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:daizy_tv/components/Anime/animeInfo.dart';
import 'package:daizy_tv/dataBase/appDatabase.dart';
import 'package:daizy_tv/scraper/episodeScrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:http/http.dart' as http;

class AnimeDetails extends StatefulWidget {
  final dynamic animeData;
  final String id;

  const AnimeDetails({super.key, this.animeData, required this.id});

  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
  dynamic filteredEpisodes;
  dynamic episodeData;
  String? episodeLink;
  int? episodeId;
  String? category;
  String? server;
  dynamic tracks;
  bool dub = false;
  String? title;
  bool isloading = false;

  final String episodeUrl =
      '${dotenv.get("HIANIME_URL")}anime/episode-srcs?id=';

  @override
  void initState() {
    super.initState();
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
          'animeTitle': widget.animeData['name'],
          'activeServer': server,
          'isDub': false,
          'animeId': widget.id,
        },
      );
    }
  }

  Future<void> fetchEpisodeList() async {
    String url =
        "https://raw.githubusercontent.com/RyanYuuki/Anilist-Database/refs/heads/master/anilist/anime/${widget.id}.json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log(data.toString());

      String? zoroUrl;
      final provider = Provider.of<Data>(context, listen: false);

      if (data['Sites']['Zoro'] != null) {
        data['Sites']['Zoro'].forEach((key, value) {
          if (zoroUrl == null && value['url'] != null) {
            zoroUrl = value['url'];
          }
        });
      }

      if (zoroUrl != null) {
        final animeId = zoroUrl?.split('/').last;
        final episodeResponse = await scrapeAnimeEpisodes(animeId!);
        log(animeId.toString());

        if (mounted) {
          setState(() {
            episodeData = episodeResponse['episodes'];
            filteredEpisodes = episodeResponse['episodes'];
            episodeId = int.tryParse(provider.getCurrentEpisodeForAnime(
                widget.animeData['id']?.toString() ?? '1')!);
            category = 'sub';
          });
        }
      } else {
        log('No Zoro URL found.');
      }
    }
  }

  Future<void> fetchEpisodeUrl() async {
    if (episodeData == null || episodeId == null) return;

    try {
      final provider = Provider.of<Data>(context, listen: false);
      final episodeIdValue = episodeData[(episodeId! - 1)]['episodeId'];
      final response = await http.get(
          Uri.parse('$episodeUrl$episodeIdValue?server=$server&category=sub'));
      log('$episodeUrl$episodeIdValue?server=$server&category=sub');
      if (response.statusCode == 200) {
        final decodeData = jsonDecode(response.body);
        setState(() {
          episodeLink = decodeData['sources'][0]["url"];
          isloading = false;
          tracks = decodeData['tracks'];
          log(decodeData.toString());
        });
        Navigator.pop(context);
        route();
        provider.addWatchedAnimes(
          animeId: widget.animeData['id'],
          animeTitle: widget.animeData['name'],
          currentEpisode: episodeId!.toString(),
          posterImage: widget.animeData['poster'],
        );
      } else {
        log('Error fetching episode data');
        isloading = true;
      }
    } catch (e) {
      log("Error in fetchEpisode: $e");
      isloading = true;
    }
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
    if (episodeData != null) {
      setState(() {
        category = newCategory;
        episodeLink = "";
      });
      fetchEpisodeUrl();
    }
  }

  void handleEpisodeList(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredEpisodes = episodeData;
      } else {
        filteredEpisodes = episodeData?.where((episode) {
          final episodes = episode['number']?.toString() ?? '';
          return episodes.contains(value);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animeData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 440,),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);

    return Positioned(
      top: 340,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextScroll(
                widget.animeData['name'].toString(),
                mode: TextScrollMode.bouncing,
                velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                delayBefore: const Duration(milliseconds: 500),
                pauseBetween: const Duration(milliseconds: 1000),
                textAlign: TextAlign.center,
                selectable: true,
                style:
                    const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
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
                  widget.animeData['rating'].toString(),
                  style:
                      const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
                ),
              ],
            ),
            const SizedBox(height: 60),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  SegmentedTabControl(
                    tabTextColor: Colors.black,
                    selectedTabTextColor: Colors.white,
                    indicatorPadding: const EdgeInsets.all(4),
                    squeezeIntensity: 2,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: textStyle,
                    selectedTextStyle: selectedTextStyle,
                    tabs: [
                      SegmentTab(
                        label: 'Details',
                        color: Theme.of(context).colorScheme.inversePrimary,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      SegmentTab(
                        label: 'Watch',
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        AnimeInfo(animeData: widget.animeData),
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              height: 440,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredEpisodes?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final item = filteredEpisodes![index];
                                    final title = item['title'];
                                    final episodeNumber = item['number'];
                                    return GestureDetector(
                                      onTap: () {
                                        displayBottomSheet(
                                            context, episodeNumber, title);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border(
                                            left: BorderSide(
                                              width: 5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          color: episodeNumber == episodeId
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                        fontWeight:
                                                            FontWeight.w500,
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
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> displayBottomSheet(
      BuildContext context, int number, String setTitle) async {
    log(episodeLink.toString());
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondaryFixedVariant,
      showDragHandle: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
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
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
