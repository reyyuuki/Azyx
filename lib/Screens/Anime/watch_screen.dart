
import 'dart:developer';
import 'dart:io';

import 'package:daizy_tv/components/Desktop/anime/media_kit.dart';
import 'package:daizy_tv/components/Video_palyer/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WatchPage extends StatefulWidget {
  final dynamic episodeData;
  final String episodeTitle;
  final int currentEpisode;
  final String episodeSrc;
  final dynamic subtitleTracks;
  final String animeTitle;
  final String activeServer;
  final bool isDub;
  final int animeId;
  const WatchPage({
    super.key,
    required this.episodeSrc,
    required this.episodeData,
    required this.currentEpisode,
    required this.episodeTitle,
    required this.subtitleTracks,
    required this.animeTitle,
    required this.activeServer,
    required this.isDub,
    required this.animeId,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    log(widget.isDub.toString());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Platform.isAndroid ? 
         VideoPlayerAlt(
          animeId: widget.animeId,
          episodeTitle: widget.episodeTitle,
          episodeSrc: widget.episodeSrc,
          tracks: widget.subtitleTracks,
          provider: Theme.of(context),
          animeTitle: widget.animeTitle,
          currentEpisode: widget.currentEpisode,
          episodeData: widget.episodeData,
          activeServer: widget.activeServer,
          isDub: widget.isDub,
        ) : 
         DesktopPlayer(
          animeId: widget.animeId,
          episodeTitle: widget.episodeTitle,
          episodeSrc: widget.episodeSrc,
          tracks: widget.subtitleTracks,
          provider: Theme.of(context),
          animeTitle: widget.animeTitle,
          currentEpisode: widget.currentEpisode,
          episodeData: widget.episodeData,
          activeServer: widget.activeServer,
          isDub: widget.isDub,
        ));
  }
}