// ignore_for_file: file_names

import 'dart:developer';

import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AnimeFloater extends StatefulWidget {
  Map<String, dynamic> data;
  List<Map<String, dynamic>> episodeList;
  String id;
  String selectedServer;
  bool isDub;
  int currentEpisode;
  String episodeTitle;
  String episodeLink;
  dynamic tracks;
  AnimeFloater(
      {super.key,
      required this.data,
      required this.episodeList,
      required this.isDub,
      required this.episodeTitle,
      required this.currentEpisode,
      required this.selectedServer,
      required this.episodeLink,
      required this.id,
      required this.tracks});

  @override
  State<AnimeFloater> createState() => _AnimefloaterState();
}

class _AnimefloaterState extends State<AnimeFloater> {
  bool isFavrouite = false;

  @override
  Widget build(BuildContext context) {

    void showSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
      content:  Text("You have not started watching yet!",style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

    final provider = Provider.of<Data>(context, listen: false);
    isFavrouite = provider.getFavroiteAnime(widget.data['id'].toString());
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: !isFavrouite ? MediaQuery.of(context).size.width * 0.5 : 100,
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                if (!isFavrouite) {
                  provider.addFavrouiteAnime(
                    name: widget.data['name'],
                    id: widget.data['id'].toString(),
                    image: widget.data['poster'],
                    episodeList: widget.episodeList,
                    server: "vidstream",
                    category: widget.isDub ? "dub" : "sub",
                    description: widget.data['description'],
                  );
                  setState(() {
                    isFavrouite = true;
                  });
                } else {
                  provider.removefavrouiteAnime(widget.id);
                  setState(() {
                    isFavrouite = false;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(20))),
                height: 60,
                width: !isFavrouite
                    ? MediaQuery.of(context).size.width * 0.5
                    : 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFavrouite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    !isFavrouite
                        ? const Text(
                            "Favorite",
                            style: TextStyle(fontFamily: "Poppins-Bold"),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.episodeLink.isNotEmpty
                    ? Navigator.pushNamed(
                        context,
                        '/stream',
                        arguments: {
                          'episodeSrc': widget.episodeLink,
                          'episodeData': widget.episodeList,
                          'currentEpisode': widget.currentEpisode,
                          'episodeTitle': widget.episodeTitle,
                          'subtitleTracks': widget.tracks,
                          'animeTitle': widget.data['name'],
                          'activeServer': widget.selectedServer,
                          'isDub': widget.isDub,
                          'animeId': widget.id,
                        },
                      )
                    : showSnackBar(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius:
                        const BorderRadius.only(topRight: Radius.circular(20))),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_filter_sharp,
                      color:
                          Theme.of(context).colorScheme.primary, // Icon color
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Episode ${widget.currentEpisode}",
                      // widget.currentChapter.length > 20 ?  '${widget.currentChapter.substring(0,20)}...' : widget.currentChapter,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: "Poppins-Bold",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
