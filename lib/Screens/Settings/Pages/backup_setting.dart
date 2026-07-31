import 'dart:io';
import 'package:azyx/Controllers/backup_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/custom_app_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackupSetting extends StatefulWidget {
  const BackupSetting({super.key});

  @override
  State<BackupSetting> createState() => _BackupSettingState();
}

class _BackupSettingState extends State<BackupSetting> {
  final BackupController controller = Get.isRegistered<BackupController>()
      ? Get.find<BackupController>()
      : Get.put(BackupController());

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            _buildActionCard(
              context,
              title: "Create Backup",
              subtitle: "Export your library, history, settings, and login tokens to a backup file.",
              icon: Icons.cloud_upload_outlined,
              buttonText: "Export Backup",
              onTap: _showExportDialog,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "Restore Backup",
              subtitle: "Import your data from an existing backup file without having to log in again.",
              icon: Icons.cloud_download_outlined,
              buttonText: "Select & Restore",
              onTap: _handleRestorePick,
            ),
          ],
        ),
      ),
    );
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
                      text: "Select what items to include in the backup:",
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Watch & Read History"),
                      value: _backupHistory,
                      onChanged: (v) => setDialogState(() => _backupHistory = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Custom Categories"),
                      value: _backupCategories,
                      onChanged: (v) => setDialogState(() => _backupCategories = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Offline / Download Data"),
                      value: _backupOffline,
                      onChanged: (v) => setDialogState(() => _backupOffline = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "App Settings"),
                      value: _backupSettings,
                      onChanged: (v) => setDialogState(() => _backupSettings = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Login Tokens (AniList / MAL / SIMKL)"),
                      subtitle: AzyXText(
                        text: "Allows auto-login after restore",
                        fontSize: 11,
                        color: colorScheme.primary,
                      ),
                      value: _backupAuthTokens,
                      onChanged: (v) => setDialogState(() => _backupAuthTokens = v ?? true),
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

  void _showRestoreDialog(File file) {
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
                      text: "Selected file: ${file.path.split('/').last.split('\\').last}",
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
                            onChanged: (v) => setDialogState(() => _mergeMode = v ?? true),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const AzyXText(text: "Overwrite", fontSize: 13),
                            value: false,
                            groupValue: _mergeMode,
                            onChanged: (v) => setDialogState(() => _mergeMode = v ?? false),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Watch & Read History"),
                      value: _restoreHistory,
                      onChanged: (v) => setDialogState(() => _restoreHistory = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Custom Categories"),
                      value: _restoreCategories,
                      onChanged: (v) => setDialogState(() => _restoreCategories = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Offline Data"),
                      value: _restoreOffline,
                      onChanged: (v) => setDialogState(() => _restoreOffline = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "App Settings"),
                      value: _restoreSettings,
                      onChanged: (v) => setDialogState(() => _restoreSettings = v ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const AzyXText(text: "Login Tokens"),
                      value: _restoreAuthTokens,
                      onChanged: (v) => setDialogState(() => _restoreAuthTokens = v ?? true),
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
}
