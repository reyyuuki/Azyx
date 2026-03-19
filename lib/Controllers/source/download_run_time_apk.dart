// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadRunTimeApk {
  static RxBool isDownloading = false.obs;
  static RxDouble downloadProgress = 0.0.obs;
  static RxString downloadSpeed = "0 KB/s".obs;
  static RxString downloadedBytes = "0 MB".obs;
  static RxString totalBytes = "-- MB".obs;
  static CancelToken? _cancelToken;
  static DateTime? _lastSpeedCheck;
  static int _lastBytes = 0;

  static String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static String _formatSpeed(double bps) {
    if (bps < 1024 * 1024) return '${(bps / 1024).toStringAsFixed(0)} KB/s';
    return '${(bps / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  static Future<String> downloadRuntimeApk() async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0;
      _cancelToken = CancelToken();
      _lastSpeedCheck = null;
      _lastBytes = 0;

      const savePath = "/storage/emulated/0/Download/anymex_runtime_host.apk";

      await Dio().download(
        "https://github.com/RyanYuuki/AnymeXExtensionRuntimeBridge/releases/download/v1.0.0/anymex_runtime_host.apk",
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          final now = DateTime.now();
          if (_lastSpeedCheck != null) {
            final elapsed =
                now.difference(_lastSpeedCheck!).inMilliseconds / 1000;
            if (elapsed > 0) {
              final bps = (received - _lastBytes) / elapsed;
              downloadSpeed.value = _formatSpeed(bps);
            }
          }
          _lastSpeedCheck = now;
          _lastBytes = received;
          downloadProgress.value = total > 0 ? received / total : 0;
          downloadedBytes.value = _formatBytes(received);
          totalBytes.value = total > 0 ? _formatBytes(total) : '-- MB';
          log('received: $received, total: $total');
        },
      );

      isDownloading.value = false;
      return savePath;
    } catch (e) {
      isDownloading.value = false;
      log('error while downloading runtime apk: $e');
      return "";
    }
  }

  static void cancelDownload() {
    _cancelToken?.cancel();
    isDownloading.value = false;
  }

  static Future<bool> showDownloadDialog(BuildContext context) async {
    final alreadyDownloaded = await File(
      "/storage/emulated/0/Download/anymex_runtime_host.apk",
    ).exists();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ApkDownloadDialog(alreadyDownloaded: alreadyDownloaded),
    );

    return result ?? false;
  }
}

enum _DownloadStatus {
  confirm,
  alreadyExists,
  downloading,
  done,
  error,
  cancelled,
}

class _ApkDownloadDialog extends StatefulWidget {
  final bool alreadyDownloaded;
  const _ApkDownloadDialog({required this.alreadyDownloaded});

  @override
  State<_ApkDownloadDialog> createState() => _ApkDownloadDialogState();
}

class _ApkDownloadDialogState extends State<_ApkDownloadDialog>
    with SingleTickerProviderStateMixin {
  _DownloadStatus _status = _DownloadStatus.confirm;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.alreadyDownloaded) {
      _status = _DownloadStatus.alreadyExists;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() => _status = _DownloadStatus.downloading);
    final result = await DownloadRunTimeApk.downloadRuntimeApk();
    if (!mounted) return;
    if (result.isNotEmpty) {
      await AnymeXRuntimeBridge.loadAnymeXRuntimeHost(result);
      await sourceController.extensionManager.onRuntimeBridgeInitialization();
      setState(() => _status = _DownloadStatus.done);
    } else {
      setState(() => _status = _DownloadStatus.error);
    }
  }

  void _reset() {
    DownloadRunTimeApk.downloadProgress.value = 0;
    DownloadRunTimeApk.downloadedBytes.value = '0 MB';
    DownloadRunTimeApk.totalBytes.value = '-- MB';
    DownloadRunTimeApk.downloadSpeed.value = '0 KB/s';
    _startDownload();
  }

  Future<void> _pickAndLoad() async {
    await AnymeXRuntimeBridge.loadRuntimeHostFromPicker();
    await sourceController.extensionManager.onRuntimeBridgeInitialization();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.outline.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),
                28.height,
                if (_status == _DownloadStatus.alreadyExists)
                  _buildAlreadyExists(theme),
                if (_status == _DownloadStatus.confirm) _buildConfirm(theme),
                if (_status == _DownloadStatus.downloading ||
                    _status == _DownloadStatus.done ||
                    _status == _DownloadStatus.error ||
                    _status == _DownloadStatus.cancelled)
                  _buildProgress(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme theme) {
    final isDownloading = _status == _DownloadStatus.downloading;
    final isDone = _status == _DownloadStatus.done;
    final isError = _status == _DownloadStatus.error;
    final isExists = _status == _DownloadStatus.alreadyExists;

    final iconColor = isDone
        ? const Color(0xFF4CAF50)
        : isError
        ? theme.error
        : isExists
        ? const Color(0xFF4CAF50)
        : theme.primary;

    final icon = isExists
        ? Icons.folder_rounded
        : isDone
        ? Icons.check_rounded
        : isError
        ? Icons.error_outline_rounded
        : _status == _DownloadStatus.confirm
        ? Icons.system_update_rounded
        : Icons.download_rounded;

    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, child) => Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(
                isDownloading ? 0.06 + 0.06 * _pulseAnimation.value : 0.1,
              ),
              border: Border.all(
                color: iconColor.withOpacity(
                  isDownloading ? 0.2 + 0.3 * _pulseAnimation.value : 0.25,
                ),
                width: 1.5,
              ),
            ),
            child: child,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.15),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
        16.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AzyXText(
                text: _status == _DownloadStatus.alreadyExists
                    ? 'Runtime Found'
                    : _status == _DownloadStatus.confirm
                    ? 'Runtime Required'
                    : _status == _DownloadStatus.done
                    ? 'Download Complete'
                    : _status == _DownloadStatus.error
                    ? 'Download Failed'
                    : _status == _DownloadStatus.cancelled
                    ? 'Download Cancelled'
                    : 'Downloading...',
                fontVariant: FontVariant.bold,
                fontSize: 18,
              ),
              4.height,
              AzyXText(
                text: 'anymex_runtime_host.apk',
                fontSize: 12,
                color: theme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlreadyExists(ColorScheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _InfoRow(
                theme: theme,
                icon: Icons.folder_rounded,
                label: 'Found at',
                value: '/Download/',
              ),
              12.height,
              _InfoRow(
                theme: theme,
                icon: Icons.storage_rounded,
                label: 'Package',
                value: 'anymex_runtime_host.apk',
              ),
            ],
          ),
        ),
        16.height,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 15,
                color: const Color(0xFF4CAF50).withOpacity(0.9),
              ),
              10.width,
              Expanded(
                child: AzyXText(
                  text:
                      'A previously downloaded runtime was found on your device.',
                  fontSize: 11,
                  color: theme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        24.height,

        Row(
          children: [
            Expanded(
              child: _OutlineButton(
                label: 'Pick App',
                theme: theme,
                onTap: _pickAndLoad,
              ),
            ),
            12.width,
            Expanded(
              child: _OutlineButton(
                label: 'Re-download',
                theme: theme,
                onTap: () => setState(() => _status = _DownloadStatus.confirm),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirm(ColorScheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _InfoRow(
                theme: theme,
                icon: Icons.storage_rounded,
                label: 'Package',
                value: 'AnymeX Runtime Host',
              ),
              12.height,
              _InfoRow(
                theme: theme,
                icon: Icons.link_rounded,
                label: 'Source',
                value: 'github.com/RyanYuuki',
              ),
              12.height,
              _InfoRow(
                theme: theme,
                icon: Icons.save_alt_rounded,
                label: 'Save to',
                value: '/Download/',
              ),
            ],
          ),
        ),
        16.height,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primary.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: theme.primary.withOpacity(0.8),
              ),
              10.width,
              Expanded(
                child: AzyXText(
                  text:
                      'The runtime host is required to run extensions on Android.',
                  fontSize: 11,
                  color: theme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        24.height,
        Row(
          children: [
            Expanded(
              child: _OutlineButton(
                label: 'Cancel',
                theme: theme,
                onTap: () => Navigator.pop(context, false),
              ),
            ),
            12.width,
            Expanded(
              child: _FilledButton(
                label: 'Download',
                icon: Icons.download_rounded,
                theme: theme,
                onTap: _startDownload,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgress(ColorScheme theme) {
    final isDone = _status == _DownloadStatus.done;
    final isError = _status == _DownloadStatus.error;
    final isCancelled = _status == _DownloadStatus.cancelled;
    final isDownloading = _status == _DownloadStatus.downloading;

    final statusColor = isDone
        ? const Color(0xFF4CAF50)
        : isError
        ? theme.error
        : isCancelled
        ? theme.onSurface.withOpacity(0.4)
        : theme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      theme: theme,
                      icon: Broken.document_download,
                      label: 'Downloaded',
                      value:
                          '${DownloadRunTimeApk.downloadedBytes.value} / ${DownloadRunTimeApk.totalBytes.value}',
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: _StatChip(
                      theme: theme,
                      icon: Icons.speed_rounded,
                      label: 'Speed',
                      value: isDone
                          ? 'Done'
                          : DownloadRunTimeApk.downloadSpeed.value,
                    ),
                  ),
                ],
              ),
              18.height,
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Stack(
                  children: [
                    Container(height: 6, color: theme.surfaceContainerHighest),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 200),
                      widthFactor: isDone
                          ? 1.0
                          : DownloadRunTimeApk.downloadProgress.value,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor.withOpacity(0.6), statusColor],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AzyXText(
                    text: isDone
                        ? 'Completed'
                        : isError
                        ? 'Failed'
                        : isCancelled
                        ? 'Cancelled'
                        : 'Downloading',
                    fontSize: 11,
                    color: statusColor,
                  ),
                  AzyXText(
                    text: isDone
                        ? '100%'
                        : '${(DownloadRunTimeApk.downloadProgress.value * 100).toStringAsFixed(1)}%',
                    fontVariant: FontVariant.bold,
                    fontSize: 11,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
        ),
        16.height,
        if (isError || isDone || isCancelled) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isDone
                      ? Icons.check_circle_outline_rounded
                      : isError
                      ? Icons.error_outline_rounded
                      : Icons.cancel_outlined,
                  size: 15,
                  color: statusColor.withOpacity(0.9),
                ),
                10.width,
                Expanded(
                  child: AzyXText(
                    text: isDone
                        ? 'Runtime downloaded successfully to /Download/.'
                        : isError
                        ? 'Something went wrong. Please retry.'
                        : 'Download was cancelled.',
                    fontSize: 11,
                    color: theme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          16.height,
        ],
        Row(
          children: [
            if (isDownloading)
              Expanded(
                child: _OutlineButton(
                  label: 'Cancel',
                  theme: theme,
                  isDestructive: true,
                  onTap: () {
                    DownloadRunTimeApk.cancelDownload();
                    setState(() => _status = _DownloadStatus.cancelled);
                  },
                ),
              ),
            if (!isDownloading) ...[
              Expanded(
                child: _OutlineButton(
                  label: 'Dismiss',
                  theme: theme,
                  onTap: () => Navigator.pop(context, isDone),
                ),
              ),
              if (isError || isCancelled) ...[
                12.width,
                Expanded(
                  child: _FilledButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    theme: theme,
                    onTap: _reset,
                  ),
                ),
              ],
            ],
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final ColorScheme theme;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: theme.onSurface.withOpacity(0.4)),
        10.width,
        AzyXText(
          text: label,
          fontSize: 12,
          color: theme.onSurface.withOpacity(0.45),
        ),
        const Spacer(),
        AzyXText(
          text: value,
          fontVariant: FontVariant.bold,
          fontSize: 12,
          color: theme.onSurface.withOpacity(0.85),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final ColorScheme theme;
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: theme.onSurface.withOpacity(0.4)),
              5.width,
              AzyXText(
                text: label,
                fontSize: 10,
                color: theme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
          5.height,
          AzyXText(text: value, fontVariant: FontVariant.bold, fontSize: 12),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final ColorScheme theme;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.theme,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? theme.error
        : theme.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? theme.error.withOpacity(0.35)
                : theme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: AzyXText(
            text: label,
            fontVariant: FontVariant.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme theme;
  final VoidCallback onTap;

  const _FilledButton({
    required this.label,
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 16),
            8.width,
            AzyXText(
              text: label,
              fontVariant: FontVariant.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
