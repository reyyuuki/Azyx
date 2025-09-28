import 'dart:io';

import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:azyx/Widgets/Animation/scale_animation.dart';
import 'package:azyx/Widgets/anime/item_card.dart';
import 'package:azyx/Widgets/common/gradient_title.dart';
import 'package:azyx/utils/functions.dart';
import 'package:flutter/material.dart';

class AnimeScrollableList extends StatelessWidget {
  final List<dynamic> animeList;
  final String title;
  final CarousaleVarient varient;
  final bool isManga;
  const AnimeScrollableList({
    super.key,
    required this.animeList,
    required this.title,
    required this.isManga,
    this.varient = CarousaleVarient.regular,
  });

  @override
  Widget build(BuildContext context) {
    final List<CarousaleData> data = getCarousaleData(animeList, varient);
    return data.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientTitle(title: title),
              const SizedBox(height: 15),
              SizedBox(
                height: Platform.isAndroid || Platform.isIOS ? 200 : 270,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final tagg = UniqueKey().toString();
                    return SlideAndScaleAnimation(
                      child: GestureDetector(
                        onTap: () {
                          isManga
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MangaDetailsScreen(
                                      smallMedia: item,
                                      tagg: tagg + data[index].id.toString(),
                                      isOffline: false,
                                    ),
                                  ),
                                )
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimeDetailsScreen(
                                      smallMedia: item,
                                      tagg: title + data[index].id.toString(),
                                      isOffline: false,
                                    ),
                                  ),
                                );
                        },
                        child: StaggeredAnimatedItemWrapper(
                          baseDuration: Duration(milliseconds: 1000),
                          child: ItemCard(
                            item: data[index],
                            tagg: tagg + data[index].id.toString(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
