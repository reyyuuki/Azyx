import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/watchium_service.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/widgets/watchium_sheet.dart';
import 'package:azyx/Screens/Settings/Pages/backup_setting.dart';
import 'package:azyx/Screens/Settings/Pages/theme_setting.dart';
import 'package:azyx/Screens/Settings/Pages/ui_settings.dart';
import 'package:azyx/Extensions/plugin_manager.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/main.dart';
import 'package:flutter/material.dart';
import 'package:azyx/utils/update_notifier.dart';
import 'package:get/get.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import '../../Widgets/common/custom_app_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          physics: const BouncingScrollPhysics(),
          children: [
            const CustomAppBar(title: "Settings", icon: Broken.setting_2),
            _buildSectionHeader(context, "APPEARANCE & UI"),
            _buildGroupedCard(
              context,
              children: [
                _buildSettingTile(
                  context,
                  title: "Theme",
                  subtitle: "Choose Vibe : Light, Dark, Dynamic",
                  icon: Broken.brush_2,
                  iconColor: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, animation, _, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: child,
                          );
                        },
                        pageBuilder: (_, __, ___) => const ThemeSetting(),
                      ),
                    );
                  },
                ),
                _buildDivider(context),
                _buildSettingTile(
                  context,
                  title: "UI Customization",
                  subtitle: "Customize Your UI: Vibrant, Sleek",
                  icon: Broken.brush_1,
                  iconColor: theme.colorScheme.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, animation, _, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: child,
                          );
                        },
                        pageBuilder: (_, __, ___) => const UiSettings(),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildSectionHeader(context, "EXTENSIONS & WATCH TOGETHER"),
            _buildGroupedCard(
              context,
              children: [
                _buildSettingTile(
                  context,
                  title: "Extension Runtime Host",
                  subtitle: "Update, Force Re-download or Load Runtime APK",
                  icon: Broken.category,
                  iconColor: theme.colorScheme.tertiary,
                  onTap: () {
                    PluginManager().showRuntimeSettingsSheet(context);
                  },
                ),
                _buildDivider(context),
                _buildSettingTile(
                  context,
                  title: "Watch Together",
                  subtitle: "Join or create a room to watch anime together",
                  icon: Broken.people,
                  iconColor: theme.colorScheme.primary,
                  onTap: () {
                    if (!Get.isRegistered<WatchiumService>()) {
                      Get.put(WatchiumService());
                    }
                    showWatchiumSheet(context);
                  },
                ),
              ],
            ),
            _buildSectionHeader(context, "DATA & STORAGE"),
            _buildGroupedCard(
              context,
              children: [
                _buildSettingTile(
                  context,
                  title: "Backup & Restore",
                  subtitle:
                      "Backup, restore, and transfer your library & login tokens",
                  icon: Icons.backup_outlined,
                  iconColor: theme.colorScheme.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, animation, _, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: child,
                          );
                        },
                        pageBuilder: (_, __, ___) => const BackupSetting(),
                      ),
                    );
                  },
                ),
                _buildDivider(context),
                _buildSettingTile(
                  context,
                  title: "Clear Cache",
                  subtitle: "Reset All Cached Settings",
                  icon: Broken.trash,
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                  onTap: () {
                    openDialogBox(context);
                  },
                ),
              ],
            ),
            _buildSectionHeader(context, "SYSTEM & UPDATES"),
            _buildGroupedCard(
              context,
              children: [
                _buildSettingTile(
                  context,
                  title: "Check for Update",
                  subtitle: "Check if a new version of AzyX is available",
                  icon: Icons.system_update_outlined,
                  iconColor: theme.colorScheme.primary,
                  onTap: () {
                    UpdateNotifier.checkUpdate(showFeedback: true);
                  },
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
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    color: textColor ?? theme.colorScheme.onSurface,
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
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAppCache(BuildContext context) async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      isar.writeTxnSync(() {
        isar.localHistoryItems.clearSync();
        isar.categorys.clearSync();
        isar.offlineItems.clearSync();
        isar.keyValues.clearSync();
      });

      if (Get.isRegistered<LocalHistoryController>()) {
        Get.find<LocalHistoryController>().refreshHistory();
      }

      if (context.mounted) {
        Provider.of<ThemeProvider>(context, listen: false).reloadSettings();
      }
      if (Get.isRegistered<UiSettingController>()) {
        Get.find<UiSettingController>().reloadSettings();
      }

      Get.snackbar('Cache Cleared', 'App reset to default state successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear cache: $e');
    }
  }

  void openDialogBox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Broken.trash,
                        color: colorScheme.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const AzyXText(
                      text: "Clear App Cache",
                      fontSize: 18,
                      fontVariant: FontVariant.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AzyXText(
                  text:
                      "This will clear temporary image cache, cached network files, and reset cached app settings. Your watch history and downloads will be preserved.",
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const AzyXText(text: "Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _clearAppCache(context);
                      },
                      child: AzyXText(
                        text: "Clear Cache",
                        fontVariant: FontVariant.bold,
                        color: colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
