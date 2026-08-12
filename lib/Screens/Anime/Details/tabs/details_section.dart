import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/characters_list.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (mediaData.value.genres != null &&
              mediaData.value.genres!.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: mediaData.value.genres!.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.35,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.08),
                        width: 1,
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
          const SizedBox(height: 22),
          if (mediaData.value.description != null)
            _ExpandableDescription(description: mediaData.value.description!),
          if (mediaData.value.trailerUrl != null &&
              mediaData.value.trailerUrl!.isNotEmpty)
            _TrailerCard(
              trailerUrl: mediaData.value.trailerUrl!,
              thumbnail: mediaData.value.trailerThumbnail,
              fallbackImage:
                  mediaData.value.coverImage ?? mediaData.value.image,
            ),
          _MediaInfoGrid(media: mediaData.value),
          const SizedBox(height: 24),
          CharactersList(
            characterList: mediaData.value.characters ?? [],
            title: "Characters",
          ),
          const SizedBox(height: 20),
          AnimeScrollableList(
            isManga: isManga,
            animeList: mediaData.value.relations ?? [],
            title: "Related",
          ),
          const SizedBox(height: 20),
          AnimeScrollableList(
            isManga: isManga,
            animeList: mediaData.value.recommendations ?? [],
            title: "You might like",
          ),
        ],
      ),
    );
  }
}

class _MediaInfoGrid extends StatelessWidget {
  final AnilistMediaData media;
  const _MediaInfoGrid({required this.media});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final studiosText = media.studios != null && media.studios!.isNotEmpty
        ? media.studios!.join(', ')
        : null;
    final seasonText = media.season;
    final durationText = media.duration != null
        ? '${media.duration} mins'
        : null;
    final sourceText = media.source;

    if (studiosText == null &&
        seasonText == null &&
        durationText == null &&
        sourceText == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AzyXText(
            text: "Studio Details",
            fontSize: 15,
            fontVariant: FontVariant.bold,
          ),
          const SizedBox(height: 14),
          if (studiosText != null)
            _InfoTile(
              label: "Studio",
              value: studiosText,
              icon: Icons.movie_creation_outlined,
            ),
          if (seasonText != null)
            _InfoTile(
              label: "Season",
              value: seasonText,
              icon: Icons.calendar_today_outlined,
            ),
          if (durationText != null)
            _InfoTile(
              label: "Duration",
              value: durationText,
              icon: Icons.timer_outlined,
            ),
          if (sourceText != null)
            _InfoTile(
              label: "Source",
              value: sourceText,
              icon: Icons.menu_book_outlined,
            ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  text: label,
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(height: 2),
                AzyXText(
                  text: value,
                  fontSize: 13,
                  fontVariant: FontVariant.bold,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailerCard extends StatelessWidget {
  final String trailerUrl;
  final String? thumbnail;
  final String? fallbackImage;
  const _TrailerCard({
    required this.trailerUrl,
    this.thumbnail,
    this.fallbackImage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryThumb = (thumbnail != null && thumbnail!.isNotEmpty)
        ? thumbnail!
        : (fallbackImage != null && fallbackImage!.isNotEmpty)
        ? fallbackImage!
        : '';

    return GestureDetector(
      onTap: () =>
          launchUrlString(trailerUrl, mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (primaryThumb.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: primaryThumb,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const ShimmerEffect(height: 140, width: double.infinity),
                  errorWidget: (context, url, error) {
                    if (fallbackImage != null &&
                        fallbackImage!.isNotEmpty &&
                        primaryThumb != fallbackImage) {
                      return CachedNetworkImage(
                        imageUrl: fallbackImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerEffect(
                          height: 140,
                          width: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      );
                    }
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                    );
                  },
                )
              else
                Container(color: colorScheme.surfaceContainerHighest),
              Container(color: Colors.black.withOpacity(0.45)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const AzyXText(
                      text: "Watch Official Trailer",
                      fontVariant: FontVariant.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            AzyXText(
              text: widget.description,
              maxLines: _expanded ? 100 : 3,
              overflow: TextOverflow.ellipsis,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withOpacity(0.9),
            ),
            const SizedBox(height: 6),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
