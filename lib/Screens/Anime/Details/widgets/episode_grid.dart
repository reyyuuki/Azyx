import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_button.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodeGrid extends StatelessWidget {
  final AnimeDetailsController controller;

  const EpisodeGrid({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    return Obx(() {
      final isLoading = controller.isFetchingEpisodes.value;
      final hasError = controller.extensionError.value;
      final episodes = controller.filteredEpisodes;
      final totalEpisodes = controller.episodesList.length;
      final seasons = controller.getAvailableSeasons();
      final types = controller.getAvailableTypes();
      final activeSourceName =
          sourceController.activeSource.value?.name ?? 'No Extension';
      final nextEpNum = controller.getNextEpisodeNumber().toString();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              Text('Episodes', style: AzTokens.h2(context)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AzChip(
                    label: activeSourceName,
                    icon: Icons.extension_rounded,
                    onTap: () => _openSourcePicker(context),
                  ),
                  const SizedBox(width: 8),
                  AzChip(
                    label: 'Wrong title?',
                    icon: Icons.sync_problem_rounded,
                    onTap: () => controller.openWrongTitleDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (seasons.length > 1 || types.length > 1 || totalEpisodes > 12) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  if (seasons.length > 1) ...[
                    AzChip(
                      label: 'All Seasons',
                      isActive: controller.selectedSeason.value.isEmpty,
                      onTap: () => controller.setSeasonFilter(''),
                    ),
                    const SizedBox(width: 8),
                    ...seasons.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AzChip(
                          label: 'Season $s',
                          isActive: controller.selectedSeason.value == s,
                          onTap: () => controller.setSeasonFilter(s),
                        ),
                      );
                    }),
                  ],
                  if (types.length > 1) ...[
                    AzChip(
                      label: 'All Types',
                      isActive: controller.selectedType.value.isEmpty,
                      onTap: () => controller.setTypeFilter(''),
                    ),
                    const SizedBox(width: 8),
                    ...types.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AzChip(
                          label: t,
                          isActive: controller.selectedType.value.toLowerCase() ==
                              t.toLowerCase(),
                          onTap: () => controller.setTypeFilter(t),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (totalEpisodes > 12)
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: TextField(
                style: AzTokens.body(
                  color: theme.colorScheme.onSurface,
                  size: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Filter episodes by number or title...',
                  hintStyle: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: controller.setEpisodeSearch,
              ),
            ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(tones.accent),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fetching episodes from $activeSourceName...',
                      style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else if (hasError)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AzTokens.radiusCards),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 36,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load episodes from $activeSourceName',
                    style: AzTokens.body(
                      color: theme.colorScheme.onSurface,
                      weight: FontWeight.w600,
                      size: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AzButton.primary(
                        label: 'Try Again',
                        icon: Icons.refresh_rounded,
                        onPressed: () => controller.loadExtensionEpisodes(),
                      ),
                      const SizedBox(width: 12),
                      AzButton.tonal(
                        label: 'Switch Extension',
                        icon: Icons.swap_horiz_rounded,
                        onPressed: () => _openSourcePicker(context),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else if (episodes.isEmpty)
            _buildEmptyState(context, theme, tones)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    max(1, (constraints.maxWidth / 240).floor());

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 16 / 13,
                  ),
                  itemBuilder: (context, index) {
                    final ep = episodes[index];
                    final isNextToWatch = ep.number == nextEpNum;

                    return _buildEpisodeCard(
                      context,
                      ep,
                      theme,
                      tones,
                      isNextToWatch: isNextToWatch,
                    );
                  },
                );
              },
            ),
        ],
      );
    });
  }

  Widget _buildEpisodeCard(
    BuildContext context,
    Episode ep,
    ThemeData theme,
    AzTones tones, {
    required bool isNextToWatch,
  }) {
    final titleText = ep.title != null && ep.title!.trim().isNotEmpty
        ? 'Ep ${ep.number} - ${ep.title}'
        : 'Episode ${ep.number}';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => controller.onEpisodeTapped(context, ep),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNextToWatch
                ? tones.accent
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: isNextToWatch ? 2.0 : 0.5,
          ),
          boxShadow: isNextToWatch
              ? [
                  BoxShadow(
                    color: tones.glow.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ep.thumbnail != null && ep.thumbnail!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: ep.thumbnail!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            size: 36,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 36,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (isNextToWatch)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tones.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEXT',
                          style: AzTokens.caption(
                            tones.onAccent,
                            10,
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AzTokens.body(
                      color: theme.colorScheme.onSurface,
                      weight: FontWeight.w600,
                      size: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (ep.type != null && ep.type!.isNotEmpty) ep.type!,
                      if (ep.season != null && ep.season!.isNotEmpty)
                        'Season ${ep.season}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, AzTones tones) {
    final activeSourceName =
        sourceController.activeSource.value?.name ?? 'No Extension';
    final hasSource = sourceController.activeSource.value != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AzTokens.radiusCards),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSource
                ? Icons.movie_filter_outlined
                : Icons.extension_off_outlined,
            size: 44,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            hasSource
                ? 'No episodes found on $activeSourceName'
                : 'No extension selected',
            style: AzTokens.body(
              color: theme.colorScheme.onSurface,
              weight: FontWeight.w600,
              size: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            hasSource
                ? 'Try remapping using "Wrong title?" or switch to another extension.'
                : 'Select an extension to stream episodes for this anime.',
            style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSource) ...[
                AzButton.tonal(
                  label: 'Wrong title?',
                  icon: Icons.sync_problem_rounded,
                  onPressed: () => controller.openWrongTitleDialog(context),
                ),
                const SizedBox(width: 10),
              ],
              AzButton.primary(
                label: hasSource ? 'Switch Extension' : 'Select Extension',
                icon: Icons.extension_rounded,
                onPressed: () => _openSourcePicker(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSourcePicker(BuildContext context) {
    controller.openSourceSelector(context);
  }
}
