import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodeListDrawer extends StatelessWidget {
  final Function(Episode) ontap;
  final Rx<bool> showEpisodesBox;
  final RxList<Episode> filteredEpisodes;
  final Rx<AnimeAllData> animeData;
  final Rx<String> episodeNumber;
  final Rx<bool> isPotraitOrientaion;

  const EpisodeListDrawer({
    super.key,
    required this.ontap,
    required this.showEpisodesBox,
    required this.animeData,
    required this.episodeNumber,
    required this.isPotraitOrientaion,
    required this.filteredEpisodes,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final drawerWidth = isPotraitOrientaion.value
        ? size.width * 0.88
        : (size.width * 0.44).clamp(320.0, 440.0);

    return Obx(
      () => AnimatedPositioned(
        right: showEpisodesBox.value ? 0 : -drawerWidth - 20,
        curve: Curves.easeOutCubic,
        top: 0,
        bottom: 0,
        duration: const Duration(milliseconds: 240),
        child: Container(
          width: drawerWidth,
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.96),
            border: Border(
              left: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.22),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(-6, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.playlist_play_rounded,
                          color: cs.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AzyXText(
                          text: 'Episodes',
                          fontSize: 17,
                          fontVariant: FontVariant.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => showEpisodesBox.value = false,
                        icon: const Icon(Icons.close_rounded, size: 19),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        final all = animeData.value.episodeList ?? [];
                        if (value.trim().isNotEmpty) {
                          final q = value.trim().toLowerCase();
                          filteredEpisodes.value = all
                              .where(
                                (i) =>
                                    i.number.toLowerCase().contains(q) ||
                                    (i.title?.toLowerCase().contains(q) ??
                                        false),
                              )
                              .toList();
                        } else {
                          filteredEpisodes.value = all;
                        }
                      },
                      style: TextStyle(fontSize: 13.5, color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search episode...',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: cs.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 19,
                          color: cs.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredEpisodes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ep = filteredEpisodes[index];
                        final isCurrent = ep.number == episodeNumber.value;
                        final rawImg =
                            (ep.thumbnail != null && ep.thumbnail!.isNotEmpty)
                            ? ep.thumbnail!
                            : (animeData.value.image ?? '');
                        final validUrl =
                            rawImg.isNotEmpty &&
                            (rawImg.startsWith('http://') ||
                                rawImg.startsWith('https://'));
                        return Material(
                          color: isCurrent
                              ? cs.primary.withValues(alpha: 0.14)
                              : cs.surfaceContainerHighest.withValues(
                                  alpha: 0.32,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => ontap(ep),
                            child: Container(
                              height: 82,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCurrent
                                      ? cs.primary.withValues(alpha: 0.5)
                                      : cs.outlineVariant.withValues(
                                          alpha: 0.16,
                                        ),
                                  width: isCurrent ? 1.2 : 0.6,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 108,
                                      height: double.infinity,
                                      child: validUrl
                                          ? CachedNetworkImage(
                                              imageUrl: rawImg,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(
                                                color: cs
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.35),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                    color: cs
                                                        .surfaceContainerHighest,
                                                  ),
                                            )
                                          : Container(
                                              color: cs.surfaceContainerHighest,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isCurrent
                                                    ? cs.primary
                                                    : cs.primary.withValues(
                                                        alpha: 0.14,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'EP ${ep.number}',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isCurrent
                                                      ? cs.onPrimary
                                                      : cs.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          (ep.title?.isNotEmpty ?? false)
                                              ? ep.title!
                                              : 'Episode ${ep.number}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrent
                                                ? cs.primary
                                                : cs.onSurface,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
}
