import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class MangaInfo extends StatelessWidget {
  final dynamic mangaData;

  const MangaInfo({super.key, this.mangaData});

  @override
  Widget build(BuildContext context) {
    if (mangaData == null) {
      return const SizedBox.shrink();
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
                Text("Author: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Status: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Updated: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("View: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(
                  width: 220,
                  child: TextScroll(
                    mangaData['author'],
                    mode: TextScrollMode.bouncing,
                    velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                    delayBefore: const Duration(milliseconds: 500),
                    pauseBetween: const Duration(milliseconds: 1000),
                    textAlign: TextAlign.center,
                    selectable: true,
                    style: const TextStyle( fontFamily: "Poppins-Bold"),
                  ),
                ),
              const SizedBox(
                height: 5,
              ),
              Text(mangaData['status'],style: const TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(mangaData['updated'],style: const TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(mangaData['view'],style: const TextStyle( fontFamily: "Poppins-Bold")),
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
