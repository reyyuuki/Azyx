import 'dart:io';

import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AzyXCard extends StatelessWidget {
  final WrongTitleSearch item;
  const AzyXCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AzyXContainer(
          height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
          width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
              imageUrl: item.image!,
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerEffect(
                height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
                width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        AzyXText(
          text: item.tilte!,
          fontVariant: FontVariant.bold,
          fontSize: 12,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
