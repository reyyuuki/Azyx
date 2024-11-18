import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class NovelInfo extends StatelessWidget {
  final dynamic novelData;

  const NovelInfo({super.key, this.novelData});

  @override
  Widget build(BuildContext context) {
    if (novelData == null) {
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
                Text("Chapters: ",style: TextStyle( fontFamily: "Poppins-Bold")),
                SizedBox(
                  height: 5,
                ),
                Text("Rating: ",style: TextStyle( fontFamily: "Poppins-Bold")),
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
                    novelData['authors'].toString(),
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
              Text(novelData['status'],style: const TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(novelData['chapters'],style: const TextStyle( fontFamily: "Poppins-Bold")),
              const SizedBox(
                height: 5,
              ),
              Text(novelData['rating'],style: const TextStyle( fontFamily: "Poppins-Bold")),
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
