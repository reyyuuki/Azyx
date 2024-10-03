import 'dart:ui';

import 'package:daizy_tv/dataBase/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class Floater extends StatelessWidget {
  final dynamic animeData;
  final String id;

  const Floater({super.key, this.animeData, required this.id});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Data>(context);

    if (animeData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 140,),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    if (id == null || id.isEmpty) {
      return const SizedBox.shrink();
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
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
                          animeData['name'] ?? 'Unknown Anime', // Added null check here
                          mode: TextScrollMode.bouncing,
                          velocity: const Velocity(
                            pixelsPerSecond: Offset(20, 0)),
                          delayBefore: const Duration(milliseconds: 500),
                          pauseBetween: const Duration(milliseconds: 1000),
                          textAlign: TextAlign.center,
                          selectable: true,
                        ),
                      ),
                      Text(
                        'Episode ${provider.getCurrentEpisodeForAnime(id) ?? '1'}', // Fixed id and default value
                        style: const TextStyle(
                          color: Color.fromARGB(187, 141, 135, 135)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/stream',
                          arguments: {"id": id});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inverseSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Ionicons.planet,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Watch',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
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
