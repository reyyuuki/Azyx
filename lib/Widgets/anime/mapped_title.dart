import 'dart:io';

import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MappedTitle extends StatelessWidget {
  const MappedTitle({
    super.key,
    required this.name,
    required this.animeTitle,
    required this.totalEpisodes,
  });

  final Rx<String> animeTitle;
  final Rx<String> totalEpisodes;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => SizedBox(
            width: Platform.isAndroid || Platform.isIOS ? 180 : 400,
            child: AzyXText(
              text: "Found: ${animeTitle.value}",
              fontVariant: FontVariant.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Obx(
          () => AzyXText(
            text: "$name: ${totalEpisodes.value}",
            fontVariant: FontVariant.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
