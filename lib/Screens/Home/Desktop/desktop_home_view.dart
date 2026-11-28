import 'package:azyx/Widgets/header.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Screens/search/search_screen.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopHomeView extends StatefulWidget {
  const DesktopHomeView({super.key});

  @override
  State<DesktopHomeView> createState() => _DesktopHomeViewState();
}

class _DesktopHomeViewState extends State<DesktopHomeView> {
  int _selectedDay = 0;

  static const List<String> _genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural',
  ];

  void _resumeOrOpen(
    BuildContext context,
    LocalHistoryItem? historyItem,
    UserMedia? onlineItem,
  ) {
    if (historyItem != null) {
      if (historyItem.episodeUrlsJson != null &&
          historyItem.episodeUrlsJson!.isNotEmpty) {
        try {
          final decodedList = jsonDecode(historyItem.episodeUrlsJson!) as List;
          final List<Video> episodeUrls = decodedList
              .map((e) => Video.fromJson(e as Map<String, dynamic>))
              .toList();
          Get.to(
            () => WatchScreen(
              playerData: AnimeAllData(
                id: historyItem.mediaId?.toString() ?? '',
                image: historyItem.image ?? '',
                title: historyItem.title ?? 'Unknown',
                url: historyItem.link ?? '',
                number:
                    RegExp(r'(\d+(?:\.\d+)?)')
                        .firstMatch(historyItem.progress ?? '')
                        ?.group(1) ??
                    '1',
                episodeTitle: historyItem.title,
                source: historyItem.sourceName,
                episodeList: historyItem.episodeList,
                episodeUrls: episodeUrls,
                startFromSeconds: historyItem.currentTimeSeconds,
              ),
            ),
          );
          return;
        } catch (_) {}
      }
      if (historyItem.mediaId != null) {
        Navigator.of(context).push(
          AnimeDetailsScreen.route(
            id: historyItem.mediaId,
            tagg: 'desktop_resume_${historyItem.mediaId}',
          ),
        );
        return;
      }
    }

    if (onlineItem != null && onlineItem.id != null) {
      final parsedId = int.tryParse(onlineItem.id!);
      if (parsedId != null) {
        Navigator.of(context).push(
          AnimeDetailsScreen.route(
            id: parsedId,
            tagg: 'desktop_resume_$parsedId',
          ),
        );
      }
    }
  }

  Widget _buildGreetingHeader(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 950;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 18 ? 'Good afternoon' : 'Good evening');

    return Obx(() {
      final user = serviceHandler.userData.value;
      final name = user.name ?? 'Guest';
      final avatar = user.avatar;

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins-Bold',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => const Header().showBottomSheet(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: (avatar != null && avatar.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: avatar,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.person, size: 22),
                            )
                          : const Icon(Icons.person, size: 22),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Get.to(() => const SearchScreen(isManga: false)),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.15,
                    ),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Broken.search_normal,
                      size: 19,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Search anime',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '/',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Get.to(() => const SearchScreen(isManga: false)),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.15,
                  ),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Broken.search_normal,
                    size: 19,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search anime',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '/',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
  Widget _buildProgressStrip(int current, int total, Color primary) {
    if (total > 0 && total <= 30) {
      return Row(
        children: List.generate(total, (i) {
          final isPast = i < current;
          final isCurrent = i == current;
          return Expanded(
            child: Container(
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: isPast
                    ? primary
                    : (isCurrent
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(2.5),
                border: isCurrent
                    ? Border.all(color: primary, width: 1.2)
                    : null,
              ),
            ),
          );
        }),
      );
    }
    final percent = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: percent,
        minHeight: 5,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(primary),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 950;

    return Obx(() {
      final history = localHistoryController.animeWatchingHistory.toList();
      final userWatching =
          serviceHandler.userAnimeList.currentlyWatching.toList();

      final hasHistory = history.isNotEmpty;
      final hasOnline = userWatching.isNotEmpty;

      final historyItem = hasHistory ? history.first : null;
      final onlineItem = !hasHistory && hasOnline ? userWatching.first : null;

      String title = 'No title playing';
      String image = '';
      String banner = '';
      int nextEp = 1;
      int totalEp = 0;
      String rating = '';

      if (historyItem != null) {
        title = historyItem.title ?? 'Unknown';
        image = historyItem.image ?? '';
        final parsedEp = double.tryParse(
          RegExp(r'(\d+(?:\.\d+)?)')
                  .firstMatch(historyItem.progress ?? '')
                  ?.group(1) ??
              '1',
        )?.toInt();
        nextEp = (parsedEp ?? 1) + 1;
        totalEp = historyItem.episodeList?.length ?? 0;
      } else if (onlineItem != null) {
        title = onlineItem.title ?? 'Unknown';
        image = onlineItem.image ?? '';
        nextEp = (onlineItem.progress ?? 0) + 1;
        totalEp = onlineItem.episodes ?? 0;
        rating = onlineItem.rating ?? '';
      } else {
        final anilist = Get.find<AnilistService>();
    final width = MediaQuery.of(context).size.width;
        if (anilist.spotlight.isNotEmpty) {
          final spot = anilist.spotlight.first;
          title = spot.title ?? 'Featured Title';
          image = spot.image ?? '';
          banner = spot.bannerImage ?? spot.image ?? '';
          rating = spot.rating ?? '';
          totalEp = spot.episodes ?? 0;
        }
      }

      final backdropUrl = banner.isNotEmpty ? banner : image;

      final sideItems = <Widget>[];
      if (hasHistory && history.length > 1) {
        for (var i = 1; i < history.length && i < 5; i++) {
          final it = history[i];
          final curEp = double.tryParse(
                RegExp(r'(\d+(?:\.\d+)?)')
                        .firstMatch(it.progress ?? '')
                        ?.group(1) ??
                    '1',
              )?.toInt() ??
              1;
          sideItems.add(
            _buildSideQueueItem(
              context: context,
              title: it.title ?? 'Unknown',
              image: it.image ?? '',
              nextEp: curEp + 1,
              totalEp: it.episodeList?.length ?? 0,
              onTap: () => _resumeOrOpen(context, it, null),
            ),
          );
        }
      } else if (!hasHistory && userWatching.length > 1) {
        for (var i = 1; i < userWatching.length && i < 5; i++) {
          final it = userWatching[i];
          final curEp = (it.progress ?? 0) + 1;
          sideItems.add(
            _buildSideQueueItem(
              context: context,
              title: it.title ?? 'Unknown',
              image: it.image ?? '',
              nextEp: curEp,
              totalEp: it.episodes ?? 0,
              onTap: () => _resumeOrOpen(context, null, it),
            ),
          );
        }
      }

      final heroCard = Container(
        height: isMobile ? 320 : 440,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(
              alpha: 0.12,
            ),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: (backdropUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: backdropUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.96),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                      stops: const [0.0, 0.45, 0.85],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            hasHistory || hasOnline
                                ? 'Continue watching'
                                : 'Popular right now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ),
                        if (rating.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasHistory || hasOnline) ...[
                          Text(
                            nextEp.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'Poppins-Bold',
                              fontSize: isMobile ? 56 : 96,
                              fontWeight: FontWeight.w800,
                              color: primary.withValues(alpha: 0.35),
                              height: 0.9,
                              letterSpacing: -3,
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasHistory || hasOnline)
                                Text(
                                  'Episode $nextEp next',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: isMobile ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins-Bold',
                                  fontSize: isMobile ? 22 : 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProgressStrip(nextEp - 1, totalEp, primary),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 24,
                              vertical: isMobile ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 22,
                          ),
                          label: Text(
                            hasHistory || hasOnline
                                ? 'Resume'
                                : 'Watch now',
                            style: TextStyle(
                              fontFamily: 'Poppins-Bold',
                              fontSize: isMobile ? 13.5 : 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => _resumeOrOpen(
                            context,
                            historyItem,
                            onlineItem,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 18 : 22,
                              vertical: isMobile ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isMobile ? 13.5 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            final id = historyItem?.mediaId ??
                                int.tryParse(onlineItem?.id ?? '');
                            if (id != null) {
                              Navigator.of(context).push(
                                AnimeDetailsScreen.route(
                                  id: id,
                                  tagg: 'hero_details_$id',
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heroCard,
            if (sideItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Also watching',
                style: TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 86,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sideItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, idx) => SizedBox(
                    width: 260,
                    child: sideItems[idx],
                  ),
                ),
              ),
            ],
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heroCard),
          if (sideItems.isNotEmpty) ...[
            const SizedBox(width: 16),
            Container(
              width: 310,
              height: 440,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer.withValues(
                  alpha: 0.65,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.12,
                  ),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                    child: Text(
                      'Also watching',
                      style: TextStyle(
                        fontFamily: 'Poppins-Bold',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: sideItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, idx) => sideItems[idx],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
  Widget _buildSideQueueItem({
    required BuildContext context,
    required String title,
    required String image,
    required int nextEp,
    required int totalEp,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    double percent = 0.3;
    if (totalEp > 0) {
      percent = ((nextEp - 1) / totalEp).clamp(0.0, 1.0);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 48,
                height: 68,
                child: image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Broken.image, size: 20),
                      )
                    : const Icon(Broken.image, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Episode $nextEp next${totalEp > 0 ? " · ${totalEp - nextEp + 1} left" : ""}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 3.5,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsStrip(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 950;

    return Obx(() {
      final user = serviceHandler.userData.value;
      final animeCount = user.animeCount ?? serviceHandler.userAnimeList.length;
      final episodes = user.episodesWatched ?? 0;
      final minutes = user.minutesWatched ?? 0;
      final days = (minutes / 1440).toStringAsFixed(1);
      final chapters = user.chaptersRead ?? 0;

      if (isMobile) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      animeCount.toString(),
                      'Anime in list',
                    ),
                  ),
                  _buildStatDivider(theme),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      episodes.toString(),
                      'Episodes watched',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      days,
                      'Days spent',
                    ),
                  ),
                  _buildStatDivider(theme),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      chapters.toString(),
                      'Chapters read',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                animeCount.toString(),
                'Anime in your list',
              ),
            ),
            _buildStatDivider(theme),
            Expanded(
              child: _buildStatItem(
                context,
                episodes.toString(),
                'Episodes watched',
              ),
            ),
            _buildStatDivider(theme),
            Expanded(
              child: _buildStatItem(
                context,
                days,
                'Days spent watching',
              ),
            ),
            _buildStatDivider(theme),
            Expanded(
              child: _buildStatItem(
                context,
                chapters.toString(),
                'Chapters read',
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins-Bold',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCollections(BuildContext context) {
    final anilist = Get.find<AnilistService>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 950;
    return Obx(() {
      final user = serviceHandler.userData.value;
      final animeList = serviceHandler.userAnimeList.toList();
      final mangaList = serviceHandler.userMangaList.toList();
      final animeHistory = localHistoryController.animeWatchingHistory.toList();
      final trendingList = anilist.trending.toList();
      final popularList = anilist.popular.toList();
      final trendingMangaList = anilist.trendingM.toList();

      final animeCount = user.animeCount ?? animeList.length;
      final mangaCount = user.mangaCount ?? mangaList.length;

      final animePosters = <String>[];
      for (final e in animeList) {
        if (e.image != null && e.image!.isNotEmpty && !animePosters.contains(e.image)) {
          animePosters.add(e.image!);
          if (animePosters.length == 3) break;
        }
      }
      if (animePosters.length < 3) {
        for (final e in animeHistory) {
          if (e.image != null && e.image!.isNotEmpty && !animePosters.contains(e.image)) {
            animePosters.add(e.image!);
            if (animePosters.length == 3) break;
          }
        }
      }
      if (animePosters.length < 3) {
        for (final e in trendingList) {
          if (e.image != null && e.image!.isNotEmpty && !animePosters.contains(e.image)) {
            animePosters.add(e.image!);
            if (animePosters.length == 3) break;
          }
        }
      }
      if (animePosters.length < 3) {
        for (final e in popularList) {
          if (e.image != null && e.image!.isNotEmpty && !animePosters.contains(e.image)) {
            animePosters.add(e.image!);
            if (animePosters.length == 3) break;
          }
        }
      }
      while (animePosters.isNotEmpty && animePosters.length < 3) {
        animePosters.add(animePosters[0]);
      }

      final mangaPosters = <String>[];
      for (final e in mangaList) {
        if (e.image != null && e.image!.isNotEmpty && !mangaPosters.contains(e.image)) {
          mangaPosters.add(e.image!);
          if (mangaPosters.length == 3) break;
        }
      }
      if (mangaPosters.length < 3) {
        for (final e in trendingMangaList) {
          if (e.image != null && e.image!.isNotEmpty && !mangaPosters.contains(e.image)) {
            mangaPosters.add(e.image!);
            if (mangaPosters.length == 3) break;
          }
        }
      }
      if (mangaPosters.length < 3) {
        for (final e in popularList) {
          if (e.image != null && e.image!.isNotEmpty && !mangaPosters.contains(e.image)) {
            mangaPosters.add(e.image!);
            if (mangaPosters.length == 3) break;
          }
        }
      }
      while (mangaPosters.isNotEmpty && mangaPosters.length < 3) {
        mangaPosters.add(mangaPosters[0]);
      }

      if (isMobile) {
        return Column(
          children: [
            FannedCollectionCard(
              title: 'Anime',
              count: animeCount.toString(),
              actionLabel: 'Open your list',
              posterUrls: animePosters,
              onTap: () {
                index.value = 1;
              },
            ),
            const SizedBox(height: 14),
            FannedCollectionCard(
              title: 'Manga',
              count: mangaCount.toString(),
              actionLabel: 'Open your list',
              posterUrls: mangaPosters,
              onTap: () {
                index.value = 3;
              },
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: FannedCollectionCard(
              title: 'Anime',
              count: animeCount.toString(),
              actionLabel: 'Open your list',
              posterUrls: animePosters,
              onTap: () {
                index.value = 1;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FannedCollectionCard(
              title: 'Manga',
              count: mangaCount.toString(),
              actionLabel: 'Open your list',
              posterUrls: mangaPosters,
              onTap: () {
                index.value = 3;
              },
            ),
          ),
        ],
      );    });
  }

  Widget _buildAiringRail(BuildContext context) {
    final theme = Theme.of(context);

    final days = <String>[
      'Today',
      'Tomorrow',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Airing this week',
                  style: TextStyle(
                    fontFamily: 'Poppins-Bold',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Next episodes of the most popular shows',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          final schedules = anilistDataController.anilistSchedules.toList();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(schedules.length, (idx) {
                final isSelected = _selectedDay == idx;
                final sched = schedules[idx];
                final count = sched.animeList.length;
                final dayLabel = idx < days.length ? days[idx] : sched.date;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedDay = idx;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(
                                  alpha: 0.15,
                                ),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 14),
        Obx(() {
          final schedules = anilistDataController.anilistSchedules.toList();
          if (schedules.isEmpty || _selectedDay >= schedules.length) {
            return const SizedBox.shrink();
          }

          final list = schedules[_selectedDay].animeList;
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No airing anime scheduled for this day.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                final anime = list[idx];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final id = int.tryParse(anime.id ?? '');
                    if (id != null) {
                      Navigator.of(context).push(
                        AnimeDetailsScreen.route(
                          id: id,
                          tagg: 'sched_${anime.id}',
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withValues(
                        alpha: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.1,
                        ),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 58,
                            height: 84,
                            child: (anime.image != null && anime.image!.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: anime.image!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Broken.image, size: 24),
                                  )
                                : const Icon(Broken.image, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                anime.title ?? 'Unknown',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins-Bold',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${anime.type ?? "TV"}${anime.episodes != null ? " · ${anime.episodes} eps" : ""}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGenresSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse by genre',
          style: TextStyle(
            fontFamily: 'Poppins-Bold',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'Jump straight into a mood',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _genres.map((g) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Get.to(() => const SearchScreen(isManga: false)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.14,
                        ),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      g,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRankedRail(
    BuildContext context,
    String title,
    List<Media> animeList,
  ) {
    if (animeList.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins-Bold',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: animeList.length > 10 ? 10 : animeList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final media = animeList[idx];
              final rankNum = (idx + 1).toString();

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final id = int.tryParse(media.id ?? '');
                  if (id != null) {
                    Navigator.of(context).push(
                      AnimeDetailsScreen.route(
                        id: id,
                        tagg: 'rank_${media.id}',
                      ),
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rankNum,
                      style: TextStyle(
                        fontFamily: 'Poppins-Bold',
                        fontSize: 88,
                        fontWeight: FontWeight.w900,
                        color: primary.withValues(alpha: 0.85),
                        height: 0.9,
                        letterSpacing: -4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 140,
                              height: 195,
                              child: media.image != null &&
                                      media.image!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: media.image!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Broken.image, size: 30),
                                    )
                                  : const Icon(Broken.image, size: 30),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            media.title ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final anilist = Get.find<AnilistService>();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 480,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.9),
                  radius: 0.9,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.75],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              width < 950 ? 16 : 28,
              width < 950 ? 16 : 24,
              width < 950 ? 16 : 28,
              width < 950 ? 110 : 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingHeader(context),
                const SizedBox(height: 24),
                _buildHeroSection(context),
                const SizedBox(height: 28),
                _buildStatsStrip(context),
                const SizedBox(height: 28),
                _buildCollections(context),
                const SizedBox(height: 32),
                _buildAiringRail(context),
                const SizedBox(height: 32),
                Obx(() {
                  final trendingList = anilist.trending.toList();
                  return _buildRankedRail(
                    context,
                    'Trending now',
                    trendingList,
                  );
                }),
                const SizedBox(height: 32),
                _buildGenresSection(context),
                const SizedBox(height: 32),
                Obx(() {
                  final popularList = anilist.popular.toList();
                  return AnimeScrollableList(
                    title: 'Popular this season',
                    animeList: popularList,
                    isManga: false,
                  );
                }),
                const SizedBox(height: 28),
                Obx(() {
                  final topList = anilist.topUpcoming.toList();
                  return AnimeScrollableList(
                    title: 'Top rated',
                    animeList: topList,
                    isManga: false,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FannedCollectionCard extends StatefulWidget {
  final String title;
  final String count;
  final String actionLabel;
  final List<String> posterUrls;
  final VoidCallback onTap;

  const FannedCollectionCard({
    super.key,
    required this.title,
    required this.count,
    required this.actionLabel,
    required this.posterUrls,
    required this.onTap,
  });

  @override
  State<FannedCollectionCard> createState() => _FannedCollectionCardState();
}

class _FannedCollectionCardState extends State<FannedCollectionCard> {
  bool _isHovered = false;
  bool _isTapped = false;

  bool get isExpanded => _isHovered || _isTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final urls = widget.posterUrls;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isTapped = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!_isTapped) {
            setState(() => _isTapped = true);
          } else {
            widget.onTap();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 208,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isExpanded
                  ? primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.12),
              width: isExpanded ? 1.2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? primary.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: isExpanded ? 24 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                if (urls.isNotEmpty)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.28,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
                        child: CachedNetworkImage(
                          imageUrl: urls.first,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          theme.colorScheme.surface.withValues(alpha: 0.88),
                          theme.colorScheme.surface.withValues(alpha: 0.22),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  top: 24,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        widget.count,
                        style: const TextStyle(
                          fontFamily: 'Poppins-Bold',
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          letterSpacing: -1.0,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.actionLabel,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            offset: isExpanded ? const Offset(0.2, 0) : Offset.zero,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 0,
                  top: 0,
                  width: 250,
                  child: _buildFan(urls),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFan(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();

    final widgets = <Widget>[];

    final centerUrl = urls.length > 1 ? urls[1] : urls[0];
    final leftUrl = urls[0];
    final rightUrl = urls.length > 2 ? urls[2] : urls[0];

    widgets.add(_buildPoster(
      url: leftUrl,
      left: isExpanded ? 8.0 : 68.0,
      bottom: isExpanded ? -20.0 : -22.0,
      turns: isExpanded ? (-12.5 / 360.0) : 0.0,
      opacity: isExpanded ? 1.0 : 0.0,
    ));

    widgets.add(_buildPoster(
      url: rightUrl,
      left: isExpanded ? 128.0 : 68.0,
      bottom: isExpanded ? -20.0 : -22.0,
      turns: isExpanded ? (12.5 / 360.0) : 0.0,
      opacity: isExpanded ? 1.0 : 0.0,
    ));

    widgets.add(_buildPoster(
      url: centerUrl,
      left: 68.0,
      bottom: -22.0,
      turns: 0.0,
      opacity: 1.0,
    ));

    return Stack(
      clipBehavior: Clip.none,
      children: widgets,
    );
  }

  Widget _buildPoster({
    required String url,
    required double left,
    required double bottom,
    required double turns,
    required double opacity,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      left: left,
      bottom: bottom,
      width: 104.0,
      height: 156.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        opacity: opacity,
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          turns: turns,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 22,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 28, color: Colors.white38),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}