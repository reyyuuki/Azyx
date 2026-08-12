import 'dart:io';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class ScrollableAppBar extends StatelessWidget {
  final Rx<AnilistMediaData> mediaData;
  final String image;
  final String tagg;
  const ScrollableAppBar({
    super.key,
    required this.mediaData,
    required this.image,
    required this.tagg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topPadding =
        MediaQuery.of(context).padding.top +
        (Platform.isIOS || Platform.isAndroid ? 10 : 22);

    return SizedBox(
      height: 330,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Obx(
              () => CachedNetworkImage(
                imageUrl: mediaData.value.coverImage ?? image,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Container(color: colorScheme.surfaceContainerHighest),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.1),
                    colorScheme.surface,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.8,
                ),
              ),
              child: const CustomBackButton(),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 16,
            right: 16,
            child: Obx(() {
              final titleText = mediaData.value.title ?? 'N/A';
              final statusText = mediaData.value.status ?? '';
              final ratingText = mediaData.value.rating;
              final episodesCount = mediaData.value.episodes;
              final typeText = mediaData.value.type;
              final popularity = mediaData.value.popularity;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: tagg,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: CachedNetworkImage(
                            height: 165,
                            width: 115,
                            imageUrl: image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AzyXText(
                          text: titleText,
                          fontVariant: FontVariant.bold,
                          fontSize: 18,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (statusText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(
                                      0.35,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: AzyXText(
                                  text: statusText.toUpperCase(),
                                  fontSize: 10,
                                  fontVariant: FontVariant.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            if (typeText != null && typeText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(
                                      0.12,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: AzyXText(
                                  text: typeText.toUpperCase(),
                                  fontSize: 10,
                                  fontVariant: FontVariant.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (ratingText != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      EvaIcons.star,
                                      size: 12,
                                      color: colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 3),
                                    AzyXText(
                                      text: ratingText,
                                      fontSize: 11,
                                      fontVariant: FontVariant.bold,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ],
                                ),
                              ),
                            if (popularity != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withOpacity(
                                    0.4,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      EvaIcons.heart,
                                      size: 12,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(width: 3),
                                    AzyXText(
                                      text: _formatPopularity(popularity),
                                      fontSize: 11,
                                      fontVariant: FontVariant.bold,
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ],
                                ),
                              ),
                            if (episodesCount != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AzyXText(
                                  text: "$episodesCount Ep",
                                  fontSize: 11,
                                  fontVariant: FontVariant.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatPopularity(int? number) {
    if (number == null) return 'N/A';
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}
