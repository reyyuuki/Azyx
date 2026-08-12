import 'dart:convert';
import 'dart:io';
import 'package:azyx/Controllers/backup_controller.dart';
import 'package:azyx/Controllers/sync/gist_sync_controller.dart';
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/main.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/custom_app_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BackupSetting extends StatefulWidget {
  const BackupSetting({super.key});

  @override
  State<BackupSetting> createState() => _BackupSettingState();
}

class _BackupSettingState extends State<BackupSetting> {
  final BackupController controller = Get.isRegistered<BackupController>()
      ? Get.find<BackupController>()
      : Get.put(BackupController());

  final GistSyncController gistController =
      Get.isRegistered<GistSyncController>()
      ? Get.find<GistSyncController>()
      : Get.put(GistSyncController());

  bool _backupHistory = true;
  bool _backupCategories = true;
  bool _backupOffline = true;
  bool _backupSettings = true;
  bool _backupAuthTokens = true;

  bool _restoreHistory = true;
  bool _restoreCategories = true;
  bool _restoreOffline = true;
  bool _restoreSettings = true;
  bool _restoreAuthTokens = true;
  bool _mergeMode = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AzyXGradientContainer(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const CustomAppBar(
              title: "Backup & Restore",
              icon: Broken.document_download,
            ),
            const SizedBox(height: 16),
            _buildOverviewHeader(context),
            const SizedBox(height: 16),
            _buildGistCard(context),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "Create Local Backup",
              subtitle:
                  "Export library, settings, and login tokens to a JSON file.",
              icon: Icons.upload_file_rounded,
              buttonText: "Export Backup",
              onTap: _showExportDialog,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "Restore From File",
              subtitle:
                  "Restore library and settings from a backup file without re-logging in.",
              icon: Icons.restore_page_rounded,
              buttonText: "Select & Restore",
              onTap: _handleRestorePick,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyCount = isar.localHistoryItems.countSync();
    final categoryCount = isar.categorys.countSync();
    final offlineCount = isar.offlineItems.countSync();
    final settingsCount = isar.keyValues.countSync();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              const AzyXText(
                text: "Local Storage Overview",
                fontSize: 16,
                fontVariant: FontVariant.bold,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                context,
                "$historyCount",
                "History",
                Icons.history_rounded,
              ),
              _buildStatChip(
                context,
                "$categoryCount",
                "Lists",
                Icons.folder_copy_rounded,
              ),
              _buildStatChip(
                context,
                "$offlineCount",
                "Offline",
                Icons.download_done_rounded,
              ),
              _buildStatChip(
                context,
                "$settingsCount",
                "Keys",
                Icons.tune_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              AzyXText(
                text: value,
                fontSize: 14,
                fontVariant: FontVariant.bold,
                color: colorScheme.onSurface,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AzyXText(
          text: label,
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildGistCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isConnected = gistController.isLoggedIn.value;
      final isSyncing = gistController.isSyncing.value;
      final username = gistController.githubUsername.value;
      final status = gistController.lastSyncStatus.value;

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected
                ? Colors.green.withValues(alpha: 0.4)
                : colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Colors.green.withValues(alpha: 0.15)
                        : colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesome.github_brand,
                    color: isConnected ? Colors.green : colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AzyXText(
                        text: "GitHub Gist Sync",
                        fontSize: 18,
                        fontVariant: FontVariant.bold,
                      ),
                      if (username != null)
                        AzyXText(
                          text: "@$username",
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Colors.green.withValues(alpha: 0.15)
                        : colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AzyXText(
                    text: isConnected ? "Connected" : "Disabled",
                    fontSize: 11,
                    color: isConnected ? Colors.green : colorScheme.error,
                    fontVariant: FontVariant.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AzyXText(
              text: isConnected
                  ? (status ??
                        "Synchronizes watch and read progress automatically to private GitHub Gist.")
                  : "Connect GitHub using a Personal Access Token to sync watch and read progress across devices.",
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isConnected) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: isSyncing
                          ? null
                          : () => gistController.syncNow(),
                      icon: isSyncing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.sync, size: 18),
                      label: AzyXText(
                        text: isSyncing ? "Syncing..." : "Sync Now",
                        fontVariant: FontVariant.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.error.withValues(
                        alpha: 0.15,
                      ),
                    ),
                    onPressed: () => gistController.logout(),
                    icon: Icon(
                      Icons.logout,
                      color: colorScheme.error,
                      size: 20,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => gistController.login(
                        context,
                        onFallbackDialog: () => _showTokenSetupDialog(context),
                      ),
                      icon: const Icon(FontAwesome.github_brand, size: 18),
                      label: const AzyXText(
                        text: "Connect GitHub",
                        fontVariant: FontVariant.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    ),
                    tooltip: "Personal Access Token",
                    onPressed: () => _showTokenSetupDialog(context),
                    icon: Icon(
                      Icons.key_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AzyXText(
                  text: title,
                  fontSize: 18,
                  fontVariant: FontVariant.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AzyXText(
            text: subtitle,
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onTap,
              child: AzyXText(
                text: buttonText,
                fontVariant: FontVariant.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final historyCount = isar.localHistoryItems.countSync();
    final categoryCount = isar.categorys.countSync();
    final offlineCount = isar.offlineItems.countSync();
    final settingsCount = isar.keyValues.countSync();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return Dialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AzyXText(
                      text: "Backup Options",
                      fontSize: 18,
                      fontVariant: FontVariant.bold,
                    ),
                    const SizedBox(height: 6),
                    AzyXText(
                      text: "Select items to export into backup:",
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "Watch & Read History ($historyCount items)",
                      ),
                      value: _backupHistory,
                      onChanged: (v) =>
                          setDialogState(() => _backupHistory = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "Custom Categories ($categoryCount lists)",
                      ),
                      value: _backupCategories,
                      onChanged: (v) =>
                          setDialogState(() => _backupCategories = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "Offline Downloads ($offlineCount items)",
                      ),
                      value: _backupOffline,
                      onChanged: (v) =>
                          setDialogState(() => _backupOffline = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "App Settings ($settingsCount keys)",
                      ),
                      value: _backupSettings,
                      onChanged: (v) =>
                          setDialogState(() => _backupSettings = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(
                        text: "Login Tokens (AniList / MAL / SIMKL)",
                      ),
                      subtitle: AzyXText(
                        text: "Preserves session tokens for instant login",
                        fontSize: 11,
                        color: colorScheme.primary,
                      ),
                      value: _backupAuthTokens,
                      onChanged: (v) =>
                          setDialogState(() => _backupAuthTokens = v ?? true),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const AzyXText(text: "Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await controller.exportBackup(
                              backupHistory: _backupHistory,
                              backupCategories: _backupCategories,
                              backupOffline: _backupOffline,
                              backupSettings: _backupSettings,
                              backupAuthTokens: _backupAuthTokens,
                            );
                          },
                          child: AzyXText(
                            text: "Export",
                            color: colorScheme.onPrimary,
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
      },
    );
  }

  void _handleRestorePick() async {
    final file = await controller.pickBackupFile();
    if (file != null) {
      _showRestoreDialog(file);
    }
  }

  void _showRestoreDialog(File file) async {
    int fileHistoryCount = 0;
    int fileCategoryCount = 0;
    int fileOfflineCount = 0;
    int fileSettingsCount = 0;

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      fileHistoryCount = (data['historyItems'] as List?)?.length ?? 0;
      fileCategoryCount = (data['categories'] as List?)?.length ?? 0;
      fileOfflineCount = (data['offlineItems'] as List?)?.length ?? 0;
      fileSettingsCount = (data['keyValues'] as List?)?.length ?? 0;
    } catch (_) {}

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return Dialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AzyXText(
                      text: "Restore Options",
                      fontSize: 18,
                      fontVariant: FontVariant.bold,
                    ),
                    const SizedBox(height: 6),
                    AzyXText(
                      text:
                          "File: ${file.path.split('/').last.split('\\').last}",
                      fontSize: 12,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const AzyXText(text: "Merge", fontSize: 13),
                            value: true,
                            groupValue: _mergeMode,
                            onChanged: (v) =>
                                setDialogState(() => _mergeMode = v ?? true),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const AzyXText(
                              text: "Overwrite",
                              fontSize: 13,
                            ),
                            value: false,
                            groupValue: _mergeMode,
                            onChanged: (v) =>
                                setDialogState(() => _mergeMode = v ?? false),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "Watch & Read History ($fileHistoryCount items)",
                      ),
                      value: _restoreHistory,
                      onChanged: (v) =>
                          setDialogState(() => _restoreHistory = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "Custom Categories ($fileCategoryCount lists)",
                      ),
                      value: _restoreCategories,
                      onChanged: (v) =>
                          setDialogState(() => _restoreCategories = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "Offline Data ($fileOfflineCount items)",
                      ),
                      value: _restoreOffline,
                      onChanged: (v) =>
                          setDialogState(() => _restoreOffline = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AzyXText(
                        text: "App Settings ($fileSettingsCount keys)",
                      ),
                      value: _restoreSettings,
                      onChanged: (v) =>
                          setDialogState(() => _restoreSettings = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Login Tokens"),
                      value: _restoreAuthTokens,
                      onChanged: (v) =>
                          setDialogState(() => _restoreAuthTokens = v ?? true),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const AzyXText(text: "Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await controller.restoreBackup(
                              file: file,
                              merge: _mergeMode,
                              restoreHistory: _restoreHistory,
                              restoreCategories: _restoreCategories,
                              restoreOffline: _restoreOffline,
                              restoreSettings: _restoreSettings,
                              restoreAuthTokens: _restoreAuthTokens,
                            );
                          },
                          child: AzyXText(
                            text: "Restore",
                            color: colorScheme.onPrimary,
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
      },
    );
  }

  void _showTokenSetupDialog(BuildContext context) {
    final TextEditingController tokenInputController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesome.github_brand,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const AzyXText(
                      text: "GitHub Token Setup",
                      fontSize: 18,
                      fontVariant: FontVariant.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AzyXText(
                  text:
                      "Generate a GitHub Personal Access Token with 'gist' scope, then paste it below:",
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: AzyXText(
                    text: "Generate Token on GitHub",
                    fontSize: 13,
                    fontVariant: FontVariant.bold,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => launchUrlString(
                    "https://github.com/settings/tokens/new?description=AzyX&scopes=gist",
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: tokenInputController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "ghp_xxxxxxxxxxxxxxxxxxxx",
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                      0.4,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.content_paste_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      onPressed: () async {
                        final data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          tokenInputController.text = data!.text!.trim();
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const AzyXText(text: "Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                      ),
                      onPressed: () async {
                        final token = tokenInputController.text.trim();
                        Navigator.pop(context);
                        if (token.isNotEmpty) {
                          await gistController.loginWithToken(token);
                        }
                      },
                      child: AzyXText(
                        text: "Connect",
                        color: colorScheme.onPrimary,
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
