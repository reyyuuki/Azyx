import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:flutter/material.dart';

class PosterRowItem {
  final int id;
  final String title;
  final String? coverImage;
  final String? badge;
  final String? subtitle;

  const PosterRowItem({
    required this.id,
    required this.title,
    this.coverImage,
    this.badge,
    this.subtitle,
  });
}

class PosterRow extends StatelessWidget {
  final String title;
  final bool isSubheading;
  final List<PosterRowItem> items;
  final void Function(int id) onItemTapped;

  const PosterRow({
    super.key,
    required this.title,
    this.isSubheading = false,
    required this.items,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSubheading)
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 14),
            child: Text(title, style: AzTokens.h3(context)),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(title, style: AzTokens.h2(context)),
          ),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(AzTokens.radiusPosters),
                onTap: () => onItemTapped(item.id),
                child: SizedBox(
                  width: 132,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AzTokens.radiusPosters),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (item.coverImage != null &&
                                  item.coverImage!.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: item.coverImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                )
                              else
                                Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                              if (item.badge != null &&
                                  item.badge!.isNotEmpty)
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface
                                          .withValues(alpha: 0.78),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: AzTokens.caption(
                                        tones.accent,
                                        12,
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AzTokens.body(
                          color: theme.colorScheme.onSurface,
                          weight: FontWeight.w500,
                          size: 13,
                          height: 1.3,
                        ),
                      ),
                      if (item.subtitle != null &&
                          item.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AzTokens.caption(
                            theme.colorScheme.onSurfaceVariant,
                            12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static List<PosterRowItem> fromRelations(List<AnilistMediaData>? relations) {
    if (relations == null) return [];
    return relations
        .where((r) => r.id != null && int.tryParse(r.id!) != null)
        .map((r) {
          final fmt = AzFormatters.formatLabel(r.type);

          return PosterRowItem(
            id: int.parse(r.id!),
            title: r.title ?? r.titleRomaji ?? 'Unknown',
            coverImage: r.coverImage ?? r.image,
            subtitle: fmt.isNotEmpty ? fmt : null,
          );
        })
        .toList();
  }

  static List<PosterRowItem> fromRecommendations(
      List<AnilistMediaData>? recommendations) {
    if (recommendations == null) return [];
    return recommendations
        .where((r) => r.id != null && int.tryParse(r.id!) != null)
        .map((r) {
          final scoreNum = num.tryParse(r.rating ?? '');
          final scoreBadge = scoreNum != null && scoreNum > 0
              ? '★ ${(scoreNum / 10).toStringAsFixed(1)}'
              : null;

          return PosterRowItem(
            id: int.parse(r.id!),
            title: r.title ?? r.titleRomaji ?? 'Unknown',
            coverImage: r.coverImage ?? r.image,
            badge: scoreBadge,
          );
        })
        .toList();
  }
}
