import 'dart:io';

import 'package:azyx/Classes/anime_class.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/Animation/scale_animation.dart';
import 'package:azyx/Widgets/anime/item_card.dart';
import 'package:azyx/Widgets/common/gradient_title.dart';
import 'package:flutter/material.dart';

class MangaScrollableList extends StatelessWidget {
  final List<Anime> managaList;
  final String title;
  const MangaScrollableList(
      {super.key, required this.managaList, required this.title});

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
              itemCount: managaList.length,
              itemBuilder: (context, index) {
                return SlideAndScaleAnimation(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MangaDetailsScreen(
                                  id: managaList[index].id ?? 1,
                                  tagg: title + managaList[index].id.toString(),
                                  image: managaList[index].image!,
                                  title: managaList[index].title!)));
                    },
                    child: ItemCard(
                      item: managaList[index],
                      tagg: title + managaList[index].id.toString(),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}
