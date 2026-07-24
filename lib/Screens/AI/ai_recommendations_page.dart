import 'dart:io';
import 'package:azyx/AI/ai_pics.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/item_card.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:azyx/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class AiRecommendationsPage extends StatefulWidget {
  final bool isManga;
  const AiRecommendationsPage({super.key, required this.isManga});
  @override
  State<AiRecommendationsPage> createState() => _AiRecommendationsPageState();
}

class _AiRecommendationsPageState extends State<AiRecommendationsPage> {
  final RxList<Media> recommendationsList = RxList();
  final RxBool isAdult = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isGrid = true.obs;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _userSearchController = TextEditingController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadData(1, refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !isLoading.value &&
        hasMore.value) {
      loadData(_currentPage + 1);
    }
  }

  Future<void> loadData(int page, {bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      recommendationsList.clear();
    }
    try {
      final username = _userSearchController.text.trim().isNotEmpty
          ? _userSearchController.text.trim()
          : anilistAuthController.userData.value.name;

      final results = await getAiRecommendations(
        widget.isManga,
        page,
        username: username,
        isAdult: isAdult.value,
        refresh: refresh,
      );

      if (results.isEmpty) {
        hasMore.value = false;
      } else {
        recommendationsList.addAll(results);
        _currentPage = page;
      }
    } catch (e) {
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  String _cleanText(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final double itemHeight = isMobile ? 230 : 310;

    return Scaffold(
      body: AzyXGradientContainer(
        child: Column(
          children: [
            35.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colors.onSurface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => Row(
                        children: [
                          Text(
                            "AI Pics",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          if (recommendationsList.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${recommendationsList.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        isGrid.value
                            ? Icons.view_headline_rounded
                            : Icons.grid_view_rounded,
                        color: colors.primary,
                      ),
                      onPressed: () => isGrid.value = !isGrid.value,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Broken.setting_2, color: colors.onSurface),
                    onPressed: () => settingsBottomSheet(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (recommendationsList.isEmpty && isLoading.value) {
                  return const Center(child: LoadingIndicatorM3E());
                }
                if (recommendationsList.isEmpty && !isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Broken.search_status,
                          size: 48,
                          color: colors.onSurfaceVariant.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        const AzyXText(
                          text: "No recommendations found",
                          fontSize: 16,
                          fontVariant: FontVariant.bold,
                        ),
                        const SizedBox(height: 6),
                        AzyXText(
                          text:
                              "Try searching a username or enabling 18+ content",
                          fontSize: 12,
                          color: colors.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ],
                    ),
                  );
                }

                if (!isGrid.value) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        recommendationsList.length + (isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= recommendationsList.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: LoadingIndicatorM3E()),
                        );
                      }
                      final item = recommendationsList[index];
                      return _buildListItem(colors, item);
                    },
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        (constraints.maxWidth / (isMobile ? 115 : 170))
                            .floor()
                            .clamp(2, 8);
                    final itemWidth = constraints.maxWidth / crossAxisCount;
                    final aspectRatio = itemWidth / itemHeight;
                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 10,
                      ),
                      itemCount:
                          recommendationsList.length +
                          (isLoading.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= recommendationsList.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: LoadingIndicatorM3E(),
                            ),
                          );
                        }
                        final item = recommendationsList[index];
                        final CarousaleData data = CarousaleData(
                          id: item.id ?? '',
                          image: item.image ?? '',
                          title: item.title ?? 'Unknown',
                        );
                        return GestureDetector(
                          onTap: () {
                            widget.isManga
                                ? MangaDetailsScreen(
                                    smallMedia: data,
                                    tagg: (item.title ?? '') + (item.id ?? ''),
                                    isOffline: false,
                                  ).navigate(context)
                                : AnimeDetailsScreen(
                                    smallMedia: data,
                                    tagg: (item.title ?? '') + (item.id ?? ''),
                                    isOffline: false,
                                  ).navigate(context);
                          },
                          child: ItemCard(
                            item: data,
                            tagg: item.id ?? index.toString(),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(ColorScheme colors, Media item) {
    final CarousaleData data = CarousaleData(
      id: item.id ?? '',
      image: item.image ?? '',
      title: item.title ?? 'Unknown',
    );
    final description = _cleanText(item.description);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.12), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            widget.isManga
                ? MangaDetailsScreen(
                    smallMedia: data,
                    tagg: (item.title ?? '') + (item.id ?? ''),
                    isOffline: false,
                  ).navigate(context)
                : AnimeDetailsScreen(
                    smallMedia: data,
                    tagg: (item.title ?? '') + (item.id ?? ''),
                    isOffline: false,
                  ).navigate(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.image ?? '',
                    width: 90,
                    height: 130,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 90,
                      height: 130,
                      color: colors.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (item.rating != null && item.rating != '0.0') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (item.type != null && item.type!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.type!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant.withOpacity(0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (item.genres != null && item.genres!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: item.genres!.take(4).map((g) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void settingsBottomSheet() {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _userSearchController,
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: "Enter AniList Username",
                    hintStyle: TextStyle(
                      color: colors.onSurfaceVariant.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.person_search_rounded,
                      color: colors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search_rounded, color: colors.primary),
                      onPressed: () {
                        Navigator.pop(context);
                        loadData(1, refresh: true);
                      },
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    Navigator.pop(context);
                    loadData(1, refresh: true);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    Icons.eighteen_up_rating,
                    size: 28,
                    color: colors.primary,
                  ),
                  title: const AzyXText(
                    text: "18+ content",
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                  ),
                  subtitle: const AzyXText(
                    text: "Show NSFW content in your recommendations",
                    fontSize: 12,
                  ),
                  trailing: Obx(
                    () => Switch(
                      value: isAdult.value,
                      onChanged: (bool isTrue) async {
                        isAdult.value = isTrue;
                        loadData(1, refresh: true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
