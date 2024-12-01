import 'dart:developer';

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
        log(chapter['link'].toString());
        Navigator.pushNamed(context, '/read', arguments: {
          "mangaId": id,
          "chapterLink": chapter['link'],
          "image": image,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
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
                    const SizedBox(height: 2,),
                    Text(chapter['date'], style: const TextStyle(fontSize: 12, color: Color.fromARGB(230, 155, 154, 154), fontStyle: FontStyle.italic),)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                      child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/read', arguments: {
                        "mangaId": id,
                        "chapterLink": chapter['link'],
                        "image": image,
                      });
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.onPrimaryContainer),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                        elevation: MaterialStateProperty.all(20)),
                    child: Text(
                      'Read',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontFamily: "Poppins-Bold"),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
