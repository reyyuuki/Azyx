import 'package:daizy_tv/components/Anime/animeInfo.dart';
import 'package:daizy_tv/components/Anime/genres.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class AnimeDetails extends StatelessWidget {
  final dynamic animeData;
  final String? description;
  const AnimeDetails({super.key, this.animeData, this.description});


  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const SizedBox();
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
                animeData == null
                    ? "Loading"
                    : animeData['name'].toString(),
                mode: TextScrollMode.bouncing,
                velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                delayBefore: const Duration(milliseconds: 500),
                pauseBetween: const Duration(milliseconds: 1000),
                textAlign: TextAlign.center,
                selectable: true,
                style: const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
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
                  animeData['malscore'] ?? "??",
                  style: const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Genres(genres: animeData['genres']),
            const SizedBox(
              height: 30,
            ),
            AnimeInfo(animeData: animeData),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                description != null ? description!.length > 400 ? '${description!.substring(0, 400)}...' : description :
                animeData['description'].length > 400
                    ? animeData['description'].substring(0, 400) + '...'
                    : animeData['description'],
                    style: const TextStyle( fontFamily: "Poppins-Bold")
              ),
            ),
          ],
        ),
      ),
    );
  }
}
