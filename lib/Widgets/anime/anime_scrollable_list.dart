import 'dart:io';

import 'package:azyx/Classes/anime_class.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Widgets/Animation/scale_animation.dart';
import 'package:azyx/Widgets/anime/item_card.dart';
import 'package:azyx/Widgets/common/gradient_title.dart';
import 'package:flutter/material.dart';

class AnimeScrollableList extends StatelessWidget {
  final List<Anime> animeList;
  final String title;
  const AnimeScrollableList(
      {super.key, required this.animeList, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientTitle(title: title),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: Platform.isAndroid || Platform.isIOS ? 200 : 270,
          child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                return SlideAndScaleAnimation(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnimeDetailsScreen(
                                  id: animeList[index].id ?? 1,
                                  tagg: title + animeList[index].id.toString(),
                                  image: animeList[index].image!,
                                  title: animeList[index].title!)));
                    },
                    child: ItemCard(
                      item: animeList[index],
                      tagg: title + animeList[index].id.toString(),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}
