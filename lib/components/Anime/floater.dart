import 'dart:developer';

import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AnimeFloater extends StatefulWidget {
  Map<String, dynamic> data;
  String currentLink;
  AnimeFloater({super.key, required this.data, required this.currentLink});

  @override
  State<AnimeFloater> createState() => _MangafloaterState();
}

class _MangafloaterState extends State<AnimeFloater> {
  bool isFavrouite = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Data>(context, listen: false);
    isFavrouite = provider.getFavroiteAnime(widget.data['id']);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isFavrouite) {
                  provider.addFavrouiteAnime(
                    title: widget.data['name'],
                    id: widget.data['id'],
                    image: widget.data['poster'],
                  );
                  setState(() {
                    isFavrouite = true;
                  });
                } else {
                  provider.removefavrouiteAnime(widget.data['id']);
                  setState(() {
                    isFavrouite = false;
                  });
                }
              },
              child: Container(
                color: Colors.white,
                height: 60,
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
                    Text(
                      !isFavrouite ? "Favrouite" : "",
                      style: const TextStyle(fontFamily: "Poppins-Bold"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/stream', arguments: {
                  'mangaId': widget.data['id'],
                  'image': widget.data['poster'],
                  'chapterLink': widget.currentLink
                });
              },
              child: Container(
                color: Colors.purple,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ionicons.book,
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary, // Icon color
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Read',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontFamily: "Poppins-Bold" // Text color
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
