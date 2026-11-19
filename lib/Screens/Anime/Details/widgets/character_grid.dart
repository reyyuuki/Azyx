import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:flutter/material.dart';

class CharacterGrid extends StatelessWidget {
  final List<Character>? characters;

  const CharacterGrid({
    super.key,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = characters ?? [];

    if (list.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Characters', style: AzTokens.h2(context)),
          const SizedBox(height: 14),
          Text(
            'No cast listed yet.',
            style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Characters', style: AzTokens.h2(context)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = max(1, (constraints.maxWidth / 260).floor());

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 84,
              ),
              itemBuilder: (context, index) {
                final character = list[index];
                final role = AzFormatters.capitalize(character.role);
                final vaName = character.voiceActorName;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius:
                        BorderRadius.circular(AzTokens.radiusSmallCards),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: character.image != null &&
                                  character.image!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: character.image!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.person_rounded,
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              character.name ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AzTokens.body(
                                color: theme.colorScheme.onSurface,
                                weight: FontWeight.w600,
                                size: 14.5,
                              ),
                            ),
                            if (role.isNotEmpty)
                              Text(
                                role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AzTokens.caption(
                                  theme.colorScheme.onSurfaceVariant,
                                  12.5,
                                ),
                              ),
                            if (vaName != null && vaName.isNotEmpty)
                              Text(
                                'Voiced by $vaName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AzTokens.caption(
                                  theme.colorScheme.onSurfaceVariant,
                                  12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
