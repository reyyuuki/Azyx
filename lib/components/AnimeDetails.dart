import 'package:daizy_tv/components/AnimeInfo.dart';
import 'package:daizy_tv/components/Genres.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AnimeDetails extends StatelessWidget {
  final dynamic AnimeData;
  const AnimeDetails({super.key,this.AnimeData });

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
                        child: Text(
                          AnimeData['info']['name'].length > 80
                              ? AnimeData['info']['name'].substring(0, 75) +
                                  "..."
                              : AnimeData['info']['name'],
                          style: const TextStyle(fontSize: 16),
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
                          AnimeData['info']['description'],
                        ),
                      ),
                    ],
                  ),
                ),
              );

  }
}