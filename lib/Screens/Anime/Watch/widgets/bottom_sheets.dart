import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

String _formatStreamType(String url) {
  final lower = url.toLowerCase();
  if (lower.contains('.m3u8')) return 'HLS';
  if (lower.contains('.mpd')) return 'DASH';
  if (lower.contains('.mp4')) return 'MP4';
  return 'STREAM';
}

void showQualitySheet(
  BuildContext context,
  Rx<AnimeAllData> animeData,
  Player player,
  Rx<Duration> position,
  Rx<bool> isPotraitOrientaion, {
  VoidCallback? onLinkSelected,
}) {
  final cs = Theme.of(context).colorScheme;
  final urls = animeData.value.episodeUrls;
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: isPotraitOrientaion.value
              ? MediaQuery.of(context).size.height * 0.6
              : MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.hd_rounded, color: cs.primary, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AzyXText(
                        text: 'Stream Links & Quality',
                        fontSize: 17,
                        fontVariant: FontVariant.bold,
                        color: cs.onSurface,
                      ),
                      Text(
                        '${urls.length} ${urls.length == 1 ? 'server' : 'servers'} available',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = urls[index];
                  final isSelected = item.url == animeData.value.url;
                  final title =
                      (item.title != null &&
                          item.title!.isNotEmpty &&
                          item.title!.toLowerCase() != 'null')
                      ? item.title!
                      : item.quality;
                  final format = _formatStreamType(item.url);
                  final subCount = item.subtitles?.length ?? 0;
                  return Material(
                    color: isSelected
                        ? cs.primary.withValues(alpha: 0.14)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        onLinkSelected?.call();
                        animeData.value.url = item.url;
                        final baseUrl =
                            sourceController.activeSource.value?.baseUrl ?? '';
                        player.open(
                          Media(
                            item.url,
                            start: position.value,
                            httpHeaders: {
                              'Referer':
                                  item.headers?['referer'] ??
                                  item.headers?['Referer'] ??
                                  baseUrl,
                              'Origin':
                                  item.headers?['origin'] ??
                                  item.headers?['Origin'] ??
                                  baseUrl,
                              'User-Agent':
                                  item.headers?['user-agent'] ??
                                  item.headers?['User-Agent'] ??
                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
                            },
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? cs.primary.withValues(alpha: 0.5)
                                : cs.outlineVariant.withValues(alpha: 0.18),
                            width: isSelected ? 1.2 : 0.6,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primary
                                    : cs.surfaceContainerHighest.withValues(
                                        alpha: 0.7,
                                      ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: isSelected
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? cs.primary
                                          : cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          format,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: cs.primary,
                                          ),
                                        ),
                                      ),
                                      if (subCount > 0) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '$subCount sub',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: cs.primary,
                                size: 20,
                              ),
                          ],
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
    },
  );
}

void showSpeedBottomList(
  BuildContext context,
  List<double> speedList,
  Rx<double> selectedSpeed,
  Player player,
  Rx<bool> isPotraitOrientaion,
) {
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, speedState) {
          return Container(
            constraints: BoxConstraints(
              maxWidth: 460,
              maxHeight: isPotraitOrientaion.value
                  ? MediaQuery.of(context).size.height * 0.56
                  : MediaQuery.of(context).size.height * 0.85,
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.speed_rounded,
                        color: cs.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AzyXText(
                            text: 'Playback Speed',
                            fontVariant: FontVariant.bold,
                            fontSize: 17,
                            color: cs.onSurface,
                          ),
                          Text(
                            'Current: ${selectedSpeed.value}x',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: speedList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final speed = speedList[index];
                      final isSelected = speed == selectedSpeed.value;
                      return Material(
                        color: isSelected
                            ? cs.primary.withValues(alpha: 0.14)
                            : cs.surfaceContainerHighest.withValues(
                                alpha: 0.35,
                              ),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            speedState(() {
                              selectedSpeed.value = speed;
                              player.setRate(speed);
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary.withValues(alpha: 0.5)
                                    : cs.outlineVariant.withValues(alpha: 0.18),
                                width: isSelected ? 1.2 : 0.6,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 19,
                                  color: isSelected
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${speed}x',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? cs.primary
                                          : cs.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: cs.primary,
                                    size: 20,
                                  ),
                              ],
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
        },
      );
    },
  );
}
