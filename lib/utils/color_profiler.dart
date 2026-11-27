import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorProfileManager {
  static const Map<String, Map<String, int>> profiles = {
    "cinema": {
      "brightness": 5,
      "contrast": 15,
      "saturation": 10,
      "gamma": 8,
      "hue": 0,
    },
    "cinema_dark": {
      "brightness": -8,
      "contrast": 20,
      "saturation": 12,
      "gamma": 15,
      "hue": 0,
    },
    "cinema_hdr": {
      "brightness": 3,
      "contrast": 25,
      "saturation": 8,
      "gamma": 5,
      "hue": -2,
    },
    "anime": {
      "brightness": 8,
      "contrast": 25,
      "saturation": 35,
      "gamma": -5,
      "hue": 2,
    },
    "anime_vibrant": {
      "brightness": 12,
      "contrast": 30,
      "saturation": 45,
      "gamma": -8,
      "hue": 5,
    },
    "anime_soft": {
      "brightness": 6,
      "contrast": 18,
      "saturation": 28,
      "gamma": -2,
      "hue": 1,
    },
    "vivid": {
      "brightness": 12,
      "contrast": 30,
      "saturation": 40,
      "gamma": 5,
      "hue": 0,
    },
    "vivid_pop": {
      "brightness": 15,
      "contrast": 35,
      "saturation": 50,
      "gamma": 8,
      "hue": 3,
    },
    "vivid_warm": {
      "brightness": 10,
      "contrast": 28,
      "saturation": 38,
      "gamma": 3,
      "hue": 12,
    },
    "natural": {
      "brightness": 0,
      "contrast": 0,
      "saturation": 0,
      "gamma": 0,
      "hue": 0,
    },
    "dark": {
      "brightness": -15,
      "contrast": 10,
      "saturation": -5,
      "gamma": 12,
      "hue": 0,
    },
    "warm": {
      "brightness": 5,
      "contrast": 8,
      "saturation": 12,
      "gamma": 3,
      "hue": 8,
    },
    "cool": {
      "brightness": 2,
      "contrast": 5,
      "saturation": 8,
      "gamma": 0,
      "hue": -8,
    },
    "grayscale": {
      "brightness": 0,
      "contrast": 15,
      "saturation": -100,
      "gamma": 5,
      "hue": 0,
    },
  };
  static const Map<String, String> profileDescriptions = {
    "cinema": "Balanced colors for movie watching",
    "cinema_dark": "Optimized for dark room cinema viewing",
    "cinema_hdr": "Enhanced cinema with HDR-like contrast",
    "anime": "Enhanced colors perfect for animation",
    "anime_vibrant": "Maximum saturation for colorful anime",
    "anime_soft": "Gentle enhancement for pastel anime",
    "vivid": "Bright and punchy colors",
    "vivid_pop": "Maximum vibrancy for eye-catching content",
    "vivid_warm": "Vivid colors with warm temperature",
    "natural": "Default balanced settings",
    "dark": "Optimized for dark environments",
    "warm": "Warmer tones for comfort viewing",
    "cool": "Cooler tones for clarity",
    "grayscale": "Black and white viewing",
  };
  static const Map<String, IconData> profileIcons = {
    "cinema": Icons.movie,
    "cinema_dark": Icons.movie_outlined,
    "cinema_hdr": Icons.hd,
    "anime": Icons.animation,
    "anime_vibrant": Icons.color_lens,
    "anime_soft": Icons.blur_on,
    "vivid": Icons.palette,
    "vivid_pop": Icons.auto_awesome,
    "vivid_warm": Icons.wb_sunny,
    "natural": Icons.nature,
    "dark": Icons.dark_mode,
    "warm": Icons.wb_sunny,
    "cool": Icons.ac_unit,
    "grayscale": Icons.gradient,
  };
  static String loadSavedProfile() {
    final saved = PlayerKeys.visualProfile.get<String>('natural');
    if (saved.isEmpty) return 'natural';
    return saved;
  }

  static void saveProfile(String profile) {
    PlayerKeys.visualProfile.set(profile);
  }

  static Map<String, int> loadCustomSettings() {
    final raw = PlayerKeys.customColorSettings.get<String>('');
    if (raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return {
          "brightness": (decoded["brightness"] as num?)?.toInt() ?? 0,
          "contrast": (decoded["contrast"] as num?)?.toInt() ?? 0,
          "saturation": (decoded["saturation"] as num?)?.toInt() ?? 0,
          "gamma": (decoded["gamma"] as num?)?.toInt() ?? 0,
          "hue": (decoded["hue"] as num?)?.toInt() ?? 0,
        };
      } catch (_) {}
    }
    return Map<String, int>.from(profiles['natural']!);
  }

  static void saveCustomSettings(Map<String, int> settings) {
    PlayerKeys.customColorSettings.set(jsonEncode(settings));
  }

  Future<void> applySavedProfile(dynamic player) async {
    final profile = loadSavedProfile();
    if (profile.toLowerCase() == 'custom') {
      await applyCustomSettings(loadCustomSettings(), player);
    } else {
      await applyColorProfile(profile, player);
    }
  }

  Future<void> applyColorProfile(String profile, dynamic player) async {
    saveProfile(profile);
    if (profile.toLowerCase() == 'custom') {
      await applyCustomSettings(loadCustomSettings(), player);
      return;
    }
    final settings = profiles[profile.toLowerCase()];
    if (settings != null && player?.platform != null) {
      try {
        for (final entry in settings.entries) {
          await (player.platform as dynamic).setProperty(
            entry.key,
            entry.value.toString(),
          );
          Utils.log('Applied ${entry.key}: ${entry.value}');
        }
      } catch (e) {
        Utils.log('Error applying color profile: $e');
      }
    }
  }

  Future<void> applyCustomSettings(
    Map<String, int> customSettings,
    dynamic player,
  ) async {
    saveProfile('custom');
    saveCustomSettings(customSettings);
    if (player?.platform != null) {
      try {
        for (final entry in customSettings.entries) {
          await (player.platform as dynamic).setProperty(
            entry.key,
            entry.value.toString(),
          );
        }
      } catch (e) {
        Utils.log('Error applying custom settings: $e');
      }
    }
  }
}

class ColorProfileBottomSheet extends StatefulWidget {
  final String currentProfile;
  final Function(String) onProfileSelected;
  final Function(Map<String, int>) onCustomSettingsChanged;
  final dynamic player;
  const ColorProfileBottomSheet({
    super.key,
    required this.currentProfile,
    required this.onProfileSelected,
    required this.onCustomSettingsChanged,
    required this.player,
  });
  @override
  State<ColorProfileBottomSheet> createState() =>
      _ColorProfileBottomSheetState();
}

class _ColorProfileBottomSheetState extends State<ColorProfileBottomSheet> {
  int _currentTab = 0;
  String _selectedProfile = 'natural';
  double _splitPosition = 0.45;
  Uint8List? _frameBytes;
  bool _isCapturingFrame = true;
  Map<String, int> _customSettings = {
    "brightness": 0,
    "contrast": 0,
    "saturation": 0,
    "gamma": 0,
    "hue": 0,
  };

  @override
  void initState() {
    super.initState();
    _selectedProfile = widget.currentProfile;
    _customSettings = _selectedProfile.toLowerCase() == 'custom'
        ? ColorProfileManager.loadCustomSettings()
        : Map.from(
            ColorProfileManager.profiles[_selectedProfile.toLowerCase()] ??
                ColorProfileManager.profiles['natural']!,
          );
    _captureCurrentFrame();
  }

  Future<void> _captureCurrentFrame() async {
    if (mounted) {
      setState(() => _isCapturingFrame = true);
    }
    Uint8List? bytes;
    try {
      if (widget.player != null) {
        bytes = await (widget.player as dynamic).safeScreenshot(
          format: 'image/jpeg',
        );
        bytes ??= await (widget.player as dynamic).screenshot(
          format: 'image/jpeg',
        );
      }
    } catch (e) {
      Utils.log('Preview screenshot error: $e');
    }
    if (!mounted) return;
    setState(() {
      _frameBytes = bytes;
      _isCapturingFrame = false;
    });
  }

  List<double> _buildColorMatrix() {
    final active = _currentTab == 0
        ? (ColorProfileManager.profiles[_selectedProfile.toLowerCase()] ??
              _customSettings)
        : _customSettings;
    final b = ((active['brightness'] ?? 0) / 100.0) * 128.0;
    final c = 1.0 + ((active['contrast'] ?? 0) / 100.0);
    final s = (1.0 + ((active['saturation'] ?? 0) / 100.0)).clamp(0.0, 2.5);
    final t = (1.0 - c) * 128.0 + b;
    const lumR = 0.2126;
    const lumG = 0.7152;
    const lumB = 0.0722;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;
    return [
      c * (sr + s),
      c * sg,
      c * sb,
      0,
      t,
      c * sr,
      c * (sg + s),
      c * sb,
      0,
      t,
      c * sr,
      c * sg,
      c * (sb + s),
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  Widget _buildPreviewContent() {
    if (_frameBytes != null && _frameBytes!.isNotEmpty) {
      return Image.memory(
        _frameBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF283E51),
            Color(0xFF4B79A1),
            Color(0xFFE06D53),
            Color(0xFF1F1C2C),
          ],
        ),
      ),
      child: _isCapturingFrame
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CircleAvatar(radius: 22, backgroundColor: Color(0xFFFFB703)),
                CircleAvatar(radius: 22, backgroundColor: Color(0xFFFB8500)),
                CircleAvatar(radius: 22, backgroundColor: Color(0xFF8ECAE6)),
                CircleAvatar(radius: 22, backgroundColor: Color(0xFFFF006E)),
              ],
            ),
    );
  }

  Widget _buildSplitPreview(ColorScheme cs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final dividerX = (width * _splitPosition).clamp(12.0, width - 12.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            setState(() {
              _splitPosition = (details.localPosition.dx / width).clamp(
                0.05,
                0.95,
              );
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _splitPosition = (details.localPosition.dx / width).clamp(
                0.05,
                0.95,
              );
            });
          },
          child: Container(
            height: 158,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.24),
                width: 0.8,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(_buildColorMatrix()),
                  child: _buildPreviewContent(),
                ),
                ClipRect(
                  clipper: _LeftSplitClipper(_splitPosition),
                  child: _buildPreviewContent(),
                ),
                Positioned(
                  left: dividerX - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Positioned(
                  left: dividerX - 13,
                  top: 66,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary, width: 1.5),
                    ),
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      size: 15,
                      color: cs.primary,
                    ),
                  ),
                ),
                Positioned(left: 10, top: 10, child: _buildBadge('BEFORE')),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBadge('AFTER'),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _captureCurrentFrame,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _openFullScreenPreview(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 8,
                  child: _buildBadge(
                    _frameBytes != null
                        ? 'Live Stream Frame • Drag to compare'
                        : 'Drag slider to compare Before & After',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullScreenPreview(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final presetKeys = ColorProfileManager.profiles.keys.toList();
    double fullSplit = _splitPosition;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Full Screen Preview',
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, _, __) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final matrix = _buildColorMatrix();
            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final dx = (w * fullSplit).clamp(16.0, w - 16.0);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) {
                        final next = (d.localPosition.dx / w).clamp(0.03, 0.97);
                        setDialogState(() => fullSplit = next);
                        if (mounted) setState(() => _splitPosition = next);
                      },
                      onHorizontalDragUpdate: (d) {
                        final next = (d.localPosition.dx / w).clamp(0.03, 0.97);
                        setDialogState(() => fullSplit = next);
                        if (mounted) setState(() => _splitPosition = next);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.matrix(matrix),
                            child: _buildPreviewContent(),
                          ),
                          ClipRect(
                            clipper: _LeftSplitClipper(fullSplit),
                            child: _buildPreviewContent(),
                          ),
                          Positioned(
                            left: dx - 1,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          Positioned(
                            left: dx - 16,
                            top: (h / 2) - 16,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: cs.surface.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cs.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.compare_arrows_rounded,
                                size: 18,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            top: 16,
                            child: _buildBadge('BEFORE'),
                          ),
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildBadge('AFTER'),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () async {
                                    await _captureCurrentFrame();
                                    setDialogState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.62,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () =>
                                      Navigator.of(dialogContext).pop(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.62,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildBadge(
                                  'Profile: ${_selectedProfile.replaceAll('_', ' ').toUpperCase()} • Drag to compare',
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: presetKeys.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (_, idx) {
                                      final key = presetKeys[idx];
                                      final isSel =
                                          _selectedProfile.toLowerCase() == key;
                                      final icon =
                                          ColorProfileManager
                                              .profileIcons[key] ??
                                          Icons.palette_rounded;
                                      return Material(
                                        color: isSel
                                            ? cs.primary
                                            : Colors.black.withValues(
                                                alpha: 0.68,
                                              ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap: () async {
                                            if (mounted) {
                                              setState(() {
                                                _selectedProfile = key;
                                                _customSettings = Map.from(
                                                  ColorProfileManager
                                                      .profiles[key]!,
                                                );
                                              });
                                            } else {
                                              _selectedProfile = key;
                                              _customSettings = Map.from(
                                                ColorProfileManager
                                                    .profiles[key]!,
                                              );
                                            }
                                            setDialogState(() {});
                                            await ColorProfileManager()
                                                .applyColorProfile(
                                                  key,
                                                  widget.player,
                                                );
                                            widget.onProfileSelected(key);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSel
                                                    ? cs.primary
                                                    : Colors.white.withValues(
                                                        alpha: 0.22,
                                                      ),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  icon,
                                                  size: 15,
                                                  color: isSel
                                                      ? cs.onPrimary
                                                      : Colors.white,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  key
                                                      .replaceAll('_', ' ')
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSel
                                                        ? cs.onPrimary
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.85,
      constraints: const BoxConstraints(maxWidth: 560),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tune_rounded, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AzyXText(
                      text: 'Color & Shaders',
                      fontVariant: FontVariant.bold,
                      fontSize: 17,
                      color: cs.onSurface,
                    ),
                    Text(
                      'Active: ${_selectedProfile.replaceAll('_', ' ').toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSplitPreview(cs),
          const SizedBox(height: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildTabItem(cs, 0, 'Presets'),
                _buildTabItem(cs, 1, 'Custom'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _currentTab == 0
                ? _buildPresetsList(cs)
                : _buildCustomList(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(ColorScheme cs, int index, String label) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? cs.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetsList(ColorScheme cs) {
    final entries = ColorProfileManager.profiles.entries.toList();
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final key = entries[index].key;
        final isSelected = _selectedProfile.toLowerCase() == key;
        final desc = ColorProfileManager.profileDescriptions[key] ?? '';
        final icon =
            ColorProfileManager.profileIcons[key] ?? Icons.palette_rounded;
        return Material(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.14)
              : cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedProfile = key;
                _customSettings = Map.from(entries[index].value);
              });
              await ColorProfileManager().applyColorProfile(key, widget.player);
              widget.onProfileSelected(key);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.5)
                      : cs.outlineVariant.withValues(alpha: 0.18),
                  width: isSelected ? 1.2 : 0.6,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary
                          : cs.surfaceContainerHighest.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomList(ColorScheme cs) {
    final keys = ['brightness', 'contrast', 'saturation', 'gamma', 'hue'];
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.18),
              width: 0.6,
            ),
          ),
          child: Column(
            children: keys.map((k) {
              final val = (_customSettings[k] ?? 0).toDouble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          k[0].toUpperCase() + k.substring(1),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '${val.round()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      min: -100,
                      max: 100,
                      value: val.clamp(-100, 100),
                      onChanged: (next) async {
                        setState(() {
                          _customSettings[k] = next.round();
                          _selectedProfile = 'custom';
                        });
                        await ColorProfileManager().applyCustomSettings(
                          _customSettings,
                          widget.player,
                        );
                        widget.onCustomSettingsChanged(_customSettings);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            setState(() {
              _selectedProfile = 'natural';
              _customSettings = Map.from(
                ColorProfileManager.profiles['natural']!,
              );
            });
            await ColorProfileManager().applyColorProfile(
              'natural',
              widget.player,
            );
            widget.onProfileSelected('natural');
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Reset to Natural'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeftSplitClipper extends CustomClipper<Rect> {
  final double splitFraction;
  const _LeftSplitClipper(this.splitFraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * splitFraction, size.height);
  }

  @override
  bool shouldReclip(covariant _LeftSplitClipper oldClipper) {
    return oldClipper.splitFraction != splitFraction;
  }
}
