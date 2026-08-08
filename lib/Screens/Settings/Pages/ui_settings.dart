import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../Widgets/common/custom_app_bar.dart';

class UiSettings extends StatelessWidget {
  const UiSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          physics: const BouncingScrollPhysics(),
          children: [
            const CustomAppBar(title: "UI Settings", icon: Broken.designtools),
            _buildSectionHeader(context, "PERFORMANCE & EFFECTS"),
            _buildGroupedCard(
              context,
              children: [
                _buildSettingTile(
                  context,
                  title: "Gradient Effect",
                  subtitle: "Enable gradient background across application",
                  icon: Icons.gradient_rounded,
                  iconColor: theme.colorScheme.primary,
                  trailing: Obx(
                    () => Switch(
                      value: settingsController.isGradient.value,
                      onChanged: (value) {
                        settingsController.gradientToggler(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            _buildSectionHeader(context, "VISUAL EFFECTS & INTENSITY"),
            _buildGroupedCard(
              context,
              children: [
                _buildSliderTile(
                  context,
                  title: "Glow Multiplier",
                  subtitle: "Adjust UI glow accent intensity",
                  icon: Ionicons.color_fill,
                  iconColor: theme.colorScheme.secondary,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  getValue: () => uiSettingController.glowMultiplier,
                  onChanged: (val) => uiSettingController.glowMultiplier = val,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: "Blur Multiplier",
                  subtitle: "Adjust backdrop blur filter intensity",
                  icon: Ionicons.color_wand,
                  iconColor: theme.colorScheme.tertiary,
                  min: 1.0,
                  max: 5.0,
                  divisions: 10,
                  getValue: () => uiSettingController.blurMultiplier,
                  onChanged: (val) => uiSettingController.blurMultiplier = val,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: "Corner Radius Multiplier",
                  subtitle: "Adjust container corner roundness",
                  icon: Broken.category,
                  iconColor: theme.colorScheme.primary,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  getValue: () => uiSettingController.radiusMultiplier,
                  onChanged: (val) =>
                      uiSettingController.radiusMultiplier = val,
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: "Shadow Spread Multiplier",
                  subtitle: "Adjust drop shadow spread distance",
                  icon: Icons.layers_outlined,
                  iconColor: theme.colorScheme.secondary,
                  min: 0.0,
                  max: 3.0,
                  divisions: 12,
                  getValue: () => uiSettingController.spreadMultiplier,
                  onChanged: (val) =>
                      uiSettingController.spreadMultiplier = val,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 6),
      child: AzyXText(
        text: title,
        fontSize: 11,
        fontVariant: FontVariant.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildGroupedCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      indent: 48,
      endIndent: 14,
      color: theme.colorScheme.outline.withOpacity(0.1),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  text: title,
                  fontVariant: FontVariant.bold,
                  fontSize: 14,
                ),
                const SizedBox(height: 2),
                AzyXText(
                  text: subtitle,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
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
    required double Function() getValue,
    required Function(double) onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AzyXText(
                      text: title,
                      fontVariant: FontVariant.bold,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 2),
                    AzyXText(
                      text: subtitle,
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AzyXText(
                    text: getValue().toStringAsFixed(1),
                    fontSize: 11,
                    fontVariant: FontVariant.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomSlider(
              onChanged: onChanged,
              divisions: divisions,
              max: max,
              min: min,
              value: getValue().clamp(min, max),
            ),
          ),
        ],
      ),
    );
  }
}
