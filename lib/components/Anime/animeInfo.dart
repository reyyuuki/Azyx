import 'package:daizy_tv/components/Anime/genres.dart';
import 'package:flutter/material.dart';

class AnimeInfo extends StatelessWidget {
  final dynamic animeData;
  const AnimeInfo({super.key, this.animeData});

  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Genres(genres: animeData['genres']),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Japanese: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Aired: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Premiered: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Duration: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Status: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Rating: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Quality: ",
                        style: TextStyle(fontFamily: "Poppins-Bold")),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animeData['japanese'] != null &&
                            animeData['japanese'].length > 20
                        ? '${animeData['japanese'].substring(0, 18)}...'
                        : animeData['japanese'] ?? "??",
                    style: const TextStyle(fontFamily: "Poppins-Bold"),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    animeData['aired'] != null && animeData['aired'].length > 20
                        ? '${animeData['aired'].substring(0, 18)}...'
                        : animeData['aired'] ?? "??",
                    style: const TextStyle(fontFamily: "Poppins-Bold"),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(animeData['premiered'] ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(animeData['duration'] ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(animeData['status'] ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(animeData['rating'].toString(),
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(animeData['quality'] ?? "??",
                      style: const TextStyle(fontFamily: "Poppins-Bold")),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
              animeData['description'].length > 300
                  ? animeData['description'].substring(0, 300) + '...'
                  : animeData['description'],
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(232, 165, 159, 159))),
        ),
      ],
    );
  }
}
