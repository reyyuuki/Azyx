// ignore_for_file: file_names

import 'dart:developer';
import 'package:azyx/Screens/Manga/read.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class Chapterlist extends StatelessWidget {
  final String id;
  final dynamic chapter;
  final String image;
  final Source source;
  final dynamic chapterList;
  final String title;

  const Chapterlist(
      {super.key,
      required this.id,
      required this.chapter,
      required this.image,
      required this.source,
      required this.chapterList,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(chapter['link'].toString());
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Read(
                    mangaId: id,
                    chapterLink: chapter['url'],
                    image: image,
                    chapterList: chapterList,
                    mangatitle: title,
                    source: source)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                  left: BorderSide(
                      width: 5,
                      color: Theme.of(context).colorScheme.inverseSurface)),
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
                    velocity:
                        const Velocity(pixelsPerSecond: Offset(30, 0)),
                    delayBefore: const Duration(milliseconds: 500),
                    pauseBetween: const Duration(milliseconds: 1000),
                    textAlign: TextAlign.center,
                    selectable: true,
                    style: const TextStyle(fontFamily: "Poppins-Bold"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                      child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Read(
                                  mangaId: id,
                                  chapterLink: chapter['url'],
                                  image: image,
                                  chapterList: chapterList,
                                  mangatitle: title,
                                  source: source)));
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
