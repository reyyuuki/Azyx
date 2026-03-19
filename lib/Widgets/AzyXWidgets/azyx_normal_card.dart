import 'dart:io';

import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

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
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: item.image ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerEffect(
                height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
                width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
              ),
              errorWidget: (context, url, error) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: context.theme.colorScheme.primary,
                  ),
                  child: const Icon(Icons.error, color: Colors.white),
                );
              },
            ),
          ),
        ),
        AzyXText(
          text: item.title!,
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
