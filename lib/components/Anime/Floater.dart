import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class Floater extends StatelessWidget {
final dynamic AnimeData;

  const Floater({super.key, this.AnimeData});

  @override
  Widget build(BuildContext context) {
    if(AnimeData == null){
      return Container(
        margin: const EdgeInsets.only(top: 150),
        child: const Center(child: CircularProgressIndicator()));
    }
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
                              AnimeData['info']['name'],
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
                            'Episode 1',
                            style: TextStyle(
                                color: Color.fromARGB(187, 141, 135, 135)),
                          ),
                        ],
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/stream',
                                arguments: {"id": AnimeData['info']['id']});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 17, 16, 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Ionicons.planet,
                                color: Colors.white, // Icon color
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Watch',
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                ),
                              ),
                            ],
                          ),
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