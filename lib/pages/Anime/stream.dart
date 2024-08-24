import 'dart:convert';

import 'package:daizy_tv/components/Anime/animeDetails.dart';
import 'package:daizy_tv/components/Anime/poster.dart';
import 'package:daizy_tv/components/Anime/reusableList.dart';
import 'package:daizy_tv/components/Anime/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';

import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:text_scroll/text_scroll.dart';

class Stream extends StatefulWidget {
  final String id;

  const Stream({super.key, required this.id});

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  dynamic EpisodeData;
  dynamic AnimeData;
  dynamic Episode;
  String? episodeId;
  String? category;
  dynamic tracks;
  int? number;
  bool dub = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  final String baseUrl = 'https://aniwatch-ryan.vercel.app/anime/info?id=';
  final String episodeDataUrl =
      'https://aniwatch-ryan.vercel.app/anime/episodes/';
  final String episodeUrl =
      'https://aniwatch-ryan.vercel.app/anime/episode-srcs?id=';

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + widget.id));
      final episodeResponse =
          await http.get(Uri.parse(episodeDataUrl + widget.id));
      if (response.statusCode == 200 && episodeResponse.statusCode == 200) {
        final decodeData = jsonDecode(episodeResponse.body);
        final tempAnimeData = jsonDecode(response.body);

        setState(() {
          AnimeData = tempAnimeData;
          EpisodeData = decodeData['episodes'];
          episodeId = decodeData['episodes'][0]['episodeId'];
          category = 'sub';
          number = decodeData['episodes'][0]['number'];
        });

        fetchEpisode();
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> fetchEpisode() async {
    try {
      final response = await http.get(Uri.parse(
          '$episodeUrl$episodeId?server=vidstreaming&category=$category'));
      final captionsResponse = await http.get(
          Uri.parse('$episodeUrl$episodeId?server=vidstreaming&category=sub'));
      if (response.statusCode == 200) {
        final decodeData = jsonDecode(response.body);
        final tempdata = jsonDecode(captionsResponse.body);
        setState(() {
          Episode = decodeData['sources'];
          tracks = tempdata['tracks'];
          // Initialize player after fetching episode
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void handleEpisode(String url, int newNumber) {
    setState(() {
      episodeId = url;
      number = newNumber;
      fetchEpisode();
    });
  }

  void handleCategory(String newCategory) {
    if (AnimeData['anime']['info']['stats']['episodes']['dub'] >= number) {
      setState(() {
        category = newCategory;
        fetchEpisode();
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    if (EpisodeData == null || AnimeData == null || tracks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextScroll(
          AnimeData['anime']['info']['name'].toString(),
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
          delayBefore: const Duration(milliseconds: 500),
          pauseBetween: const Duration(milliseconds: 1000),
          textAlign: TextAlign.center,
          selectable: true,
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: ListView(
        children: [
          MediaPlayer(
            Episode: Episode![0]['url'],
            tracks: tracks,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Episode $number',
                  style: const TextStyle(fontSize: 20),
                ),
                Swicther(),
              ],
            ),
          ),
          EpisodeList(),
          const SizedBox(
            height: 30,
          ),
          Column(
            children: [
              Poster(
                imageUrl: AnimeData['anime']['info']['poster'],
                id: AnimeData['anime']['info']['id'],
              ),
              AnimeDetails(
                AnimeData: AnimeData['anime'],
              ),
              const SizedBox(
                height: 20,
              ),
              ReusableList(
                name: "Popular Anime",
                data: AnimeData['mostPopularAnimes'],
              ),
              const SizedBox(
                height: 10,
              ),
              ReusableList(
                name: "Related Anime",
                data: AnimeData['relatedAnimes'],
              ),
              const SizedBox(
                height: 10,
              ),
              ReusableList(
                name: "Recommended Anime",
                data: AnimeData['recommendedAnimes'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  LiteRollingSwitch Swicther() {
    return LiteRollingSwitch(
      value: true,
      width: 150,
      textOn: 'Sub',
      textOff: 'Dub',
      colorOn: Colors.indigo.shade400,
      colorOff: Colors.blueGrey,
      iconOn: Icons.closed_caption,
      iconOff: Icons.mic,
      animationDuration: const Duration(milliseconds: 300),
      onChanged: (bool state) {
        print('turned ${(state) ? 'off' : 'on'}');
      },
      onDoubleTap: () => handleCategory(category == 'sub' ? 'dub' : 'sub'),
      onSwipe: () => handleCategory(category == 'sub' ? 'dub' : 'sub'),
      onTap: () => handleCategory(category == 'sub' ? 'dub' : 'sub'),
    );
  }

  Padding EpisodeList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: EpisodeData!.length,
        itemBuilder: (context, index) {
          final item = EpisodeData![index];
          final title = item['title'];
          final url = item['episodeId'];
          final episodeNumber = item['number'];
          return GestureDetector(
            onTap: () => handleEpisode(url, episodeNumber),
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.inversePrimary),
                  borderRadius: BorderRadius.circular(10),
                  color: episodeNumber == number
                      ? Theme.of(context).colorScheme.inverseSurface
                      : Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextScroll(
                        title,
                        mode: TextScrollMode.bouncing,
                        velocity:
                            const Velocity(pixelsPerSecond: Offset(30, 0)),
                        delayBefore: const Duration(milliseconds: 500),
                        pauseBetween: const Duration(milliseconds: 1000),
                        textAlign: TextAlign.center,
                        selectable: true,
                        style: TextStyle(
                          color: episodeNumber == number
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                    ),
                    episodeNumber == number
                        ? Icon(
                            Ionicons.play,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )
                        : Text(
                            'Ep- ${item['number']}',
                            style: TextStyle(
                                fontSize: 14,
                                color: episodeNumber == number
                                    ? Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .inverseSurface),
                          )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
