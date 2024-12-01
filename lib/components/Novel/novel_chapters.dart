import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

class NovelChapters extends StatelessWidget {
  final String? id;
  final dynamic chapter;
  final String? image;
  final String title;

  const NovelChapters(
      {super.key, this.id, this.chapter, this.image, required this.title});

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
                Text(
                  Platform.isAndroid || Platform.isIOS ?
                  (chapter['title'].length > 22
                      ? "${chapter['title'].substring(0, 20)}..."
                      : chapter['title']) : chapter['title'].length > 100
                      ? "${chapter['title'].substring(0, 100)}..."
                      : chapter['title'],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                      child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/novelRead', arguments: {
                        "novelId": id,
                        "chapterLink": chapter['id'],
                        "image": image,
                        "title": title
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
