import 'dart:developer';
import 'dart:io';

import 'package:daizy_tv/components/Anime/anime_item.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class Animecarousale extends StatelessWidget {
  final List<dynamic>? carosaleData;

  const Animecarousale({super.key, required this.carosaleData});

  @override
  Widget build(BuildContext context) {
    if (carosaleData == null) {
      return const SizedBox.shrink();
    }
    return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Currently Watching",
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
              Icon(
                Iconsax.arrow_right_4,
                color: Theme.of(context).colorScheme.primary,
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
              height: Platform.isAndroid ? 220 : 300,
              child: ListView.builder(
                  itemCount: carosaleData!.length,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, itemIndex) {
                    final anime = carosaleData?[itemIndex];
                    final id = anime['media']['id'];
                    final poster = anime['media']['coverImage']['large'];
                    final title = anime['media']['title']['english'] ??
                        anime['media']['title']['romaji'] ??
                        "N/A";
                    final type = anime['media']['format'];
                    final rating = anime['media']['averageScore'];
                    final tagg = '${id.toString()}current';
                    return ItemCard(
                        id: id.toString(),
                        poster: poster,
                        type: type,
                        name: title,
                        rating: rating,
                        tagg: tagg,
                        route: '/detailspage');
                  }))
        ]));
  }
}
