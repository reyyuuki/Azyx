import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:better_player/better_player.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class Stream extends StatefulWidget {
  final String id;
  
  const Stream({super.key, required this.id});

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  dynamic EpisodeData;
  dynamic AnimeData;

  BetterPlayerController? _betterPlayerController;
  

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Ensure data is fetched when the widget is initialized

    print("Initializing BetterPlayerController...");

    var betterPlayerConfiguration = const BetterPlayerConfiguration(
      controlsConfiguration: BetterPlayerControlsConfiguration(
        playerTheme: BetterPlayerTheme.cupertino
      ),
      autoPlay: true,
    );

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    );

    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );
    
    print("BetterPlayerController initialized.");
  }

  final String baseUrl = 'https://aniwatch-ryan.vercel.app/anime/';
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
          AnimeData = tempAnimeData['anime'];
          EpisodeData = decodeData['episodes'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Streaming"),
      ),
      body: ListView(
        children:[ AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(
            controller: _betterPlayerController!,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text('Episode 1', style: TextStyle(fontSize: 20), ),
            LiteRollingSwitch(
                  value: true,
                  width: 150,
                  textOn: 'Dub',
                  textOff: 'Sub',
                  colorOn: const Color.fromARGB(255, 30, 187, 38),
                  colorOff: Colors.blueGrey,
                  iconOn: Icons.mic,
                  iconOff: Icons.closed_caption,
                  animationDuration: const Duration(milliseconds: 300),
                  onChanged: (bool state) {
                    print('turned ${(state) ? 'on' : 'off'}');
                  },
                  onDoubleTap: () {},
                  onSwipe: () {},
                  onTap: () {},
                ),
          ],),
        ),
        ],
      ),
    );
  }
}


