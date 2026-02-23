import 'dart:io';

import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatelessWidget {
  final Character item;
  const CharacterCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AzyXContainer(
              height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
              width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(2, 2))
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: item.image ?? "",
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerEffect(
                    height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
                    width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            item.popularity != null
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    child: AzyXContainer(
                      height: 22,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceBright
                                  .withOpacity(0.6),
                              blurRadius: 10)
                        ],
                        color: Theme.of(context).colorScheme.surfaceBright,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(25)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AzyXText(
                              text: item.popularity.toString(),
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontVariant: FontVariant.bold,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                              shadows: [
                                BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    blurRadius: 10)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 10),
        AzyXText(
          text: item.name != null
              ? item.name!.length > 12
                  ? '${item.name!.substring(0, 10)}...'
                  : item.name!
              : "N/A",
          fontVariant: FontVariant.bold,
        ),
      ],
    );
  }
}
