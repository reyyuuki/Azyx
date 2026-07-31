import 'package:azyx/Database/isar_models/key_value.dart';
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
    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          children: [
            const CustomAppBar(title: "Settings", icon: Broken.setting_2),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1, 0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const ThemeSetting();
                    },
                  ),
                );
              },
              child: settingTile(
                context,
                "Theme",
                "Choose Vibe : Light, Dark, Dynamic",
                const Icon(Broken.brush_2),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1, 0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const UiSettings();
                    },
                  ),
                );
              },
              child: settingTile(
                context,
                "UI",
                "Customize Your UI: Vibrant, Sleek",
                const Icon(Broken.brush_1),
              ),
            ),
            GestureDetector(
              onTap: () {
                PluginManager().showRuntimeSettingsSheet(context);
              },
              child: settingTile(
                context,
                "Extension Runtime Host",
                "Update, Force Re-download or Load Runtime APK",
                const Icon(Broken.category),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1, 0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const BackupSetting();
                    },
                  ),
                );
              },
              child: settingTile(
                context,
                "Backup & Restore",
                "Backup, restore, and transfer your library & login tokens",
                const Icon(Icons.backup_outlined),
              ),
            ),
            GestureDetector(
              onTap: () {
                openDialogBox(context);
              },
              child: settingTile(
                context,
                "Clear Cache",
                "Reset All Cached Settings",
                const Icon(Broken.trash),
              ),
            ),
            GestureDetector(
              onTap: () {
                UpdateNotifier.checkUpdate(showFeedback: true);
              },
              child: settingTile(
                context,
                "Check for Update",
                "Check if a new version of AzyX is available",
                const Icon(Icons.system_update_outlined),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //   },
            //   child: settingTile(
            //     context,
            //     "About",
            //     "Discover More: About Us",
            //     const Icon(Broken.information),
            //   ),
            // ),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () async {
            //     await Get.find<CommunityService>().fetchAll();
            //   },
            //   child: const Text("Testing"),
            // ),
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

  ListTile settingTile(
    BuildContext context,
    String title,
    String subtitle,
    Icon icon,
  ) {
    return ListTile(
      leading: icon,
      title: AzyXText(text: title, fontVariant: FontVariant.bold),
      trailing: const Icon(Broken.arrow_right_3),
      subtitle: AzyXText(text: subtitle, fontSize: 12),
    );
  }
}
