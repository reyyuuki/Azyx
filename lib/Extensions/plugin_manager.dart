import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:azyx/Controllers/source/download_run_time_apk.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart' hide isar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PluginManager {
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/RyanYuuki/AnymeXExtensionRuntimeBridge/releases/latest';

  String get installedVersion =>
      PluginKeys.runtimeHostInstalledVersion.get<String>('');

  Future<void> ensurePluginLoaded(BuildContext context) async {
    final isLoaded = await AnymeXRuntimeBridge.isLoaded();
    if (isLoaded) {
      await checkForUpdates(context, showIfUpToDate: false);
      return;
    }

    final downloadNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Runtime Required'),
        content: const Text(
          'The AnymeX extension runtime is required to run extensions. Would you like to download and install it now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (downloadNow == true) {
      if (!context.mounted) return;
      final success = await DownloadRunTimeApk.showDownloadDialog(context);
      if (success) {
        final release = await fetchLatestRelease();
        if (release != null) {
          PluginKeys.runtimeHostInstalledVersion.set(release.tagName);
          PluginKeys.runtimeHostInstalledReleaseTitle.set(release.title);
        }
      }
    }
  }

  Future<void> checkForUpdates(
    BuildContext context, {
    bool showIfUpToDate = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(_latestReleaseUrl),
        headers: const {'Accept': 'application/vnd.github+json'},
      );

      if (response.statusCode != 200) {
        if (showIfUpToDate) {
          azyxSnackBar('Failed to check plugin updates.');
        }
        return;
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final latestTag = (json['tag_name'] as String? ?? '').trim();
      if (latestTag.isEmpty) return;

      final currentVersion = installedVersion;
      bool needsUpdate = false;
      if (currentVersion.isEmpty) {
        PluginKeys.runtimeHostInstalledVersion.set(latestTag);
        return;
      } else {
        needsUpdate = isNewerVersion(currentVersion, latestTag);
      }

      if (needsUpdate) {
        if (!context.mounted) return;
        final updateNow = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: Text(
              'A new version ($latestTag) of the AnymeX extension runtime is available. Would you like to update now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Update'),
              ),
            ],
          ),
        );

        if (updateNow == true) {
          if (!context.mounted) return;
          final success = await DownloadRunTimeApk.showDownloadDialog(context);
          if (success) {
            PluginKeys.runtimeHostInstalledVersion.set(latestTag);
            PluginKeys.runtimeHostInstalledReleaseTitle.set(json['name'] as String? ?? latestTag);
            azyxSnackBar('Plugin updated successfully. Please restart the app.');
          }
        }
      } else {
        if (showIfUpToDate) {
          azyxSnackBar('Plugin is already up to date.');
        }
      }
    } catch (e) {
      log('Error checking updates: $e');
    }
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
      final installedPart =
          index < installedParts.length ? installedParts[index] : 0;
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
  });

  final String tagName;
  final String title;
}
