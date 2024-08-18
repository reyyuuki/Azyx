import 'package:flutter/material.dart';

class AnimeInfo extends StatelessWidget {
final dynamic AnimeData;

   const AnimeInfo({super.key,this.AnimeData});

  @override
  Widget build(BuildContext context) {
    if (AnimeData == null) {
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
              Text(AnimeData!['moreInfo']['japanese'].length > 13
                  ? AnimeData['moreInfo']['japanese'].substring(0, 13)
                  : AnimeData['moreInfo']['japanese']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['aired']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['premiered']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['duration']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['status']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['info']['stats']['rating']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['info']['stats']['quality']),
            ],
          ),
        ],
      ),
    );
  }
}
