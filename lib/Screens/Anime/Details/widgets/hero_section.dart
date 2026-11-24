import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_button.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_chip.dart';
import 'package:azyx/Screens/Anime/Details/widgets/score_ring.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HeroSection extends StatelessWidget {
  final AnilistMediaData media;
  final String primaryLabel;
  final String listButtonLabel;
  final bool isListOn;
  final bool isFavourite;
  final VoidCallback onWatchTap;
  final VoidCallback onListTap;
  final VoidCallback onFavTap;
  final String? heroTag;
  final bool isLoading;

  const HeroSection({
    super.key,
    required this.media,
    required this.primaryLabel,
    required this.listButtonLabel,
    required this.isListOn,
    required this.isFavourite,
    required this.onWatchTap,
    required this.onListTap,
    required this.onFavTap,
    this.heroTag,
    this.isLoading = false,
  });

  Widget _buildDivider(ColorScheme colorScheme, {double height = 24.0}) {
    return Container(
      width: 1.0,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      color: colorScheme.outlineVariant.withValues(alpha: 0.22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = AzTokens.isExpanded(context);
    final isNarrow = width < 680;
    final coverW = AzTokens.coverWidth(width);

    final title = media.title ?? media.titleRomaji ?? '??';
    final nativeTitle = media.titleNative ?? media.titleRomaji ?? '';

    int? resolvedScore;
    if (media.rating != null && media.rating!.trim().isNotEmpty) {
      final parsedDouble = double.tryParse(media.rating!.trim());
      if (parsedDouble != null && parsedDouble > 0) {
        resolvedScore = parsedDouble <= 10.0
            ? (parsedDouble * 10).round()
            : parsedDouble.round();
      }
    }
    if (resolvedScore == null &&
        media.meanScore != null &&
        media.meanScore! > 0) {
      resolvedScore =
          media.meanScore! <= 10 ? media.meanScore! * 10 : media.meanScore;
    }

    final favCount =
        AzFormatters.compactNumber(media.favourites ?? media.popularity);

    final allTimeRankings = (media.rankingsList ?? [])
        .where((r) => r.allTime && r.rank != null)
        .take(2)
        .toList();

    final hasStatus = media.status != null;
    final hasType = media.type != null;
    final hasSeason = media.season != null && media.season!.isNotEmpty;
    final hasEpisodes = media.episodes != null && media.episodes! > 0;
    final hasAnyMeta = hasStatus || hasType || hasSeason || hasEpisodes;

    final hPad = isNarrow ? 16.0 : AzTokens.horizontalPadding;
    final topPad = isNarrow
        ? (MediaQuery.of(context).padding.top + 52.0)
        : AzTokens.heroTopPadding;

    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasAnyMeta)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                if (hasStatus)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: AzChip(
                      label: AzFormatters.formatStatus(media.status),
                      isOn: true,
                    ),
                  ),
                if (hasType)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: AzChip(
                      label: AzFormatters.formatFormat(media.type),
                    ),
                  ),
                if (hasSeason)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: AzChip(label: media.season!),
                  ),
                if (hasEpisodes)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: AzChip(label: '${media.episodes} episodes'),
                  ),
              ],
            ),
          )
        else if (isLoading)
          const Row(
            children: [
              _PlaceholderChip(width: 72.0, height: 26.0),
              SizedBox(width: 6.0),
              _PlaceholderChip(width: 52.0, height: 26.0),
            ],
          ),
        const SizedBox(height: 12.0),
        Text(
          title,
          style: AzTokens.titleStyle(context),
        ),
        if (nativeTitle.isNotEmpty) ...[
          const SizedBox(height: 4.0),
          Text(
            nativeTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AzTokens.body(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              size: 13.0,
            ),
          ),
        ] else if (isLoading) ...[
          const SizedBox(height: 4.0),
          const _PlaceholderLine(width: 100.0, height: 13.0),
        ],
        if (media.genres != null && media.genres!.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: media.genres!
                  .take(6)
                  .map((g) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: AzChip(label: g),
                      ))
                  .toList(),
            ),
          ),
        ] else if (isLoading) ...[
          const SizedBox(height: 12.0),
          const Row(
            children: [
              _PlaceholderChip(width: 64.0, height: 26.0),
              SizedBox(width: 6.0),
              _PlaceholderChip(width: 78.0, height: 26.0),
              SizedBox(width: 6.0),
              _PlaceholderChip(width: 70.0, height: 26.0),
            ],
          ),
        ],
        const SizedBox(height: 16.0),
        if ((resolvedScore != null && resolvedScore > 0) ||
            allTimeRankings.isNotEmpty ||
            favCount.isNotEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (resolvedScore != null && resolvedScore > 0) ...[
                  ScoreRing(
                    score: resolvedScore,
                    size: 44.0,
                    strokeWidth: 3.0,
                  ),
                  _buildDivider(colorScheme),
                ],
                ...allTimeRankings.map((r) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RankingStat(ranking: r, isCompact: false),
                        _buildDivider(colorScheme),
                      ],
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      favCount.isNotEmpty ? favCount : '0',
                      style: AzTokens.statNumber(context),
                    ),
                    Text(
                      'Favourites',
                      style: AzTokens.statCaption(context),
                    ),
                  ],
                ),
              ],
            ),
          )
        else if (isLoading)
          const _PlaceholderStatsRow(),
        if (isDesktop) ...[
          const SizedBox(height: 24.0),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AzButton.primary(
                label: primaryLabel,
                icon: const Icon(Icons.play_arrow_rounded),
                onTap: onWatchTap,
              ),
              AzButton.tonal(
                label: listButtonLabel,
                trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                isOn: isListOn,
                onTap: onListTap,
              ),
              AzButton.square(
                icon: Icon(
                  isFavourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavourite
                      ? AzTonesProvider.of(context).accent
                      : null,
                ),
                isOn: isFavourite,
                onTap: onFavTap,
                semanticsLabel: 'Favourite',
              ),
              if (media.trailerUrl != null && media.trailerUrl!.isNotEmpty)
                AzButton.tonal(
                  label: 'Watch trailer',
                  icon: const Icon(Icons.open_in_new_rounded),
                  onTap: () {
                    launchUrlString(
                      media.trailerUrl!,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
      padding: EdgeInsets.fromLTRB(
        hPad,
        topPad,
        hPad,
        isNarrow ? 12.0 : 18.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
          child: SizedBox(
            width: double.infinity,
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _CoverArt(
                            imageUrl: media.image ?? media.coverImage ?? '',
                            width: 115.0,
                            altTitle: title,
                            heroTag: heroTag,
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins-Bold',
                                    fontSize: 19.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (nativeTitle.isNotEmpty) ...[
                                  const SizedBox(height: 3.0),
                                  Text(
                                    nativeTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AzTokens.body(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.75),
                                      size: 12.0,
                                    ),
                                  ),
                                ],
                                if (hasAnyMeta) ...[
                                  const SizedBox(height: 10.0),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        if (hasStatus)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: AzChip(
                                              label: AzFormatters.formatStatus(
                                                  media.status),
                                              isOn: true,
                                            ),
                                          ),
                                        if (hasType)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: AzChip(
                                              label: AzFormatters.formatFormat(
                                                  media.type),
                                            ),
                                          ),
                                        if (hasSeason)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: AzChip(label: media.season!),
                                          ),
                                        if (hasEpisodes)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: AzChip(
                                                label:
                                                    '${media.episodes} episodes'),
                                          ),
                                      ],
                                    ),
                                  ),
                                ] else if (isLoading) ...[
                                  const SizedBox(height: 10.0),
                                  const Row(
                                    children: [
                                      _PlaceholderChip(
                                          width: 68.0, height: 24.0),
                                      SizedBox(width: 6.0),
                                      _PlaceholderChip(
                                          width: 48.0, height: 24.0),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (media.genres != null &&
                          media.genres!.isNotEmpty) ...[
                        const SizedBox(height: 14.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: media.genres!
                                .take(6)
                                .map((g) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 6.0),
                                      child: AzChip(label: g),
                                    ))
                                .toList(),
                          ),
                        ),
                      ] else if (isLoading) ...[
                        const SizedBox(height: 14.0),
                        const Row(
                          children: [
                            _PlaceholderChip(width: 60.0, height: 24.0),
                            SizedBox(width: 6.0),
                            _PlaceholderChip(width: 72.0, height: 24.0),
                            SizedBox(width: 6.0),
                            _PlaceholderChip(width: 64.0, height: 24.0),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14.0),
                      if ((resolvedScore != null && resolvedScore > 0) ||
                          allTimeRankings.isNotEmpty ||
                          favCount.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.12),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (resolvedScore != null &&
                                  resolvedScore > 0) ...[
                                ScoreRing(
                                  score: resolvedScore,
                                  size: 40.0,
                                  strokeWidth: 2.8,
                                ),
                                _buildDivider(colorScheme, height: 22.0),
                              ],
                              ...allTimeRankings.map((r) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _RankingStat(ranking: r, isCompact: true),
                                      _buildDivider(colorScheme, height: 22.0),
                                    ],
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    favCount.isNotEmpty ? favCount : '0',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins-Bold',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'Favourites',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else if (isLoading)
                        const _PlaceholderStatsRow(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CoverArt(
                        imageUrl: media.image ?? media.coverImage ?? '',
                        width: coverW,
                        altTitle: title,
                        heroTag: heroTag,
                      ),
                      const SizedBox(width: 32.0),
                      Expanded(child: infoColumn),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  final String imageUrl;
  final double width;
  final String altTitle;
  final String? heroTag;

  const _CoverArt({
    required this.imageUrl,
    required this.width,
    required this.altTitle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.48;
    final theme = Theme.of(context);

    Widget art = ClipRRect(
      borderRadius: BorderRadius.circular(AzTokens.radiusCover),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: (width * 2.0).toInt(),
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (_, __) =>
                  Container(color: theme.colorScheme.surfaceContainerHighest),
              errorWidget: (_, __, ___) =>
                  Container(color: theme.colorScheme.surfaceContainerHighest),
            )
          : Container(color: theme.colorScheme.surfaceContainerHighest),
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      art = Hero(
        tag: heroTag!,
        flightShuttleBuilder: (
          flightContext,
          animation,
          flightDirection,
          fromHeroContext,
          toHeroContext,
        ) {
          return Material(
            color: Colors.transparent,
            child: toHeroContext.widget,
          );
        },
        child: art,
      );
    }

    return Semantics(
      label: 'Cover of $altTitle',
      image: true,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AzTokens.radiusCover),
          color: theme.colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 36.0,
              spreadRadius: -10.0,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: art,
      ),
    );
  }
}

class _RankingStat extends StatelessWidget {
  final AzRanking ranking;
  final bool isCompact;

  const _RankingStat({
    required this.ranking,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRated = ranking.type?.toUpperCase() == 'RATED';
    final label = isCompact
        ? (isRated ? 'Top Rated' : 'Popular')
        : (isRated ? 'Top rated of all time' : 'Most popular of all time');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '#${ranking.rank}',
          style: isCompact
              ? const TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                )
              : AzTokens.statNumber(context),
        ),
        Text(
          label,
          style: isCompact
              ? TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : AzTokens.statCaption(context),
        ),
      ],
    );
  }
}

class _PlaceholderChip extends StatelessWidget {
  final double width;
  final double height;

  const _PlaceholderChip({
    required this.width,
    this.height = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AzTokens.radiusChips),
      ),
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  final double width;
  final double height;

  const _PlaceholderLine({
    required this.width,
    this.height = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

class _PlaceholderStatsRow extends StatelessWidget {
  const _PlaceholderStatsRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 3.0,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                width: 58.0,
                height: 11.0,
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                width: 58.0,
                height: 11.0,
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                width: 58.0,
                height: 11.0,
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
