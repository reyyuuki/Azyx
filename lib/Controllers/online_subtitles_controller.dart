import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    as bridge;
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Settings/Pages/subtitle_settings.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/m3_slider.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

enum _SubtitleSheetTab { source, embedded, style }

class EnhancedSubtitleBottomSheet extends StatefulWidget {
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
  State<EnhancedSubtitleBottomSheet> createState() =>
      _EnhancedSubtitleBottomSheetState();
}

class _EnhancedSubtitleBottomSheetState
    extends State<EnhancedSubtitleBottomSheet> {
  _SubtitleSheetTab _tab = _SubtitleSheetTab.source;

  List<bridge.Track> _resolveSourceSubtitles() {
    final urls = widget.animeData.value.episodeUrls;
    if (urls.isEmpty) return const [];
    final current = urls.firstWhereOrNull(
      (v) => v.url == widget.animeData.value.url,
    );
    final subs = current?.subtitles ?? urls.first.subtitles ?? const [];
    if (subs.isNotEmpty) return subs;
    final allSubs = <bridge.Track>[];
    final seen = <String>{};
    for (final v in urls) {
      for (final s in (v.subtitles ?? const <bridge.Track>[])) {
        final key = '${s.file}_${s.label}';
        if (seen.add(key)) allSubs.add(s);
      }
    }
    return allSubs;
  }

  List<SubtitleTrack> _resolveEmbeddedTracks() {
    return widget.player.state.tracks.subtitle
        .where((t) => t.id != 'no' && t.id != 'auto')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.82,
      constraints: const BoxConstraints(maxWidth: 560),
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
                  Icons.subtitles_rounded,
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
                      text: 'Subtitles',
                      fontVariant: FontVariant.bold,
                      fontSize: 17,
                      color: cs.onSurface,
                    ),
                    Text(
                      'Select track or customize appearance',
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
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.18),
                width: 0.6,
              ),
            ),
            child: Row(
              children: [
                _buildTabButton(cs, _SubtitleSheetTab.source, 'Source'),
                _buildTabButton(cs, _SubtitleSheetTab.embedded, 'Embedded'),
                _buildTabButton(cs, _SubtitleSheetTab.style, 'Style'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: switch (_tab) {
              _SubtitleSheetTab.source => _buildSourceTab(cs),
              _SubtitleSheetTab.embedded => _buildEmbeddedTab(cs),
              _SubtitleSheetTab.style => _buildStyleTab(cs),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    ColorScheme cs,
    _SubtitleSheetTab tab,
    String label,
  ) {
    final isSelected = _tab == tab;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _tab = tab);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? cs.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceTab(ColorScheme cs) {
    final sourceSubs = _resolveSourceSubtitles();
    return Obx(() {
      final currentLabel = widget.selectedSbt.value;
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTrackCard(
            cs,
            title: 'Off (No Subtitles)',
            subtitle: 'Hide all subtitle tracks',
            icon: Icons.subtitles_off_rounded,
            isSelected: currentLabel.isEmpty,
            onTap: () {
              widget.selectedSbt.value = '';
              widget.player.setSubtitleTrack(SubtitleTrack.no());
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          if (sourceSubs.isEmpty)
            _buildEmptyBox(
              cs,
              icon: Icons.cloud_off_rounded,
              title: 'No source subtitles found',
              subtitle:
                  'Try switching to Embedded tracks or another server link.',
            )
          else
            ...sourceSubs.map((sub) {
              final label = (sub.label?.trim().isNotEmpty ?? false)
                  ? sub.label!.trim()
                  : 'Subtitle';
              final file = sub.file ?? '';
              final isSelected = currentLabel == label;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTrackCard(
                  cs,
                  title: label,
                  subtitle: 'External source track',
                  icon: Icons.closed_caption_rounded,
                  isSelected: isSelected,
                  onTap: () {
                    if (file.isEmpty) return;
                    widget.selectedSbt.value = label;
                    widget.player.setSubtitleTrack(
                      SubtitleTrack.uri(file, title: label),
                    );
                    Navigator.pop(context);
                  },
                ),
              );
            }),
        ],
      );
    });
  }

  Widget _buildEmbeddedTab(ColorScheme cs) {
    final embedded = _resolveEmbeddedTracks();
    final activeId = widget.player.state.track.subtitle.id;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTrackCard(
          cs,
          title: 'Off (No Subtitles)',
          subtitle: 'Disable embedded subtitle track',
          icon: Icons.subtitles_off_rounded,
          isSelected: activeId == 'no',
          onTap: () {
            widget.selectedSbt.value = '';
            widget.player.setSubtitleTrack(SubtitleTrack.no());
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 10),
        if (embedded.isEmpty)
          _buildEmptyBox(
            cs,
            icon: Icons.subtitles_off_outlined,
            title: 'No embedded tracks',
            subtitle: 'This video stream has no muxed subtitle tracks.',
          )
        else
          ...embedded.map((track) {
            final title = (track.title?.trim().isNotEmpty ?? false)
                ? track.title!.trim()
                : (track.language?.trim().isNotEmpty ?? false)
                ? track.language!.toUpperCase()
                : 'Track ${track.id}';
            final sub = (track.language?.trim().isNotEmpty ?? false)
                ? 'Language: ${track.language!.toUpperCase()}'
                : 'Embedded track #${track.id}';
            final isSelected = activeId == track.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTrackCard(
                cs,
                title: title,
                subtitle: sub,
                icon: Icons.subtitles_rounded,
                isSelected: isSelected,
                onTap: () {
                  widget.selectedSbt.value = title;
                  widget.player.setSubtitleTrack(track);
                  Navigator.pop(context);
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStyleTab(ColorScheme cs) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.2),
              width: 0.6,
            ),
          ),
          child: Column(
            children: [
              _buildQuickSlider(
                cs,
                title: 'Font Size',
                min: 12,
                max: 32,
                divisions: 20,
                valueGetter: () => settingsController.subtitleFontSize.value,
                labelBuilder: (v) => '${v.round()} px',
                onChanged: settingsController.setSubtitleFontSize,
              ),
              Divider(
                height: 16,
                thickness: 0.5,
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
              _buildQuickSlider(
                cs,
                title: 'Background Opacity',
                min: 0.0,
                max: 1.0,
                divisions: 10,
                valueGetter: () => settingsController.subtitleBgOpacity.value,
                labelBuilder: (v) => '${(v * 100).round()}%',
                onChanged: settingsController.setSubtitleBgOpacity,
              ),
              Divider(
                height: 16,
                thickness: 0.5,
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
              _buildQuickSlider(
                cs,
                title: 'Bottom Margin',
                min: 8,
                max: 80,
                divisions: 18,
                valueGetter: () =>
                    settingsController.subtitleBottomMargin.value,
                labelBuilder: (v) => '${v.round()} px',
                onChanged: settingsController.setSubtitleBottomMargin,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.pop(context);
            Get.to(() => const SubtitleSettingsPage());
          },
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('Open Full Subtitle Styling'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSlider(
    ColorScheme cs, {
    required String title,
    required double min,
    required double max,
    required int divisions,
    required double Function() valueGetter,
    required String Function(double) labelBuilder,
    required ValueChanged<double> onChanged,
  }) {
    return Obx(() {
      final val = valueGetter().clamp(min, max);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                labelBuilder(val),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CustomSlider(
            min: min,
            max: max,
            divisions: divisions,
            value: val,
            theme: const M3SliderTheme(
              height: 18,
              trackHeight: 5,
              outerRadius: 5,
              innerRadius: 2,
              thumbGap: 6,
              edgeInset: 2,
              thumbWidth: 4,
              thumbHeight: 18,
              thumbCornerRadius: 2,
            ),
            onChanged: onChanged,
          ),
        ],
      );
    });
  }

  Widget _buildTrackCard(
    ColorScheme cs, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? cs.primary.withValues(alpha: 0.14)
          : cs.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      : cs.surfaceContainerHighest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  size: 19,
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
                        color: isSelected ? cs.primary : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBox(
    ColorScheme cs, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.18),
          width: 0.6,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
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
