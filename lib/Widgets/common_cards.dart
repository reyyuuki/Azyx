import 'dart:convert';
import 'dart:io';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/AI/ai_recommendations_page.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:azyx/Screens/Home/Calender/calender.dart';
import 'package:azyx/Screens/Home/UserLists/user_lists.dart';
import 'package:azyx/Screens/Manga/Read/view/read.dart';
import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:azyx/Widgets/Animation/scale_animation.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/gradient_title.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
class CalenderCard extends StatelessWidget {
  const CalenderCard({super.key, required this.userData});
  final Rx<User> userData;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => userData.value.name == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.theme.colorScheme.primary.withOpacity(
                        0.15,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withOpacity(
                          0.04,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: context.theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: context.theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: AzyXText(
                                  text: "SPRING 2025",
                                  fontSize: 10,
                                  color: context.theme.colorScheme.primary,
                                  fontVariant: FontVariant.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const AzyXText(
                                text: "Season Highlights",
                                fontSize: 20,
                                color: Colors.white,
                                fontVariant: FontVariant.bold,
                              ),
                              const SizedBox(height: 8),
                              AzyXText(
                                text: "Latest releases of the season",
                                fontSize: 14,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                                fontVariant: FontVariant.regular,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: context.theme.colorScheme.primary
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Get.to(() => const CalenderPage());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    "View All",
                                    style: TextStyle(
                                      color:
                                          context.theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
class UserListsCard extends StatelessWidget {
  const UserListsCard({super.key, required this.userData});
  final Rx<User> userData;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => userData.value.name == null || userData.value.name!.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.theme.colorScheme.primary.withOpacity(
                        0.15,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withOpacity(
                          0.04,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: context.theme.colorScheme.primary
                                  .withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: AzyXText(
                            text: "MY COLLECTIONS",
                            fontSize: 10,
                            color: context.theme.colorScheme.primary,
                            fontVariant: FontVariant.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AzyXText(
                          text: "Your Collections",
                          fontSize: 20,
                          color: Colors.white,
                          fontVariant: FontVariant.bold,
                        ),
                        const SizedBox(height: 8),
                        AzyXText(
                          text:
                              "Access your personalized anime and manga lists",
                          fontSize: 14,
                          color: context.theme.colorScheme.onSurfaceVariant,
                          fontVariant: FontVariant.regular,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: buildModernButton(
                                context: context,
                                title: "Anime",
                                icon: Icons.movie_filter,
                                subtitle: "Your watched shows",
                                onTap: () {
                                  Get.to(() => UserListPage(isManga: false));
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildModernButton(
                                context: context,
                                title: "Manga",
                                icon: Broken.book,
                                subtitle: "Your reading list",
                                onTap: () {
                                  Get.to(() => UserListPage(isManga: true));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
Widget buildModernButton({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final colorScheme = context.theme.colorScheme;
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 12),
            AzyXText(
              text: title,
              fontSize: 16,
              fontVariant: FontVariant.bold,
              color: Colors.white,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AzyXText(
              text: subtitle,
              fontSize: 11,
              fontVariant: FontVariant.regular,
              color: colorScheme.onSurfaceVariant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
class AiSuggestionsCard extends StatelessWidget {
  const AiSuggestionsCard({super.key, required this.userData});
  final Rx<User> userData;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => userData.value.name == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.theme.colorScheme.primary.withOpacity(
                        0.15,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withOpacity(
                          0.04,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: context.theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: context.theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: AzyXText(
                                  text: "DISCOVER",
                                  fontSize: 10,
                                  color: context.theme.colorScheme.primary,
                                  fontVariant: FontVariant.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const AzyXText(
                                text: "AI Media Hub",
                                fontSize: 22,
                                color: Colors.white,
                                fontVariant: FontVariant.bold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              AzyXText(
                                text:
                                    "Personalized recommendations powered by AI",
                                fontSize: 13,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                                fontVariant: FontVariant.regular,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SuggestionButton(
                                      label: "Anime",
                                      onTap: () => Get.to(
                                        () => const AiRecommendationsPage(
                                          isManga: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  8.width,
                                  Expanded(
                                    child: _SuggestionButton(
                                      label: "Manga",
                                      onTap: () => Get.to(
                                        () => const AiRecommendationsPage(
                                          isManga: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
class _SuggestionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  const _SuggestionButton({
    required this.label,
    required this.onTap,
    this.icon = Icons.arrow_forward_rounded,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
class RecentlyWatchedCard extends StatelessWidget {
  const RecentlyWatchedCard({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final history = localHistoryController.animeWatchingHistory;
        if (history.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientTitle(title: "Recently Watched"),
              const SizedBox(height: 15),
              SizedBox(
                height: Platform.isAndroid || Platform.isIOS ? 210 : 280,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final tagg =
                        UniqueKey().toString() + item.mediaId.toString();
                    return SlideAndScaleAnimation(
                      child: GestureDetector(
                        onTap: () {
                          final decodedList = item.episodeUrlsJson != null
                              ? jsonDecode(item.episodeUrlsJson!) as List
                              : [];
                          final List<Video> episodeUrls = decodedList
                              .map(
                                (e) =>
                                    Video.fromJson(e as Map<String, dynamic>),
                              )
                              .toList();
                          Get.to(
                            () => WatchScreen(
                              playerData: AnimeAllData(
                                id: item.mediaId.toString(),
                                image: item.image ?? '',
                                title: item.title ?? 'Unknown',
                                url: item.link ?? '',
                                number:
                                    item.progress?.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    ) ??
                                    '1',
                                episodeTitle: item.title,
                                source: item.sourceName,
                                episodeList: item.episodeList,
                                episodeUrls: episodeUrls,
                                startFromSeconds: item.currentTimeSeconds,
                              ),
                            ),
                          );
                        },
                        child: StaggeredAnimatedItemWrapper(
                          baseDuration: const Duration(milliseconds: 1000),
                          child: _RecentItemCard(
                            imageUrl: item.image ?? '',
                            title: item.title ?? '',
                            progress: item.progress ?? '',
                            tagg: tagg,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
class RecentlyReadCard extends StatelessWidget {
  const RecentlyReadCard({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final history = localHistoryController.mangaReadingHistory;
        if (history.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientTitle(title: "Recently Read"),
              const SizedBox(height: 15),
              SizedBox(
                height: Platform.isAndroid || Platform.isIOS ? 210 : 280,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final tagg =
                        UniqueKey().toString() + item.mediaId.toString();
                    return SlideAndScaleAnimation(
                      child: GestureDetector(
                        onTap: () {
                          final sourceIndex = sourceController
                              .installedMangaExtensions
                              .indexWhere((e) => e.name == item.sourceName);
                          if (sourceIndex != -1 ||
                              item.mangaSourceJson != null) {
                            final Source source = sourceIndex != -1
                                ? sourceController
                                      .installedMangaExtensions[sourceIndex]
                                : Source.fromJson(
                                    jsonDecode(item.mangaSourceJson!),
                                  );
                            Get.to(
                              () => ReadPage(
                                source: source,
                                link: item.link ?? '',
                                chapterList: item.chapterList ?? [],
                                mangaTitle: item.title ?? 'Unknown',
                                mangaImage: item.image ?? '',
                                mediaId: item.mediaId?.toString(),
                                syncId: item.mediaId?.toString(),
                                initialPage: item.currentPage,
                              ),
                            );
                          }
                        },
                        child: StaggeredAnimatedItemWrapper(
                          baseDuration: const Duration(milliseconds: 1000),
                          child: _RecentItemCard(
                            imageUrl: item.image ?? '',
                            title: item.title ?? '',
                            progress: item.progress ?? '',
                            tagg: tagg,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
class _RecentItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String progress;
  final String tagg;
  const _RecentItemCard({
    required this.imageUrl,
    required this.title,
    required this.progress,
    required this.tagg,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AzyXContainer(
              height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
              width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Hero(
                tag: tagg,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ShimmerEffect(
                      height: Platform.isAndroid || Platform.isIOS ? 150 : 230,
                      width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            if (progress.isNotEmpty)
              Positioned(
                bottom: 0,
                right: 0,
                child: AzyXContainer(
                  height: 22,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceBright.withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ],
                    color: Theme.of(context).colorScheme.surfaceBright,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: AzyXText(
                        text: progress,
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.primary,
                        fontVariant: FontVariant.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: Platform.isAndroid || Platform.isIOS ? 103 : 160,
          child: AzyXText(
            text: title,
            fontVariant: FontVariant.bold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
