import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Search/search_screen.dart';
import 'package:flutter/material.dart';

class TagsSection extends StatefulWidget {
  final List<AzMediaTag> tags;
  final bool isManga;
  final void Function(String tagName)? onMuteTag;

  const TagsSection({
    super.key,
    required this.tags,
    this.isManga = false,
    this.onMuteTag,
  });

  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  bool _showAll = false;
  bool _showSpoilers = false;
  String? _expandedTag;
  final Set<String> _mutedTags = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    final allTags = widget.tags;
    if (allTags.isEmpty) return const SizedBox.shrink();

    final spoilerCount = allTags.where((t) => t.isMediaSpoiler).length;
    final eligible = allTags
        .where(
          (t) =>
              !_mutedTags.contains(t.name) &&
              (_showSpoilers || !t.isMediaSpoiler),
        )
        .toList();

    final visibleTags = _showAll ? eligible : eligible.take(7).toList();
    final hasMore = eligible.length > 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('What it is tagged as', style: AzTokens.h2(context)),
        const SizedBox(height: 4),
        Text(
          'The bar shows how many voters agree a tag fits.',
          style: AzTokens.caption(theme.colorScheme.onSurfaceVariant, 13.5),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            final tagListColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visibleTags.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AzTokens.radiusCards),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.2,
                        ),
                        width: 0.6,
                      ),
                    ),
                    child: Text(
                      'No tags visible with current filters.',
                      style: AzTokens.caption(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...visibleTags.map(
                    (tag) => _buildTagRow(context, theme, tones, tag),
                  ),
              ],
            );

            final legendColumn = _buildLegendPanel(
              context,
              theme,
              tones,
              hasMore: hasMore,
              totalCount: eligible.length,
              spoilerCount: spoilerCount,
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: tagListColumn),
                  const SizedBox(width: 28),
                  SizedBox(width: 300, child: legendColumn),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tagListColumn,
                const SizedBox(height: 18),
                legendColumn,
              ],
            );
          },
        ),
      ],
    );
  }

  String? _tierLabel(int rank) {
    if (rank >= 90) return 'DEFINING';
    if (rank >= 85) return 'STRONG';
    return null;
  }

  double _tierOpacity(int rank) {
    if (rank >= 90) return 1.0;
    if (rank >= 85) return 0.78;
    return 0.45;
  }

  Widget _buildTagRow(
    BuildContext context,
    ThemeData theme,
    AzTones tones,
    AzMediaTag tag,
  ) {
    final isExpanded = _expandedTag == tag.name;
    final tier = _tierLabel(tag.rank);
    final fillOpacity = _tierOpacity(tag.rank);
    final fraction = (tag.rank / 100.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 4,
          vertical: isExpanded ? 14 : 8,
        ),
        decoration: BoxDecoration(
          color: isExpanded
              ? theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isExpanded
              ? Border.all(
                  color: tones.accent.withValues(alpha: 0.32),
                  width: 0.8,
                )
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _expandedTag = isExpanded ? null : tag.name;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            tag.name,
                            overflow: TextOverflow.ellipsis,
                            style: AzTokens.body(
                              color: theme.colorScheme.onSurface,
                              weight: FontWeight.w600,
                              size: 14.5,
                            ),
                          ),
                        ),
                        if (tier != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            tier,
                            style: TextStyle(
                              fontFamily: 'Poppins-Bold',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                        if (tag.isMediaSpoiler) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SPOILER',
                              style: TextStyle(
                                fontFamily: 'Poppins-Bold',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${tag.rank}%',
                    textAlign: TextAlign.right,
                    style: AzTokens.body(
                      color: theme.colorScheme.onSurface,
                      weight: FontWeight.w600,
                      size: 13.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.75,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: tones.accent.withValues(alpha: fillOpacity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  '${tag.rank}% of voters agree this fits.',
                  style: AzTokens.caption(
                    theme.colorScheme.onSurfaceVariant,
                    13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SearchScreen(
                              isManga: widget.isManga,
                              initialTag: tag.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 17),
                      label: Text(
                        widget.isManga
                            ? 'Find similar manga'
                            : 'Find similar anime',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: tones.accent,
                        foregroundColor: tones.onAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins-Bold',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mutedTags.add(tag.name);
                          _expandedTag = null;
                        });
                        widget.onMuteTag?.call(tag.name);
                      },
                      icon: const Icon(Icons.volume_off_rounded, size: 16),
                      label: const Text('Mute tag'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendPanel(
    BuildContext context,
    ThemeData theme,
    AzTones tones, {
    required bool hasMore,
    required int totalCount,
    required int spoilerCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                'How to read it',
                style: AzTokens.body(
                  color: theme.colorScheme.onSurface,
                  weight: FontWeight.w600,
                  size: 14.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildLegendRow(theme, tones.accent, 'Defining', '90% and up'),
              const SizedBox(height: 8),
              _buildLegendRow(
                theme,
                tones.accent.withValues(alpha: 0.72),
                'Strong',
                '85% and up',
              ),
              const SizedBox(height: 8),
              _buildLegendRow(
                theme,
                tones.accent.withValues(alpha: 0.35),
                'Supporting',
                'below 85%',
              ),
            ],
          ),
        ),
        if (hasMore || _showAll) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showAll = !_showAll;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              backgroundColor: theme.colorScheme.surfaceContainer,
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              _showAll ? 'Show fewer tags' : 'Show all $totalCount tags',
              style: AzTokens.body(
                color: theme.colorScheme.onSurface,
                weight: FontWeight.w600,
                size: 13.5,
              ),
            ),
          ),
        ],
        if (spoilerCount > 0) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                _showSpoilers
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _showSpoilers
                      ? 'Spoiler tags are shown ($spoilerCount)'
                      : 'Spoiler tags are hidden',
                  style: AzTokens.caption(
                    theme.colorScheme.onSurfaceVariant,
                    12.5,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showSpoilers = !_showSpoilers;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _showSpoilers ? 'Hide' : 'Show',
                  style: AzTokens.body(
                    color: tones.accent,
                    weight: FontWeight.w600,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_mutedTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.volume_off_rounded,
                size: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_mutedTags.length} tag${_mutedTags.length == 1 ? '' : 's'} muted',
                  style: AzTokens.caption(
                    theme.colorScheme.onSurfaceVariant,
                    12.5,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _mutedTags.clear();
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reset',
                  style: AzTokens.body(
                    color: tones.accent,
                    weight: FontWeight.w600,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLegendRow(
    ThemeData theme,
    Color swatchColor,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 6,
          decoration: BoxDecoration(
            color: swatchColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AzTokens.body(
            color: theme.colorScheme.onSurface,
            weight: FontWeight.w600,
            size: 13,
          ),
        ),
        Expanded(
          child: Text(
            ' · $subtitle',
            overflow: TextOverflow.ellipsis,
            style: AzTokens.caption(theme.colorScheme.onSurfaceVariant, 12.5),
          ),
        ),
      ],
    );
  }
}
