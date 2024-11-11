import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class NovelChapters extends StatelessWidget {
  final String? id;
  final dynamic chapter;
  final String? image;
  final String title;

   const NovelChapters({super.key, this.id, this.chapter, this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(chapter['link'].toString());
        Navigator.pushNamed(context, '/novelRead', arguments: {
          "novelId": id,
          "chapterLink": chapter['id'],
          "image": image,
          "title": title
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border( left: BorderSide(width: 5, color: Theme.of(context).colorScheme.inverseSurface)),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  
                  child: TextScroll(
                    chapter['title'],
                    mode: TextScrollMode.bouncing,
                    velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                    delayBefore: const Duration(milliseconds: 500),
                    pauseBetween: const Duration(milliseconds: 1000),
                    textAlign: TextAlign.center,
                    selectable: true,
                    style: const TextStyle(fontFamily: "Poppins-Bold"),
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                          child: Row(
                        children: [
                          Icon(
                            Ionicons.book,
                            size: 16,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            'Read',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                               fontFamily: "Poppins-Bold"
                            ),
                          ),
                        ],
                      )),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
