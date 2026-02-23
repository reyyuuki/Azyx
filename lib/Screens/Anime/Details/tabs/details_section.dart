import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/characters_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class DetailsSection extends StatelessWidget {
  final Rx<AnilistMediaData> mediaData;
  final int index;
  final List<Episode>? episodesList;
  final List<Chapter>? chapterList;
  final String animeTitle;
  final bool isManga;

  const DetailsSection({
    super.key,
    required this.mediaData,
    required this.index,
    required this.animeTitle,
    required this.isManga,
    this.chapterList,
    this.episodesList,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: AzyXText(
              text: mediaData.value.title ?? 'N/A',
              fontSize: 26,
              fontVariant: FontVariant.bold,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: EvaIcons.star,
                value: mediaData.value.rating ?? 'N/A',
                bgColor: colorScheme.tertiaryContainer,
                fgColor: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: EvaIcons.heart,
                value: _formatPopularity(mediaData.value.popularity),
                bgColor: colorScheme.errorContainer,
                fgColor: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: EvaIcons.activity,
                value: mediaData.value.status ?? 'N/A',
                bgColor: colorScheme.primaryContainer,
                fgColor: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (mediaData.value.genres != null &&
              mediaData.value.genres!.isNotEmpty)
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: mediaData.value.genres!.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.45,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.12),
                        width: 0.5,
                      ),
                    ),
                    child: AzyXText(
                      text: genre,
                      fontSize: 12,
                      fontVariant: FontVariant.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 26),
          if (mediaData.value.description != null)
            _ExpandableDescription(description: mediaData.value.description!),
          const SizedBox(height: 30),
          CharactersList(
            characterList: mediaData.value.characters ?? [],
            title: "Characters",
          ),
          const SizedBox(height: 24),
          AnimeScrollableList(
            isManga: isManga,
            animeList: mediaData.value.relations ?? [],
            title: "Related",
          ),
          const SizedBox(height: 24),
          AnimeScrollableList(
            isManga: isManga,
            animeList: mediaData.value.recommendations ?? [],
            title: "You might like",
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color bgColor;
  final Color fgColor;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bgColor.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 15),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String description;
  const _ExpandableDescription({required this.description});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.12),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AzyXText(
                text: widget.description,
                fontSize: 14,
                fontVariant: FontVariant.regular,
                maxLines: _expanded ? 100 : 4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
