import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anime_scrollable_list.dart';
import 'package:azyx/Widgets/anime/characters_list.dart';
import 'package:azyx/Widgets/helper/platform_builder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsSection extends StatelessWidget {
  final Rx<AnilistMediaData> mediaData;
  final int index;
  final List<Episode>? episodesList;
  final List<Chapter>? chapterList;
  final String animeTitle;
  final bool isManga;
  const DetailsSection({
    super.key,
    required this.mediaData,
    required this.index,
    required this.animeTitle,
    required this.isManga,
    this.chapterList,
    this.episodesList,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Container(
            width: getResponsiveSize(
              context,
              mobileSize: Get.width - 40,
              dektopSize: 600,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.1),
                      ]
                    : [Colors.white, Colors.white],
              ),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AzyXText(
                  text: mediaData.value.title ?? 'N/A',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  fontSize: 20,
                  fontVariant: FontVariant.bold,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Broken.star,
                        color: Colors.amber,
                        size: 18,
                        shadows: [
                          BoxShadow(
                            color: Colors.amber,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      AzyXText(
                        text: mediaData.value.rating ?? 'N/A',
                        fontSize: 16,
                        fontVariant: FontVariant.bold,
                        color: Colors.amber.shade200,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (mediaData.value.genres != null &&
                    mediaData.value.genres!.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: mediaData.value.genres!.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: getResponsiveSize(
              context,
              mobileSize: Get.width - 40,
              dektopSize: 600,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.04),
                        Colors.white.withOpacity(0.08),
                      ]
                    : [Colors.white, Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildCrystalStat(
                    "Rating",
                    mediaData.value.rating ?? 'N/A',
                    context,
                  ),
                ),
                _buildCrystalDivider(context),
                Expanded(
                  child: _buildCrystalStat(
                    "Popular",
                    mediaData.value.popularity?.toString() ?? 'N/A',
                    context,
                  ),
                ),
                _buildCrystalDivider(context),
                Expanded(
                  child: _buildCrystalStat(
                    "Status",
                    mediaData.value.status ?? 'N/A',
                    context,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.03),
                        Colors.white.withOpacity(0.06),
                      ]
                    : [Colors.white, Colors.white],
              ),
              border: Border.all(
                width: 1,
                color: Colors.white.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AzyXText(
              text: mediaData.value.description ?? "No description available",
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          CharactersList(
            characterList: mediaData.value.characters ?? [],
            title: "Characters",
          ),
          const SizedBox(height: 16),
          AnimeScrollableList(
            isManga: isManga,
            animeList: mediaData.value.relations ?? [],
            title: "Related Animes",
          ),
          const SizedBox(height: 16),
          AnimeScrollableList(
            isManga: isManga,
            animeList: mediaData.value.recommendations ?? [],
            title: "Recommendations",
          ),
        ],
      ),
    );
  }

  Widget _buildCrystalStat(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: AzyXText(
            text: '#$value',
            fontVariant: FontVariant.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCrystalDivider(BuildContext context) {
    return Container(
      height: 50,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        children: [
          Positioned(
            left: -2,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          Container(
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          Positioned(
            top: 22,
            left: -1,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
