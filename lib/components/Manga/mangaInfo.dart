import 'package:flutter/material.dart';

class MangaInfo extends StatelessWidget {
final dynamic mangaData;

   const MangaInfo({super.key,this.mangaData});

  @override
  Widget build(BuildContext context) {
    if (mangaData == null) {
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
                Text("Author: "),
                SizedBox(
                  height: 5,
                ),
                Text("Status: "),
                SizedBox(
                  height: 5,
                ),
                Text("Updated: "),
                SizedBox(
                  height: 5,
                ),
                Text("View: "),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mangaData['author']),
              const SizedBox(
                height: 5,
              ),
              Text(mangaData['status']),
              const SizedBox(
                height: 5,
              ),
              Text(mangaData['status']),
              const SizedBox(
                height: 5,
              ),
              Text(mangaData['view']),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
