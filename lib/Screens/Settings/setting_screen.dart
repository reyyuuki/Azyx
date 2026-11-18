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

class SettingItemData {
  final String section;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color Function(ThemeData theme) iconColor;
  final Color Function(ThemeData theme)? textColor;
  final void Function(BuildContext context) onTap;

  SettingItemData({
    required this.section,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.textColor,
    required this.onTap,
  });
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<SettingItemData> _getAllSettings(BuildContext context) {
    return [
      SettingItemData(
        section: "APPEARANCE & UI",
        title: "Theme",
        subtitle: "Choose Vibe : Light, Dark, Dynamic",
        icon: Broken.brush_2,
        iconColor: (theme) => theme.colorScheme.primary,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (ctx, animation, _, child) {
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
      SettingItemData(
        section: "APPEARANCE & UI",
        title: "UI Customization",
        subtitle: "Customize Your UI: Vibrant, Sleek",
        icon: Broken.brush_1,
        iconColor: (theme) => theme.colorScheme.secondary,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (ctx, animation, _, child) {
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
      SettingItemData(
        section: "EXTENSIONS & WATCH TOGETHER",
        title: "Extension Runtime Host",
        subtitle: "Update, Force Re-download or Load Runtime APK",
        icon: Broken.category,
        iconColor: (theme) => theme.colorScheme.tertiary,
        onTap: (ctx) {
          PluginManager().showRuntimeSettingsSheet(ctx);
        },
      ),
      SettingItemData(
        section: "EXTENSIONS & WATCH TOGETHER",
        title: "Watch Together",
        subtitle: "Join or create a room to watch anime together",
        icon: Broken.people,
        iconColor: (theme) => theme.colorScheme.primary,
        onTap: (ctx) {
          if (!Get.isRegistered<WatchiumService>()) {
            Get.put(WatchiumService());
          }
          showWatchiumSheet(ctx);
        },
      ),
      SettingItemData(
        section: "DATA & STORAGE",
        title: "Backup & Restore",
        subtitle: "Backup, restore, and transfer your library & login tokens",
        icon: Icons.backup_outlined,
        iconColor: (theme) => theme.colorScheme.secondary,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (ctx, animation, _, child) {
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
      SettingItemData(
        section: "DATA & STORAGE",
        title: "Clear Cache",
        subtitle: "Reset All Cached Settings",
        icon: Broken.trash,
        iconColor: (theme) => theme.colorScheme.error,
        textColor: (theme) => theme.colorScheme.error,
        onTap: (ctx) {
          openDialogBox(ctx);
        },
      ),
      SettingItemData(
        section: "SYSTEM & UPDATES",
        title: "Check for Update",
        subtitle: "Check if a new version of AzyX is available",
        icon: Icons.system_update_outlined,
        iconColor: (theme) => theme.colorScheme.primary,
        onTap: (ctx) {
          UpdateNotifier.checkUpdate(showFeedback: true);
        },
      ),
    ];
  }

  Widget _buildIOSHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: _isSearching
                  ? Container(
                      key: const ValueKey("SearchHeader"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Broken.search_normal,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 14,
                                fontFamily: "Poppins",
                              ),
                              decoration: InputDecoration(
                                hintText: "Search settings...",
                                hintStyle: TextStyle(
                                  color: colors.onSurfaceVariant.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.trim().toLowerCase();
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = "";
                                });
                              },
                              child: Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isSearching = false;
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.surface.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      key: const ValueKey("StandardHeader"),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withOpacity(
                                0.35,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colors.outline.withOpacity(0.08),
                              ),
                            ),
                            child: Icon(
                              Broken.arrow_left_2,
                              size: 20,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isSearching = true;
                            });
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                _searchFocusNode.requestFocus();
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              Broken.search_normal,
                              size: 20,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            AzyXText(
              text: "Settings",
              fontVariant: FontVariant.bold,
              fontSize: 30,
              color: colors.onSurface,
              letterSpacing: -0.5,
            ),
            const SizedBox(height: 2),
            AzyXText(
              text: _isSearching && _searchQuery.isNotEmpty
                  ? "Search results for \"$_searchQuery\""
                  : "Customize your layout, runtime plugins & playback options",
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.35),
                    colors.outline.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final allSettings = _getAllSettings(context);

    final filteredSettings = _searchQuery.isEmpty
        ? allSettings
        : allSettings.where((item) {
            final titleMatch = item.title.toLowerCase().contains(_searchQuery);
            final subtitleMatch = item.subtitle.toLowerCase().contains(
              _searchQuery,
            );
            final sectionMatch = item.section.toLowerCase().contains(
              _searchQuery,
            );
            return titleMatch || subtitleMatch || sectionMatch;
          }).toList();

    final Map<String, List<SettingItemData>> groupedSettings = {};
    for (var item in filteredSettings) {
      groupedSettings.putIfAbsent(item.section, () => []).add(item);
    }

    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildIOSHeader(context),
            if (groupedSettings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 40,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.outline.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Broken.search_status,
                        size: 44,
                        color: colors.primary.withOpacity(0.7),
                      ),
                      const SizedBox(height: 12),
                      AzyXText(
                        text: "No Settings Found",
                        fontSize: 16,
                        fontVariant: FontVariant.bold,
                        color: colors.onSurface,
                      ),
                      const SizedBox(height: 4),
                      AzyXText(
                        text:
                            "No setting matching \"$_searchQuery\" was found.",
                        fontSize: 12,
                        textAlign: TextAlign.center,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...groupedSettings.entries.expand((entry) {
                final sectionTitle = entry.key;
                final items = entry.value;

                return [
                  _buildSectionHeader(context, sectionTitle),
                  _buildGroupedCard(
                    context,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isLast = index == items.length - 1;

                      return Column(
                        children: [
                          _buildSettingTile(
                            context,
                            title: item.title,
                            subtitle: item.subtitle,
                            icon: item.icon,
                            iconColor: item.iconColor(theme),
                            textColor: item.textColor?.call(theme),
                            onTap: () => item.onTap(context),
                          ),
                          if (!isLast) _buildDivider(context),
                        ],
                      );
                    }),
                  ),
                ];
              }),
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
