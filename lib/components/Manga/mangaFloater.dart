import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class Mangafloater extends StatelessWidget {
final dynamic mangaData;
final String? id;

  const Mangafloater({super.key, this.mangaData, this.id});


  @override
  Widget build(BuildContext context) {
    if(mangaData == null){
      return Container(
        margin: const EdgeInsets.only(top: 150),
        child: const SizedBox.shrink());
    }
    final String chapterId = mangaData['chapterId'] ?? 'chapter-1';

    return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            margin: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: TextScroll(
                              mangaData['name'],
                              mode: TextScrollMode.bouncing,
                              velocity: const Velocity(
                                  pixelsPerSecond: Offset(20, 0)),
                              delayBefore: const Duration(milliseconds: 500),
                              pauseBetween:
                                  const Duration(milliseconds: 1000),
                              textAlign: TextAlign.center,
                              selectable: true,
                            ),
                          ),
                          const Text(
                            'Chapter 1',
                            style: TextStyle(
                                color: Color.fromARGB(187, 141, 135, 135)),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/read',
                              arguments: {"mangaId": id, "chapterId": chapterId});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Theme.of(context).colorScheme.inverseSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Ionicons.book,
                               color: Theme.of(context).colorScheme.inversePrimary, // Icon color
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Read',
                              style: TextStyle(
                                 color: Theme.of(context).colorScheme.surface, // Text color
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }
}