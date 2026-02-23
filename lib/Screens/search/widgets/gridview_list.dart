import 'dart:math';

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:azyx/Widgets/anime/item_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GridviewList extends StatelessWidget {
  final List<Anime> data;
  final bool isManga;
  const GridviewList({super.key, required this.data, required this.isManga});

  @override
  Widget build(BuildContext context) {
    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 2.2, maxHeight);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: max(itemCount, minCount),
        childAspectRatio: gridWidth / gridHeight,
        crossAxisSpacing: 5,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final tagg = data[index].id.toString();
        final item = data[index];
        return GestureDetector(
          onTap: () {
            isManga
                ? Get.to(
                    () => MangaDetailsScreen(
                      tagg: tagg,
                      smallMedia: CarousaleData(
                        id: item.id ?? '1',
                        image: item.image ?? '',
                        title: item.title!,
                      ),
                    ),
                  )
                : Get.to(
                    () => AnimeDetailsScreen(
                      tagg: tagg,
                      smallMedia: CarousaleData(
                        id: item.id ?? '1',
                        image: item.image ?? '',
                        title: item.title!,
                      ),
                    ),
                  );
          },
          child: StaggeredAnimatedItemWrapper(
            baseDuration: Duration(milliseconds: 1000),
            child: ItemCard(
              item: CarousaleData(
                id: item.id ?? '1',
                image: item.image ?? '',
                title: item.title ?? 'Unkown',
                extraData: item.rating,
                other: item.status,
              ),
              tagg: tagg.toString(),
            ),
          ),
        );
      },
    );
  }
}
