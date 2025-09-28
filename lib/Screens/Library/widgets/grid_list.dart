import 'dart:io';
import 'dart:math';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GridList extends StatelessWidget {
  final String tagg;
  final List<OfflineItem> data;

  final void Function(OfflineItem, String) ontap;
  const GridList({
    super.key,
    required this.data,
    required this.tagg,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.9, maxHeight);
    return Container(
      padding: const EdgeInsets.only(left: 12),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max(itemCount, minCount),
          childAspectRatio: gridWidth / gridHeight,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index].mediaData;
          final taggname = "${item.id}&$tagg";
          final isStatus =
              item.status == "RELEASING" || item.status == "Ongoing";
          return GestureDetector(
            onTap: () => ontap(data[index], taggname),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AzyXContainer(
                        // height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
                        width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
                        margin: const EdgeInsets.only(right: 10),
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
                        child: Hero(
                          tag: taggname,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: item.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => ShimmerEffect(
                                height: Platform.isAndroid || Platform.isIOS
                                    ? 150
                                    : 230,
                                width: Platform.isAndroid || Platform.isIOS
                                    ? 103
                                    : 160,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      item.rating != null
                          ? Positioned(
                              top: 0,
                              left: 0,
                              child: AzyXContainer(
                                height: 22,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright
                                          .withOpacity(0.6),
                                      blurRadius: 10,
                                    ),
                                  ],
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    topLeft: Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AzyXText(
                                        text: item.rating!,
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontVariant: FontVariant.bold,
                                      ),
                                      const Icon(
                                        Icons.star_half,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Positioned(
                        bottom: 0,
                        right: 10,
                        child: AzyXContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isStatus
                                ? const Color.fromARGB(255, 124, 247, 128)
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(15),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AzyXText(
                                text: data[index].number,
                                fontSize: 12,
                                color: isStatus
                                    ? Colors.black
                                    : Theme.of(
                                        context,
                                      ).colorScheme.inverseSurface,
                                fontVariant: FontVariant.bold,
                              ),
                              10.width,
                              Icon(
                                Icons.circle,
                                size: 5,
                                color: isStatus
                                    ? Colors.black
                                    : Theme.of(
                                        context,
                                      ).colorScheme.inverseSurface,
                              ),
                              10.width,
                              AzyXText(
                                text: item.episodes?.toString() ?? "12",
                                fontSize: 12,
                                color: isStatus
                                    ? Colors.black
                                    : Theme.of(
                                        context,
                                      ).colorScheme.inverseSurface,
                                fontVariant: FontVariant.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AzyXText(
                    text: Platform.isAndroid || Platform.isIOS
                        ? (item.title!.length > 12
                              ? '${item.title!.substring(0, 10)}...'
                              : item.title!)
                        : (item.title!.length > 20
                              ? '${item.title!.substring(0, 17)}...'
                              : item.title!),
                    fontVariant: FontVariant.bold,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
