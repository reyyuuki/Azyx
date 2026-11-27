import 'dart:convert';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Screens/search/search_screen.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

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
                    historyItem.progress?.replaceAll(RegExp(r'[^0-9]'), '') ??
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
            tagg: 'nav_continue_${historyItem.mediaId}',
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
            tagg: 'nav_continue_$parsedId',
          ),
        );
      }
    }
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedIndex == index;
    final primary = theme.colorScheme.primary;
    final unselected = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onDestinationSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 0),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: isExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? primary : unselected,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primary : unselected,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListShortcut({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final theme = Theme.of(context);
    final unselected = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onDestinationSelected(1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: unselected),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: unselected,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: unselected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isExpanded = screenWidth >= 1250;
    final sidebarWidth = isExpanded ? 248.0 : 78.0;

    return Container(
      width: sidebarWidth,
      margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.14),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 14 : 8,
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment: isExpanded
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 6 : 0,
                  vertical: 4,
                ),
                child: isExpanded
                    ? Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/icon.jpg',
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            'assets/images/sticker.png',
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/icon.jpg',
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.to(() => const SearchScreen(isManga: false)),
                child: Container(
                  height: 44,
                  padding: EdgeInsets.symmetric(
                    horizontal: isExpanded ? 12 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: isExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(
                        Broken.search_normal,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      if (isExpanded) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Ctrl K',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildNavItem(
                context: context,
                index: 0,
                icon: Broken.home_1,
                label: 'Home',
                isExpanded: isExpanded,
              ),
              const SizedBox(height: 4),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Broken.element_4,
                label: 'Library',
                isExpanded: isExpanded,
              ),
              const SizedBox(height: 4),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.movie_filter_rounded,
                label: 'Anime',
                isExpanded: isExpanded,
              ),
              const SizedBox(height: 4),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Broken.book,
                label: 'Manga',
                isExpanded: isExpanded,
              ),
              if (isExpanded) ...[
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Your lists',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => _buildListShortcut(
                    context: context,
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Watching',
                    count: serviceHandler
                        .userAnimeList
                        .currentlyWatching
                        .length,
                  ),
                ),
                Obx(
                  () => _buildListShortcut(
                    context: context,
                    icon: Broken.bookmark,
                    label: 'Planning',
                    count: serviceHandler.userAnimeList.planning.length,
                  ),
                ),
                Obx(
                  () => _buildListShortcut(
                    context: context,
                    icon: Broken.heart,
                    label: 'Favourites',
                    count: serviceHandler.userAnimeList.completed.length,
                  ),
                ),
              ],
              const Spacer(),
              Obx(() {
                final history = localHistoryController.animeWatchingHistory;
                final userWatching =
                    serviceHandler.userAnimeList.currentlyWatching;
                if (history.isEmpty && userWatching.isEmpty) {
                  return const SizedBox.shrink();
                }

                final hasLocal = history.isNotEmpty;
                final historyItem = hasLocal ? history.first : null;
                final onlineItem =
                    !hasLocal && userWatching.isNotEmpty
                        ? userWatching.first
                        : null;

                final title = hasLocal
                    ? (history.first.title ?? 'Unknown')
                    : (userWatching.first.title ?? 'Unknown');
                final image = hasLocal
                    ? (history.first.image ?? '')
                    : (userWatching.first.image ?? '');
                final progressStr = hasLocal
                    ? (history.first.progress ?? 'EP 1')
                    : 'Episode ${userWatching.first.progress ?? 1}';

                double progressPercent = 0.35;
                if (hasLocal &&
                    history.first.currentTimeSeconds != null &&
                    history.first.totalDurationSeconds != null &&
                    history.first.totalDurationSeconds! > 0) {
                  progressPercent = (history.first.currentTimeSeconds! /
                          history.first.totalDurationSeconds!)
                      .clamp(0.0, 1.0);
                } else if (onlineItem != null &&
                    onlineItem.progress != null &&
                    onlineItem.episodes != null &&
                    onlineItem.episodes! > 0) {
                  progressPercent =
                      (onlineItem.progress! / onlineItem.episodes!).clamp(
                    0.0,
                    1.0,
                  );
                }

                if (!isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _resumeOrOpen(context, historyItem, onlineItem),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.35,
                            ),
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (image.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 22,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _resumeOrOpen(context, historyItem, onlineItem),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.12,
                          ),
                          width: 0.8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (image.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.88),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins-Bold',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    progressStr,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: progressPercent,
                                      minHeight: 3.5,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => const Header().showBottomSheet(context),
                child: Container(
                  padding: EdgeInsets.all(isExpanded ? 8 : 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(() {
                    final user = serviceHandler.userData.value;
                    final name = user.name ?? 'Guest';
                    final avatar = user.avatar;

                    return Row(
                      mainAxisAlignment: isExpanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: avatar != null && avatar.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: avatar,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Broken.user,
                                      size: 18,
                                    ),
                                  )
                                : const Icon(Broken.user, size: 18),
                          ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins-Bold',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF7DDC9A),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        serviceHandler.isLoggedIn.value
                                            ? 'Connected'
                                            : 'Guest',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
