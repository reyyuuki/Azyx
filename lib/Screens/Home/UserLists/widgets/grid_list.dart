import 'dart:io';
import 'dart:math';

import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserGridList extends StatelessWidget {
  final List<UserAnime> data;
  final bool isManga;
  const UserGridList({super.key, required this.data, required this.isManga});

  @override
  Widget build(BuildContext context) {
    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.9, maxHeight);
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max(itemCount, minCount),
          childAspectRatio: gridWidth / gridHeight,
          crossAxisSpacing: 5),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final tagg = data[index].id;
        final item = data[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                isManga
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MangaDetailsScreen(
                                  smallMedia: CarousaleData(
                                      id: tagg!,
                                      image: item.image!,
                                      title: item.title!),
                                  tagg: item.title! + item.id.toString(),
                                  isOffline: false,
                                )))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnimeDetailsScreen(
                                  smallMedia: CarousaleData(
                                      id: tagg!,
                                      image: item.image!,
                                      title: item.title!),
                                  tagg: item.title! + item.id.toString(),
                                  isOffline: false,
                                )));
              },
              child: Container(
                height: Platform.isAndroid || Platform.isIOS ? 150 : 200,
                width: Platform.isAndroid || Platform.isIOS ? 103 : 140,
                margin: const EdgeInsets.only(right: 10),
                child: Hero(
                  tag: tagg.toString(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: data[index].image!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            AzyXText(
              text: data[index].title!,
              fontVariant: FontVariant.bold,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            AzyXText(
              text: '${data[index].progress} | ${data[index].episodes ?? '?'}',
            )
          ],
        );
      },
    );
  }
}
