import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SearchOverlay extends StatelessWidget {
  final AnimeDetailsController controller;
  final void Function(int id) onSelectMedia;

  const SearchOverlay({
    super.key,
    required this.controller,
    required this.onSelectMedia,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (!controller.isSearchOpen.value) return const SizedBox.shrink();

      return FocusScope(
        autofocus: true,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              controller.closeSearch();
            },
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () => controller.closeSearch(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.72),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 620),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius:
                            BorderRadius.circular(AzTokens.radiusSearchBox),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    autofocus: true,
                                    style: AzTokens.body(
                                      color: theme.colorScheme.onSurface,
                                      size: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search anime by title',
                                      hintStyle: AzTokens.body(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        size: 16,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: controller.onSearchInput,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => controller.closeSearch(),
                                ),
                              ],
                            ),
                          ),
                          _buildResults(context, theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildResults(BuildContext context, ThemeData theme) {
    if (controller.isSearching.value) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (controller.searchHasError.value) {
      return Padding(
        padding: const EdgeInsets.all(22),
        child: Text(
          'Search is unavailable right now. Check your connection and try again.',
          style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    final query = controller.searchQuery.value.trim();
    final results = controller.searchResults;

    if (query.isNotEmpty && results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(22),
        child: Text(
          'No titles match that search. Try the romaji name.',
          style: AzTokens.caption(theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final media = results[index];
          final title = media.title ?? media.titleRomaji ?? 'Unknown';
          final format = AzFormatters.formatLabel(media.format);
          final year = media.seasonYear?.toString() ?? '';
          final score = media.meanScore != null && media.meanScore! > 0
              ? '★ ${(media.meanScore! / 10).toStringAsFixed(1)}'
              : '';

          final subtitle = [
            if (format.isNotEmpty) format,
            if (year.isNotEmpty) year,
            if (score.isNotEmpty) score,
          ].join(' · ');

          return InkWell(
            onTap: () {
              if (media.id != null) {
                final id = int.tryParse(media.id!);
                if (id != null) {
                  controller.closeSearch();
                  onSelectMedia(id);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 40,
                      height: 56,
                      child: media.image != null && media.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: media.image!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AzTokens.body(
                            color: theme.colorScheme.onSurface,
                            weight: FontWeight.w600,
                            size: 14.5,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AzTokens.caption(
                              theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
  }
}
