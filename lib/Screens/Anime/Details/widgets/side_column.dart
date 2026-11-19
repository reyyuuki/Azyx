import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_chip.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SideColumn extends StatelessWidget {
  final AnilistMediaData media;

  const SideColumn({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    final airedStr = AzFormatters.dateRange(
      startYear: media.startYear,
      startMonth: media.startMonth,
      startDay: media.startDay,
      endYear: media.endYear,
      endMonth: media.endMonth,
      endDay: media.endDay,
    );

    final seasonStr = (media.season != null && media.season!.isNotEmpty)
        ? (media.season!.contains(RegExp(r'\d{4}'))
            ? AzFormatters.capitalize(media.season)
            : '${AzFormatters.capitalize(media.season)} ${media.seasonYear ?? ''}'.trim())
        : '–';

    final detailsRows = <MapEntry<String, String>>[
      MapEntry('Format', AzFormatters.formatLabel(media.format ?? media.type)),
      MapEntry('Status', AzFormatters.capitalize(media.status)),
      MapEntry(
        'Episodes',
        media.episodes != null && media.episodes! > 0
            ? media.episodes.toString()
            : 'Ongoing',
      ),
      MapEntry(
        'Duration',
        media.duration != null && media.duration! > 0
            ? '${media.duration} min'
            : '–',
      ),
      MapEntry('Aired', airedStr.isNotEmpty ? airedStr : '–'),
      MapEntry('Season', seasonStr.isNotEmpty ? seasonStr : '–'),
      MapEntry(
        'Studio',
        media.studios != null && media.studios!.isNotEmpty
            ? media.studios!.first
            : '–',
      ),
      MapEntry(
        'Source',
        media.source != null && media.source!.isNotEmpty
            ? AzFormatters.capitalize(media.source)
            : '–',
      ),
      MapEntry('Country', media.countryOfOrigin ?? '–'),
    ];

    final tags = (media.tagsList ?? [])
        .where((t) => !t.isMediaSpoiler)
        .take(7)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AzTokens.radiusCards),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            children: detailsRows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  border: index > 0
                      ? Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.key,
                      style: AzTokens.body(
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: AzTokens.body(
                          color: theme.colorScheme.onSurface,
                          weight: FontWeight.w500,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AzTokens.radiusCards),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Column(
              children: tags.map((tag) {
                final rankPercent = (tag.rank / 100).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              tag.name,
                              overflow: TextOverflow.ellipsis,
                              style: AzTokens.body(
                                color: theme.colorScheme.onSurface,
                                size: 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${tag.rank}%',
                            style: AzTokens.caption(
                              theme.colorScheme.onSurfaceVariant,
                              12.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 5,
                          width: double.infinity,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: rankPercent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: tones.accent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (media.siteUrl != null && media.siteUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          AzChip(
            label: 'View on AniList',
            icon: Icons.open_in_new_rounded,
            onTap: () {
              launchUrlString(
                media.siteUrl!,
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ],
    );
  }
}
