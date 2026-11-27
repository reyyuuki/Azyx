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
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Characters', style: AzTokens.h2(context)),
        const SizedBox(height: 18),
        SizedBox(
          height: 162,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final character = list[index];
              final role = AzFormatters.capitalize(character.role);
              final vaName = character.voiceActorName;
              final subtitleParts = <String>[
                if (role.isNotEmpty) role,
                if (vaName != null && vaName.isNotEmpty) vaName,
              ];
              final subtitle = subtitleParts.join(' · ');

              return SizedBox(
                width: 106,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: ClipOval(
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
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      character.name ?? 'Unknown',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AzTokens.body(
                        color: theme.colorScheme.onSurface,
                        weight: FontWeight.w600,
                        size: 13,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AzTokens.caption(
                          theme.colorScheme.onSurfaceVariant,
                          11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
