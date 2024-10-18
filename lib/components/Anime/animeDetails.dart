import 'dart:convert';
import 'dart:developer';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:daizy_tv/backupData/anime.dart';
import 'package:daizy_tv/components/Anime/animeInfo.dart';
import 'package:daizy_tv/components/Anime/episode_list.dart';
import 'package:daizy_tv/scraper/episodeScrapper.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:http/http.dart' as http;

class AnimeDetails extends StatefulWidget {
  final dynamic animeData;
  final String id;
  const AnimeDetails({super.key, this.animeData,required this.id});

  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
  @override
  void initState() {
    super.initState();
    fetchEpisode();
  }

  dynamic filteredEpisodes;

  Future<void> fetchEpisode() async {
    String url =
        "https://raw.githubusercontent.com/RyanYuuki/Anilist-Database/master/mal/anime/${widget.id}.json";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log(data.toString());
      String? zoroUrl;
      if (data['Sites']['Zoro'] != null) {
        data['Sites']['Zoro'].forEach((key, value) {
          zoroUrl = value['url']; // Store the first URL found
        });
      }

      if (zoroUrl != null) {
        final animeId = zoroUrl?.split('/').last;
        final episodeResponse = await scrapeAnimeEpisodes(animeId!);
        log(episodeResponse.toString());

        if (mounted) {
          setState(() {
            filteredEpisodes = episodeResponse['episodes'];
          });
        }
      } else {
        log('No Zoro URL found.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animeData == null) {
      return const SizedBox();
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
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextScroll(
                widget.animeData == null
                    ? "Loading"
                    : widget.animeData['name'].toString(),
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
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Ionicons.star,
                  color: Colors.yellow,
                  size: 20,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.animeData['rating'].toString(),
                  style:
                      const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
                ),
              ],
            ),
            const SizedBox(
              height: 60,
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  SegmentedTabControl(
                    // Customization of widget
                    tabTextColor: Colors.black,
                    selectedTabTextColor: Colors.white,
                    indicatorPadding: const EdgeInsets.all(4),
                    squeezeIntensity: 2,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: textStyle,
                    selectedTextStyle: selectedTextStyle,
                    // Options for selection
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
                  // Corrected TabBarView
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        AnimeInfo(animeData: widget.animeData),
                        Column(
                          children: [
                            const SizedBox(height: 10,),
                            EpisodeList(filteredEpisodes: filteredEpisodes),
                            const SizedBox(height: 10,)
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
}
