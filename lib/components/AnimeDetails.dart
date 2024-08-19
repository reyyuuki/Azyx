import 'package:daizy_tv/components/AnimeInfo.dart';
import 'package:daizy_tv/components/Genres.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class AnimeDetails extends StatelessWidget {
  final dynamic AnimeData;
  const AnimeDetails({super.key, this.AnimeData});

  @override
  Widget build(BuildContext context) {
    if (AnimeData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Positioned(
      top: 340,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextScroll(
                AnimeData == null
                    ? "Loading"
                    : AnimeData['info']['name'].toString(),
                mode: TextScrollMode.bouncing,
                velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                delayBefore: const Duration(milliseconds: 500),
                pauseBetween: const Duration(milliseconds: 1000),
                textAlign: TextAlign.center,
                selectable: true,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Ionicons.star,
                  color: Colors.yellow,
                  size: 20,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  AnimeData['moreInfo']['malscore'],
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Genres(genres: AnimeData['moreInfo']['genres']),
            const SizedBox(
              height: 30,
            ),
            AnimeInfo(AnimeData: AnimeData),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                AnimeData['info']['description'].length > 400
                    ? AnimeData['info']['description'].substring(0, 400) + '...'
                    : AnimeData['info']['description'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
