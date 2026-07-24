import 'dart:io';
import 'package:azyx/Controllers/services/community_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Screens/community/community_recommendations_page.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/reasons_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
class CommunityScrollableList extends StatelessWidget {
  final String title;
  final MediaType mediaType;
  final String category;
  const CommunityScrollableList({
    super.key,
    required this.title,
    required this.mediaType,
    required this.category,
  });
  List<CommunityMedia> _getItems(CommunityService svc) {
    switch (category) {
      case 'anime':
        return svc.getFilteredCommunityAnimes();
      case 'manga':
        return svc.getFilteredCommunityMangas();
      case 'shows':
        return svc.getFilteredCommunityShows();
      case 'movies':
        return svc.getFilteredCommunityMovies();
      default:
        return [];
    }
  }
  bool _isLoading(CommunityService svc) {
    switch (category) {
      case 'anime':
        return svc.isLoadingAnime.value;
      case 'manga':
        return svc.isLoadingManga.value;
      case 'shows':
        return svc.isLoadingShows.value;
      case 'movies':
        return svc.isLoadingMovies.value;
      default:
        return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final svc = Get.find<CommunityService>();
    final handler = Get.find<ServiceHandler>();
    final serviceType = handler.serviceType.value;
    return Obx(() {
      final loading = _isLoading(svc);
      final items = _getItems(svc);
      if (loading) {
        return const SizedBox(
          height: 210,
          child: Center(child: LoadingIndicatorM3E()),
        );
      }
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Platform.isAndroid || Platform.isIOS ? 18 : 25,
                    fontFamily: "Poppins-Bold",
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [colors.inverseSurface, colors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  color: colors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityRecommendationsPage(
                          category: category,
                          type: mediaType,
                          title: title,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: Platform.isAndroid || Platform.isIOS ? 210 : 280,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length > 10 ? 10 : items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _CommunityScrollItem(
                  item: item,
                  mediaType: mediaType,
                  serviceType: serviceType,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
class _CommunityScrollItem extends StatelessWidget {
  final CommunityMedia item;
  final MediaType mediaType;
  final ServicesType serviceType;
  const _CommunityScrollItem({
    required this.item,
    required this.mediaType,
    required this.serviceType,
  });
  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => mediaType == MediaType.manga
            ? MangaDetailsScreen(
                smallMedia: CarousaleData(
                  id: item.media.id ?? '',
                  image: item.media.image ?? '',
                  title: item.media.title ?? '',
                ),
                tagg: 'community-scroll-${item.media.id}',
                isOffline: false,
              )
            : AnimeDetailsScreen(
                smallMedia: CarousaleData(
                  id: item.media.id ?? '',
                  image: item.media.image ?? '',
                  title: item.media.title ?? '',
                ),
                tagg: 'community-scroll-${item.media.id}',
                isOffline: false,
              ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final author = item.usernameFor(serviceType) ?? '';
    final avatarUrl = item.avatarFor(serviceType);
    return Container(
      width: Platform.isAndroid || Platform.isIOS ? 130 : 180,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetails(context),
              onLongPress: () {
                final id = item.media.id ?? '';
                final isMovieOrShow = id.contains('*');
                final voteId = isMovieOrShow ? id.split('*').first : id;
                final voteType = isMovieOrShow
                    ? (id.endsWith('*MOVIE') ? 'movie' : 'show')
                    : (mediaType == MediaType.manga ? 'manga' : 'anime');
                ReasonsSheet.show(
                  context,
                  item: item,
                  mediaItemType: mediaType,
                  voteMediaId: voteId,
                  voteMediaType: voteType,
                );
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: item.media.image ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, _) =>
                            const Center(child: LoadingIndicatorM3E()),
                        errorWidget: (context, _, __) => Container(
                          color: colors.surfaceContainerLow,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  if (item.hasMultipleReasons)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiaryContainer.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: 10,
                              color: colors.onTertiaryContainer,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${item.reasonCount}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: colors.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (author.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 7,
                              backgroundImage: avatarUrl != null
                                  ? CachedNetworkImageProvider(avatarUrl)
                                  : null,
                              backgroundColor: colors.primary.withOpacity(0.1),
                              child: avatarUrl == null
                                  ? Text(
                                      author[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 6,
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 60),
                              child: Text(
                                author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          AzyXText(
            text: item.displayTitle,
            fontSize: 12,
            fontVariant: FontVariant.bold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
