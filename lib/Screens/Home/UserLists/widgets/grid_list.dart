import 'dart:math';

import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class UserGridList extends StatelessWidget {
  final List<UserMedia> data;
  final bool isManga;
  const UserGridList({super.key, required this.data, required this.isManga});

  @override
  Widget build(BuildContext context) {
    int itemCount = (MediaQuery.of(context).size.width ~/ 120).toInt();
    int minCount = 3;
    int crossAxisCount = max(itemCount, minCount);

    double horizontalPadding = 16;
    double gridWidth =
        (MediaQuery.of(context).size.width -
            (horizontalPadding * 2) -
            ((crossAxisCount - 1) * 10)) /
        crossAxisCount;
    double gridHeight = (gridWidth * 1.5) + 65;

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: gridWidth / gridHeight,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
      ),
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
                              title: item.title!,
                            ),
                            tagg: item.title! + item.id.toString(),
                            isOffline: false,
                          ),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimeDetailsScreen(
                            smallMedia: CarousaleData(
                              id: tagg!,
                              image: item.image!,
                              title: item.title!,
                            ),
                            tagg: item.title! + item.id.toString(),
                            isOffline: false,
                          ),
                        ),
                      );
              },
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Hero(
                  tag: tagg.toString(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.image!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              Center(child: LoadingIndicatorM3E()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AzyXText(
              text: item.title!,
              fontVariant: FontVariant.bold,
              fontSize: 12,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AzyXText(
              text: '${item.progress} | ${item.episodes ?? '?'}',
              fontSize: 11,
              fontVariant: FontVariant.regular,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ],
        );
      },
    );
  }
}
