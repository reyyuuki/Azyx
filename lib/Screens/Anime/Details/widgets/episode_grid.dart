import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_button.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_chip.dart';
import 'package:azyx/Widgets/custom_drop_down.dart';
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
      final ranges = controller.getEpisodeRanges();
      final showRanges =
          ranges.length > 1 && controller.episodeFilter.value.trim().isEmpty;
      final activeSourceName =
          sourceController.activeSource.value?.name ?? 'No Extension';
      final nextEpNum = controller.getNextEpisodeNumber().toString();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text('Episodes', style: AzTokens.h2(context))),
              if (types.isNotEmpty) ...[
                _buildTypeDropdown(context, theme, tones, types),
                const SizedBox(width: 8),
              ],
              AzChip(
                label: 'Wrong title?',
                icon: Icons.sync_problem_rounded,
                onTap: () => controller.openWrongTitleDialog(context),
              ),
            ],
          ),
          if (sourceController.installedExtensions.isNotEmpty) ...[
            const SizedBox(height: 14),
            CustomSourceDropdown(
              items: sourceController.installedExtensions,
              sourceController: sourceController,
              selectedSource: controller.activeSource.value ??
                  sourceController.activeSource.value ??
                  sourceController.installedExtensions.first,
              labelText: 'Source',
              onChanged: (value) {
                if (value != null) {
                  final matched = sourceController.installedExtensions.firstWhere(
                    (i) =>
                        i.id.toString() == value ||
                        "${i.name}_${i.id}" == value ||
                        i.name == value,
                    orElse: () => sourceController.installedExtensions.first,
                  );
                  controller.switchExtension(matched);
                }
              },
            ),
          ],
          const SizedBox(height: 14),
          if (seasons.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
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
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (totalEpisodes > 12)
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 12),
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
          if (showRanges) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  AzChip(
                    label: 'All',
                    isActive: controller.selectedRangeIndex.value == -1,
                    onTap: () => controller.setEpisodeRange(-1),
                  ),
                  const SizedBox(width: 8),
                  ...ranges.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AzChip(
                        label: r.label,
                        isActive: controller.selectedRangeIndex.value == r.index,
                        onTap: () => controller.setEpisodeRange(r.index),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
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
                final isWide = constraints.maxWidth >= 650;
                if (!isWide) {
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: episodes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                }

                final crossAxisCount =
                    constraints.maxWidth >= 1000 ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 86,
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
    final hasTitle = ep.title != null && ep.title!.trim().isNotEmpty;
    final hasThumb = ep.thumbnail != null && ep.thumbnail!.isNotEmpty;
    final primaryText = hasTitle ? ep.title!.trim() : 'Episode ${ep.number}';
    final metaParts = <String>[
      if (hasTitle) 'Ep ${ep.number}',
      if (ep.type != null && ep.type!.isNotEmpty) ep.type!,
      if (ep.season != null && ep.season!.isNotEmpty) 'Season ${ep.season}',
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.onEpisodeTapped(context, ep),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 86,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNextToWatch
                ? tones.soft.withValues(alpha: 0.45)
                : theme.colorScheme.surfaceContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNextToWatch
                  ? tones.accent
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.16),
              width: isNextToWatch ? 1.5 : 0.8,
            ),
            boxShadow: isNextToWatch
                ? [
                    BoxShadow(
                      color: tones.glow.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: SizedBox(
                  width: hasThumb ? 116 : 64,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasThumb)
                        CachedNetworkImage(
                          imageUrl: ep.thumbnail!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Text(
                                ep.number,
                                style: AzTokens.body(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  weight: FontWeight.w700,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: isNextToWatch
                              ? tones.accent.withValues(alpha: 0.16)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.65),
                          child: Center(
                            child: Text(
                              ep.number.padLeft(2, '0'),
                              style: AzTokens.body(
                                color: isNextToWatch
                                    ? tones.accent
                                    : theme.colorScheme.onSurface,
                                weight: FontWeight.w700,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      if (hasThumb)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'EP ${ep.number}',
                              style: AzTokens.caption(
                                Colors.white,
                                10,
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isNextToWatch || metaParts.isNotEmpty)
                      Row(
                        children: [
                          if (isNextToWatch)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tones.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'NEXT',
                                style: AzTokens.caption(
                                  tones.onAccent,
                                  9.5,
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          if (metaParts.isNotEmpty)
                            Expanded(
                              child: Text(
                                metaParts.join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AzTokens.caption(
                                  theme.colorScheme.onSurfaceVariant,
                                  11.5,
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (isNextToWatch || metaParts.isNotEmpty)
                      const SizedBox(height: 3),
                    Text(
                      primaryText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AzTokens.body(
                        color: theme.colorScheme.onSurface,
                        weight: FontWeight.w600,
                        size: 13.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNextToWatch
                      ? tones.accent
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.7),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: isNextToWatch
                      ? tones.onAccent
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
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

  Widget _buildTypeDropdown(
    BuildContext context,
    ThemeData theme,
    AzTones tones,
    List<String> types,
  ) {
    final current = controller.selectedType.value;
    final matched = types.firstWhereOrNull(
      (t) => t.toLowerCase() == current.toLowerCase(),
    );
    final value = matched ?? '';

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: theme.colorScheme.surfaceContainerHigh,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: tones.accent,
          ),
          style: AzTokens.body(
            color: theme.colorScheme.onSurface,
            weight: FontWeight.w600,
            size: 12.5,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('All'),
            ),
            ...types.map(
              (t) => DropdownMenuItem<String>(
                value: t,
                child: Text(t),
              ),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              controller.setTypeFilter(val);
            }
          },
        ),
      ),
    );
  }

  void _openSourcePicker(BuildContext context) {
    controller.openSourceSelector(context);
  }
}
