import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/custom_app_bar.dart';
import 'package:azyx/Widgets/common/m3_slider.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubtitleSettingsPage extends StatelessWidget {
  const SubtitleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 36),
          physics: const BouncingScrollPhysics(),
          children: [
            const CustomAppBar(
              title: 'Subtitle Settings',
              icon: Icons.subtitles_rounded,
            ),
            _buildSectionHeader(context, 'LIVE PREVIEW'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Obx(() {
                final fontSize = settingsController.subtitleFontSize.value;
                final textColor = settingsController.resolveSubtitleTextColor();
                final bgColor = settingsController.resolveSubtitleBgColor();
                final outlineColor =
                    settingsController.resolveSubtitleOutlineColor();
                final outlineWidth =
                    settingsController.subtitleOutlineWidth.value;
                final bottomMargin =
                    settingsController.subtitleBottomMargin.value;
                final opacity = settingsController.subtitleOpacity.value;
                return Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A233A),
                        Color(0xFF2B1D3D),
                        Color(0xFF10141F),
                      ],
                    ),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            (bottomMargin * 0.6).clamp(8.0, 48.0),
                          ),
                          child: Opacity(
                            opacity: opacity.clamp(0.1, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (outlineWidth > 0)
                                    Text(
                                      'Dedicate your hearts!\nShinzou wo Sasageyo!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = outlineWidth * 2
                                          ..color = outlineColor,
                                      ),
                                    ),
                                  Text(
                                    'Dedicate your hearts!\nShinzou wo Sasageyo!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            _buildSectionHeader(context, 'TYPOGRAPHY & LAYOUT'),
            _buildGroupedCard(
              context,
              children: [
                _buildSliderTile(
                  context,
                  title: 'Font Size',
                  subtitle: 'Adjust subtitle text size',
                  icon: Icons.format_size_rounded,
                  iconColor: cs.primary,
                  min: 12,
                  max: 32,
                  divisions: 20,
                  valueGetter: () => settingsController.subtitleFontSize.value,
                  labelBuilder: (v) => '${v.round()} px',
                  onChanged: settingsController.setSubtitleFontSize,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Outline Thickness',
                  subtitle: 'Stroke width around characters',
                  icon: Icons.border_color_rounded,
                  iconColor: cs.secondary,
                  min: 0,
                  max: 4,
                  divisions: 8,
                  valueGetter: () =>
                      settingsController.subtitleOutlineWidth.value,
                  labelBuilder: (v) => v.toStringAsFixed(1),
                  onChanged: settingsController.setSubtitleOutlineWidth,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Bottom Margin',
                  subtitle: 'Distance from bottom edge',
                  icon: Icons.vertical_align_bottom_rounded,
                  iconColor: cs.tertiary,
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
            _buildSectionHeader(context, 'COLORS & OPACITY'),
            _buildGroupedCard(
              context,
              children: [
                _buildColorPickerTile(
                  context,
                  title: 'Text Color',
                  icon: Icons.text_fields_rounded,
                  iconColor: cs.primary,
                  selectedGetter: () =>
                      settingsController.subtitleTextColor.value,
                  options: const ['White', 'Yellow', 'Cyan', 'Green', 'Pink'],
                  onSelected: settingsController.setSubtitleTextColor,
                ),
                _buildDivider(context),
                _buildColorPickerTile(
                  context,
                  title: 'Background Color',
                  icon: Icons.format_color_fill_rounded,
                  iconColor: cs.secondary,
                  selectedGetter: () =>
                      settingsController.subtitleBgColor.value,
                  options: const ['Black', 'Transparent', 'White'],
                  onSelected: settingsController.setSubtitleBgColor,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Background Opacity',
                  subtitle: 'Backdrop box transparency',
                  icon: Icons.opacity_rounded,
                  iconColor: cs.tertiary,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  valueGetter: () =>
                      settingsController.subtitleBgOpacity.value,
                  labelBuilder: (v) => '${(v * 100).round()}%',
                  onChanged: settingsController.setSubtitleBgOpacity,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Subtitle Opacity',
                  subtitle: 'Overall subtitle visibility',
                  icon: Icons.visibility_rounded,
                  iconColor: cs.primary,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  valueGetter: () => settingsController.subtitleOpacity.value,
                  labelBuilder: (v) => '${(v * 100).round()}%',
                  onChanged: settingsController.setSubtitleOpacity,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
              child: OutlinedButton.icon(
                onPressed: settingsController.resetSubtitleSettings,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Subtitle Defaults'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 8),
      child: AzyXText(
        text: title,
        fontSize: 11,
        fontVariant: FontVariant.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildGroupedCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
          width: 0.6,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 62,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double min,
    required double max,
    required int divisions,
    required double Function() valueGetter,
    required String Function(double) labelBuilder,
    required ValueChanged<double> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AzyXText(
                      text: title,
                      fontSize: 15,
                      fontVariant: FontVariant.bold,
                      color: cs.onSurface,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labelBuilder(valueGetter()),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () => CustomSlider(
              min: min,
              max: max,
              divisions: divisions,
              value: valueGetter().clamp(min, max),
              theme: const M3SliderTheme(
                height: 20,
                trackHeight: 6,
                outerRadius: 6,
                innerRadius: 2,
                thumbGap: 6,
                edgeInset: 2,
                thumbWidth: 4,
                thumbHeight: 20,
                thumbCornerRadius: 2,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String Function() selectedGetter,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 14),
              AzyXText(
                text: title,
                fontSize: 15,
                fontVariant: FontVariant.bold,
                color: cs.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final selected = selectedGetter();
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((name) {
                final isSelected = selected == name;
                final swatch =
                    SettingsController.subtitleColorOptions[name] ??
                    Colors.white;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelected(name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.16)
                          : cs.surface.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : cs.outlineVariant.withValues(alpha: 0.25),
                        width: isSelected ? 1.2 : 0.7,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: swatch == Colors.transparent
                                ? Colors.transparent
                                : swatch,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: swatch == Colors.transparent
                              ? Icon(
                                  Icons.block_rounded,
                                  size: 10,
                                  color: cs.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
