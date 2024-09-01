import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class Chapterlist extends StatelessWidget {
  final String? id;
  final dynamic chapter;
  final String? image;

  const Chapterlist({super.key, this.id, this.chapter, this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/read', arguments: {
          "mangaId": id,
          "chapterId": chapter['path'].toString().substring(
                8,
                chapter['path'].toString().length,
              ),
          "image": image
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 90,
                  child: TextScroll(
                    chapter['name'],
                    mode: TextScrollMode.bouncing,
                    velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                    delayBefore: const Duration(milliseconds: 500),
                    pauseBetween: const Duration(milliseconds: 1000),
                    textAlign: TextAlign.center,
                    selectable: true,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Ionicons.eye,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      chapter['view'],
                    ),
                  ],
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
