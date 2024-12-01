// ignore_for_file: file_names

import 'dart:io';

import 'package:azyx/components/Anime/anime_item.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class Mangacarousale extends StatelessWidget {
  final List<dynamic>? carosaleData;

  const Mangacarousale({super.key, required this.carosaleData});

  @override
  Widget build(BuildContext context) {

  if(carosaleData == null){
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Currently Reading",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins-Bold",
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                         Theme.of(context).colorScheme.inverseSurface,
                          Theme.of(context).colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
              ),
              Icon(Iconsax.arrow_right_4, color: Theme.of(context).colorScheme.primary,)
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: Platform.isAndroid ? 220 : 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: carosaleData!.length,
              itemBuilder: (context, itemIndex) {
                final manga = carosaleData![itemIndex];
                final id = manga['media']['id'];
                final poster = manga['media']['coverImage']['large'];
                final title = manga['media']['title']['english'] ?? manga['media']['title']['romaji'] ?? "N/A";
                final type = manga['media']['format'];
                final rating = manga['media']['averageScore'];
                final tagg = '${id.toString()}current';
                return ItemCard(id: id.toString(), poster: poster, type: type, name: title, rating: rating, tagg: tagg, route: '/mangaDetail');
              }
            )
          )
        ]
      )
    );


  }
}
