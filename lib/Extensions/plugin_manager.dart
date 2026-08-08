import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Controllers/source/download_run_time_apk.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class PluginManager {
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/RyanYuuki/AnymeXExtensionRuntimeBridge/releases/latest';

  String get installedVersion {
    final bridgeVersion = AnymeXRuntimeBridge.installedVersion;
    if (bridgeVersion.isNotEmpty) return bridgeVersion;
    return PluginKeys.runtimeHostInstalledVersion.get<String>('');
  }

  Future<void> ensurePluginLoaded(BuildContext context) async {
    final isLoaded = await AnymeXRuntimeBridge.isLoaded();
    if (isLoaded) {
      if (!context.mounted) return;
      await checkForUpdates(context, showIfUpToDate: false);
      return;
    }
    final release = await fetchLatestRelease();
    if (release != null && context.mounted) {
      await showUpdateSheet(
        context,
        release: release,
        installedVersion: 'Not Installed',
      );
    }
  }

  Future<void> checkForUpdates(
    BuildContext context, {
    bool showIfUpToDate = false,
  }) async {
    try {
      final release = await fetchLatestRelease();
      if (release == null) {
        if (showIfUpToDate) {
          azyxSnackBar('Failed to check plugin updates.');
        }
        return;
      }
      final currentVersion = installedVersion;
      if (currentVersion.isEmpty) {
        if (!context.mounted) return;
        await showUpdateSheet(
          context,
          release: release,
          installedVersion: 'Not Installed',
        );
        return;
      }
      if (isNewerVersion(currentVersion, release.tagName)) {
        if (!context.mounted) return;
        await showUpdateSheet(
          context,
          release: release,
          installedVersion: currentVersion,
        );
      } else {
        if (showIfUpToDate) {
          azyxSnackBar(
            'Plugin is already up to date (${currentVersion.isNotEmpty ? currentVersion : 'Latest'}).',
          );
        }
      }
    } catch (e) {
      log('Error checking updates: $e');
    }
  }

  Future<void> showUpdateSheet(
    BuildContext context, {
    required PluginRelease release,
    required String installedVersion,
  }) async {
    final colors = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: colors.outline.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AzyXGradientContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.system_update_rounded,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AzyXText(
                                text: 'Extension Runtime Update',
                                fontVariant: FontVariant.bold,
                                fontSize: 17,
                              ),
                              const SizedBox(height: 2),
                              AzyXText(
                                text:
                                    '$installedVersion  ➜  ${release.tagName}',
                                fontSize: 12,
                                fontVariant: FontVariant.bold,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.outline.withOpacity(0.08),
                        ),
                      ),
                      child: AzyXText(
                        text: release.title,
                        fontVariant: FontVariant.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withOpacity(
                            0.25,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outline.withOpacity(0.08),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: MarkdownBody(
                            data: release.body.isNotEmpty
                                ? release.body
                                : 'No release notes provided for this version.',
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant,
                              ),
                              h1: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                              h2: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(sheetCtx),
                            child: AzyXText(
                              text: 'Later',
                              color: colors.onSurfaceVariant,
                              fontVariant: FontVariant.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(sheetCtx);
                              final success =
                                  await DownloadRunTimeApk.showDownloadDialog(
                                    context,
                                    force: true,
                                  );
                              if (success) {
                                PluginKeys.runtimeHostInstalledVersion.set(
                                  release.tagName,
                                );
                                PluginKeys.runtimeHostInstalledReleaseTitle.set(
                                  release.title,
                                );
                                azyxSnackBar(
                                  Platform.isAndroid
                                      ? 'Plugin updated successfully. Please restart app.'
                                      : 'Desktop runtime updated successfully.',
                                );
                              }
                            },
                            child: const AzyXText(
                              text: 'Update Now',
                              fontVariant: FontVariant.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> forceReDownload(BuildContext context) async {
    try {
      final success = await DownloadRunTimeApk.showDownloadDialog(
        context,
        force: true,
      );
      if (success) {
        final release = await fetchLatestRelease();
        if (release != null) {
          PluginKeys.runtimeHostInstalledVersion.set(release.tagName);
          PluginKeys.runtimeHostInstalledReleaseTitle.set(release.title);
        }
        azyxSnackBar(
          Platform.isAndroid
              ? 'Extension runtime host re-downloaded & re-installed successfully.'
              : 'Desktop extension runtime bridge re-downloaded successfully.',
        );
      }
    } catch (e) {
      log('Force re-download failed: $e');
      azyxSnackBar('Force re-download failed: $e');
    }
  }

  Future<bool> syncLocalPluginFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: Platform.isAndroid ? const ['apk'] : const ['jar'],
        allowMultiple: false,
        withData: false,
      );
      final apkPath = result?.files.single.path;
      if (apkPath == null || apkPath.isEmpty) return false;

      final isJar = apkPath.toLowerCase().endsWith('.jar');
      final isApk = apkPath.toLowerCase().endsWith('.apk');

      if (Platform.isAndroid && !isApk) {
        azyxSnackBar('Please select a valid APK file.');
        return false;
      }
      if (!Platform.isAndroid && !isJar) {
        azyxSnackBar('Please select a valid JAR file.');
        return false;
      }

      final file = File(apkPath);
      if (!await file.exists()) {
        azyxSnackBar('Selected file does not exist.');
        return false;
      }

      if (Platform.isAndroid) {
        await AnymeXRuntimeBridge.useLocalApk(apkPath);
        azyxSnackBar('Local plugin APK installed. Restart the app if needed.');
        return true;
      } else {
        final paths = RuntimePaths();
        final destPath = await paths.bridgePath;
        final destFile = File(destPath);
        if (await destFile.exists()) {
          await destFile.delete();
        }
        await file.copy(destPath);

        final toolsDir = await paths.toolsDir;
        final metadataFile = File('${toolsDir.path}/metadata.json');
        await metadataFile.writeAsString(
          jsonEncode({
            'version': 'Local-${DateTime.now().millisecondsSinceEpoch}',
            'title': 'Local Synced Jar',
          }),
        );
        await AnymeXRuntimeBridge.loadMetadata();
        azyxSnackBar(
          'Local plugin JAR loaded successfully. Please restart app.',
        );
        return true;
      }
    } catch (e) {
      log('Local plugin sync failed: $e');
      azyxSnackBar('Failed to load local plugin file: $e');
      return false;
    }
  }

  void showRuntimeSettingsSheet(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: colors.outline.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AzyXGradientContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AzyXText(
                      text: 'Extension Runtime Options',
                      fontVariant: FontVariant.bold,
                      fontSize: 18,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    AzyXText(
                      text: installedVersion.isNotEmpty
                          ? 'Current Version: $installedVersion'
                          : 'Runtime Not Installed',
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildOptionTile(
                      modalCtx,
                      onPressed: () {
                        Navigator.pop(modalCtx);
                        checkForUpdates(context, showIfUpToDate: true);
                      },
                      icon: Icons.system_update_alt_rounded,
                      title: 'Check Runtime Updates',
                      subtitle: 'Check GitHub for newer runtime versions',
                    ),
                    const SizedBox(height: 10),
                    _buildOptionTile(
                      modalCtx,
                      onPressed: () {
                        Navigator.pop(modalCtx);
                        forceReDownload(context);
                      },
                      icon: Icons.refresh_rounded,
                      title: 'Force Re-Update / Re-Download',
                      subtitle:
                          'Re-download and reinstall runtime host from scratch',
                    ),
                    const SizedBox(height: 10),
                    _buildOptionTile(
                      modalCtx,
                      onPressed: () {
                        Navigator.pop(modalCtx);
                        syncLocalPluginFile(context);
                      },
                      icon: Platform.isAndroid
                          ? Icons.install_mobile_rounded
                          : Icons.folder_zip_rounded,
                      title: Platform.isAndroid
                          ? 'Load Local Runtime APK'
                          : 'Load Local Runtime JAR',
                      subtitle:
                          'Install runtime file directly from local storage',
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: colors.primary),
                ),
                const SizedBox(width: 14),
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
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<PluginRelease?> fetchLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(_latestReleaseUrl),
        headers: const {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return PluginRelease(
        tagName: (json['tag_name'] as String? ?? '').trim(),
        title: ((json['name'] as String?)?.trim().isNotEmpty ?? false)
            ? (json['name'] as String).trim()
            : (json['tag_name'] as String? ?? 'Latest Plugin Release').trim(),
        body: (json['body'] as String? ?? '').trim(),
      );
    } catch (e) {
      log('Error fetching latest release: $e');
      return null;
    }
  }

  bool isNewerVersion(String installed, String latest) {
    final installedParts = _normalizeVersion(installed);
    final latestParts = _normalizeVersion(latest);
    final maxLength = installedParts.length > latestParts.length
        ? installedParts.length
        : latestParts.length;
    for (var index = 0; index < maxLength; index++) {
      final installedPart = index < installedParts.length
          ? installedParts[index]
          : 0;
      final latestPart = index < latestParts.length ? latestParts[index] : 0;
      if (latestPart > installedPart) return true;
      if (latestPart < installedPart) return false;
    }
    return false;
  }

  List<int> _normalizeVersion(String version) {
    final cleaned = version.toLowerCase().replaceFirst(RegExp(r'^v'), '');
    final stablePart = cleaned.split('-').first;
    return stablePart
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}

class PluginRelease {
  const PluginRelease({
    required this.tagName,
    required this.title,
    this.body = '',
  });
  final String tagName;
  final String title;
  final String body;
}
