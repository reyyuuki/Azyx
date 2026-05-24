import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/subtitle.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:media_kit/media_kit.dart';

class EnhancedSubtitleBottomSheet extends StatelessWidget {
  final Rx<AnimeAllData> animeData;
  final Rx<String> selectedSbt;
  final Player player;

  const EnhancedSubtitleBottomSheet({
    super.key,
    required this.animeData,
    required this.selectedSbt,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.subtitles_outlined,
                              color: theme.colorScheme.onPrimary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AzyXText(
                                  text: 'Subtitles',
                                  fontVariant: FontVariant.bold,
                                  fontSize: 28,
                                  color: theme.colorScheme.onSurface,
                                ),
                                const SizedBox(height: 4),
                                AzyXText(
                                  text: 'Choose your preferred subtitle option',
                                  fontVariant: FontVariant.regular,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AzyXText(
                        text: 'Quick Options',
                        fontVariant: FontVariant.bold,
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickOption(
                              context,
                              'None',
                              Icons.subtitles_off_rounded,
                              () {
                                selectedSbt.value = '';
                                player.setSubtitleTrack(SubtitleTrack.no());
                                Get.back();
                              },
                              isSelected: selectedSbt.value.isEmpty,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              if (animeData.value.episodeUrls.first.subtitles != null &&
                  animeData.value.episodeUrls.first.subtitles!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AzyXText(
                      text: 'Available Subtitles',
                      fontVariant: FontVariant.bold,
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              if (animeData.value.episodeUrls.first.subtitles != null &&
                  animeData.value.episodeUrls.first.subtitles!.isNotEmpty)
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (animeData.value.episodeUrls.first.subtitles != null &&
                  animeData.value.episodeUrls.first.subtitles!.isNotEmpty)
                Obx(
                  () => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subtitle =
                            animeData.value.episodeUrls.first.subtitles![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildSubtitleTile(
                            subtitle.label!,
                            subtitle.file!,
                            theme,
                            selectedSbt.value == subtitle.label,
                            () {
                              selectedSbt.value = subtitle.label!;
                              player.setSubtitleTrack(
                                SubtitleTrack.uri(subtitle.file!),
                              );
                              Get.back();
                            },
                          ),
                        );
                      },
                      childCount:
                          animeData.value.episodeUrls.first.subtitles!.length,
                    ),
                  ),
                ),
              if (animeData.value.episodeUrls.first.subtitles == null ||
                  animeData.value.episodeUrls.first.subtitles!.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.subtitles_off_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        AzyXText(
                          text: "No built-in subtitles available",
                          fontSize: 18,
                          fontVariant: FontVariant.bold,
                          textAlign: TextAlign.center,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 8),
            AzyXText(
              text: title,
              fontVariant: FontVariant.bold,
              fontSize: 14,
              textAlign: TextAlign.center,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleTile(
    String title,
    String url,
    ThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              )
            : null,
        color: isSelected ? null : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [
                              theme.colorScheme.onPrimary.withOpacity(0.2),
                              theme.colorScheme.onPrimary.withOpacity(0.1),
                            ]
                          : [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primaryContainer.withOpacity(
                                0.8,
                              ),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withOpacity(0.3)
                          : theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.subtitles_rounded,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AzyXText(
                    text: title,
                    fontVariant: FontVariant.bold,
                    fontSize: 16,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _showOnlineSearchBottomSheet(
  //   BuildContext context,
  //   OnlineSubtitlesController controller,
  // ) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => _buildOnlineSearchSheet(context, controller),
  //   );
  // }
}

void showEnhancedSubtitleSheet(
  Rx<AnimeAllData> animeData,
  Rx<String> selectedSbt,
  BuildContext context, {
  required Player player,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (context) => EnhancedSubtitleBottomSheet(
      animeData: animeData,
      selectedSbt: selectedSbt,
      player: player,
    ),
  );
}
