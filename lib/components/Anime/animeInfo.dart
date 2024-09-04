import 'package:flutter/material.dart';

class AnimeInfo extends StatelessWidget {
final dynamic animeData;

   const AnimeInfo({super.key,this.animeData});

  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Japanese: "),
                SizedBox(
                  height: 5,
                ),
                Text("Aired: "),
                SizedBox(
                  height: 5,
                ),
                Text("Premiered: "),
                SizedBox(
                  height: 5,
                ),
                Text("Duration: "),
                SizedBox(
                  height: 5,
                ),
                Text("Status: "),
                SizedBox(
                  height: 5,
                ),
                Text("Rating: "),
                SizedBox(
                  height: 5,
                ),
                Text("Quality: "),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(animeData!['moreInfo']['japanese'].length > 13
                  ? animeData['moreInfo']['japanese'].substring(0, 13)
                  : animeData['moreInfo']['japanese'] ?? "??"),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['moreInfo']['aired'] ?? "??"),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['moreInfo']['premiered'] ?? "??"),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['moreInfo']['duration'] ?? "??"),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['moreInfo']['status'] ?? "??"),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['info']['stats']['rating'] ?? "??"),
              const SizedBox(
                height: 5,
              ),
              Text(animeData['info']['stats']['quality'] ?? "??"),
            ],
          ),
        ],
      ),
    );
  }
}
