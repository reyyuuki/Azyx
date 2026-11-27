import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:azyx/Screens/Anime/Details/utils/html_sanitizer.dart';
import 'package:flutter/material.dart';

class SynopsisBlock extends StatefulWidget {
  final AnilistMediaData media;
  final bool isLoading;

  const SynopsisBlock({
    super.key,
    required this.media,
    this.isLoading = false,
  });

  @override
  State<SynopsisBlock> createState() => _SynopsisBlockState();
}

class _SynopsisBlockState extends State<SynopsisBlock> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tones = AzTonesProvider.of(context);
    final theme = Theme.of(context);

    final cleanDesc = HtmlSanitizer.clean(
      widget.media.description ?? 'No synopsis available for this title.',
    );

    final nextEpNumber = widget.media.nextEpisodeNumber;
    final nextEpAiringAt = widget.media.nextEpisodeAiringAt;
    final hasNextEpisode = nextEpNumber != null && nextEpAiringAt != null;

    final airingEta = hasNextEpisode
        ? AzFormatters.airingEta(
            nextEpAiringAt - (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          )
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasNextEpisode)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: tones.soft,
              borderRadius: BorderRadius.circular(AzTokens.radiusCards),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: tones.accent,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Episode $nextEpNumber airs in $airingEta',
                    style: AzTokens.body(
                      color: tones.accent,
                      weight: FontWeight.w600,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Synopsis',
          style: AzTokens.h2(context),
        ),
        const SizedBox(height: 14),
        if (widget.isLoading &&
            (widget.media.description == null ||
                widget.media.description!.isEmpty))
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AzTokens.radiusCards),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanDesc,
                  maxLines: _isExpanded ? null : 5,
                  overflow:
                      _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: AzTokens.body(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    size: 14.5,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: tones.soft,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 14,
                      ),
                      child: Text(
                        _isExpanded ? 'Show less' : 'Read more',
                        style: AzTokens.body(
                          color: tones.accent,
                          weight: FontWeight.w600,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
