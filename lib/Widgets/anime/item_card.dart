import 'dart:io';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemCard extends StatelessWidget {
  final CarousaleData item;
  final String tagg;
  const ItemCard({super.key, required this.item, required this.tagg});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rMult = uiSettingController.radiusMultiplier;
      final cardRadius = (15.0 * rMult).clamp(4.0, 36.0);

      return Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                AzyXContainer(
                  height: double.infinity,
                  width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: tagg,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cardRadius),
                      child: CachedNetworkImage(
                        imageUrl: item.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ShimmerEffect(
                          height: double.infinity,
                          width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                item.extraData != null
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: AzyXContainer(
                          height: 22,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceBright.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                            color: Theme.of(context).colorScheme.surfaceBright,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(cardRadius * 0.6),
                              topLeft: Radius.circular(cardRadius * 1.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AzyXText(
                                  text: item.extraData!,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontVariant: FontVariant.bold,
                                ),
                                Icon(
                                  Broken.star,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                item.other != null &&
                        (item.other == "RELEASING" || item.other == "Ongoing")
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        child: AzyXContainer(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 95, 209, 99),
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(255, 8, 117, 11),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
            child: AzyXText(
              text: item.title,
              fontVariant: FontVariant.bold,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    });
  }
}
