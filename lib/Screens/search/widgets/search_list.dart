import 'dart:ui';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SearchList extends StatelessWidget {
  final List<Anime> data;
  final bool isManga;
  const SearchList({super.key, required this.data, required this.isManga});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return _buildAnimeCard(context, item, index);
        },
      ),
    );
  }

  Widget _buildAnimeCard(BuildContext context, Anime item, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            isManga
                ? Get.to(() => MangaDetailsScreen(
                      tagg: 'anime_${item.id}',
                      smallMedia: CarousaleData(
                          id: item.id!, image: item.image!, title: item.title!),
                    ))
                : Get.to(() => AnimeDetailsScreen(
                      tagg: 'anime_${item.id}',
                      smallMedia: CarousaleData(
                          id: item.id!, image: item.image!, title: item.title!),
                    ));
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: colorScheme.surfaceContainerLow,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  _buildBackgroundImage(item, colorScheme),
                  _buildGradientOverlay(colorScheme),
                  _buildContent(context, item, colorScheme),
                  _buildRatingBadge(item, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(Anime item, ColorScheme colorScheme) {
    return Positioned.fill(
      child: item.bannerImage != null
          ? ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: CachedNetworkImage(
                imageUrl: item.bannerImage!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withOpacity(0.3),
                        colorScheme.secondaryContainer.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.3),
                    colorScheme.secondaryContainer.withOpacity(0.2),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGradientOverlay(ColorScheme colorScheme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              colorScheme.surface.withOpacity(0.95),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Anime item, ColorScheme colorScheme) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildPosterImage(item),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimeInfo(item, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage(Anime item) {
    return Hero(
      tag: 'anime_${item.id}',
      child: Container(
        width: 80,
        height: 108,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: item.image != null
              ? CachedNetworkImage(
                  imageUrl: item.image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.withOpacity(0.2),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.withOpacity(0.2),
                    child: const Icon(Icons.broken_image, size: 32),
                  ),
                )
              : Container(
                  color: Colors.grey.withOpacity(0.2),
                  child: const Icon(Icons.image, size: 32),
                ),
        ),
      ),
    );
  }

  Widget _buildAnimeInfo(Anime item, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _truncateTitle(item.title ?? 'Unknown Title'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip(
              icon: Icons.play_circle_outline,
              text: '${item.episodes ?? 0} ${isManga ? 'ch' : 'eps'} ',
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 8),
            if (item.status != null)
              _buildInfoChip(
                icon: Icons.circle,
                text: _formatStatus(item.status!),
                colorScheme: colorScheme,
                isStatus: true,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (item.genres != null && item.genres!.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.genres!
                .take(2)
                .map((genre) => _buildGenreTag(genre, colorScheme))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
    bool isStatus = false,
  }) {
    Color chipColor = isStatus
        ? _getStatusColor(text, colorScheme)
        : colorScheme.primaryContainer.withOpacity(0.8);

    Color textColor = isStatus
        ? _getStatusTextColor(text, colorScheme)
        : colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreTag(String genre, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Text(
        genre,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(Anime item, ColorScheme colorScheme) {
    if (item.rating == null) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 14,
              color: Colors.amber.shade400,
            ),
            const SizedBox(width: 4),
            Text(
              item.rating!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateTitle(String title) {
    return title.length > 45 ? '${title.substring(0, 42)}...' : title;
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Complete';
      case 'ongoing':
        return 'Ongoing';
      case 'upcoming':
        return 'Upcoming';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.green.withOpacity(0.8);
      case 'ongoing':
        return Colors.blue.withOpacity(0.8);
      case 'upcoming':
        return Colors.orange.withOpacity(0.8);
      default:
        return colorScheme.primaryContainer.withOpacity(0.8);
    }
  }

  Color _getStatusTextColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.green.shade800;
      case 'ongoing':
        return Colors.blue.shade800;
      case 'upcoming':
        return Colors.orange.shade800;
      default:
        return colorScheme.onPrimaryContainer;
    }
  }
}
