// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, file_names

import 'package:azyx/Extensions/ExtensionSettings/ExtensionSettings.dart';
import 'package:azyx/Widgets/AlertDialogBuilder.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/source_preference.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:isar/isar.dart';

import '../../api/Mangayomi/Extensions/GetSourceList.dart';
import '../../api/Mangayomi/Extensions/fetch_anime_sources.dart';
import '../../api/Mangayomi/Extensions/fetch_manga_sources.dart';
import '../../main.dart';

class ExtensionListTileWidget extends ConsumerStatefulWidget {
  final Source source;
  final bool isTestSource;

  const ExtensionListTileWidget({
    super.key,
    required this.source,
    this.isTestSource = false,
  });

  @override
  ConsumerState<ExtensionListTileWidget> createState() =>
      _ExtensionListTileWidgetState();
}

class _ExtensionListTileWidgetState
    extends ConsumerState<ExtensionListTileWidget>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleSourceAction() async {
    setState(() => _isLoading = true);

    if (widget.source.isManga!) {
      await ref.read(
          fetchMangaSourcesListProvider(id: widget.source.id, reFresh: true)
              .future);
    } else {
      await ref.read(
          fetchAnimeSourcesListProvider(id: widget.source.id, reFresh: true)
              .future);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final updateAvailable = widget.isTestSource
        ? false
        : compareVersions(widget.source.version!, widget.source.versionLast!) <
            0;
    final sourceNotEmpty = widget.source.sourceCode?.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.7, 1.0],
              colors: [
                theme.surface,
                theme.surface.withOpacity(0.95),
                theme.surface.withOpacity(0.9),
                theme.surface.withOpacity(0.85),
              ],
            ),
            border: Border.all(
              color: theme.outline.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: theme.primary.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 4),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle shimmer effect
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(_shimmerAnimation.value - 1, 0),
                          end: Alignment(_shimmerAnimation.value, 0),
                          colors: [
                            Colors.transparent,
                            theme.primary.withOpacity(0.02),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Enhanced icon container
                      _buildIconContainer(theme, updateAvailable),
                      const SizedBox(width: 16),
                      // Content section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with gradient text effect
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  theme.onSurface,
                                  theme.onSurface.withOpacity(0.8),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                widget.source.name!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Enhanced subtitle row
                            _buildSubtitleRow(theme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Enhanced action buttons
                      _buildActionButtons(
                          sourceNotEmpty, updateAvailable, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(ColorScheme theme, bool updateAvailable) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: updateAvailable ? _pulseAnimation.value : 1.0,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryContainer.withOpacity(0.8),
                  theme.primaryContainer.withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: theme.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: widget.source.iconUrl!.isEmpty
                      ? Icon(
                          Icons.extension_rounded,
                          color: theme.onPrimaryContainer,
                          size: 28,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: widget.source.iconUrl!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            placeholder: (context, url) => Icon(
                              Icons.extension_rounded,
                              color: theme.onPrimaryContainer,
                              size: 28,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.extension_rounded,
                              color: theme.onPrimaryContainer,
                              size: 28,
                            ),
                          ),
                        ),
                ),
                if (updateAvailable)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.surface,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_upward,
                          color: theme.onError,
                          size: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitleRow(ColorScheme theme) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        // Version badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: theme.secondaryContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            "v${widget.source.version!}",
            style: TextStyle(
              color: theme.onSecondaryContainer,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 10.0,
              letterSpacing: 0.3,
            ),
          ),
        ),
        // NSFW badge
        if (widget.source.isNsfw!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.errorContainer.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "18+",
              style: TextStyle(
                color: theme.onErrorContainer,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 9.0,
                letterSpacing: 0.2,
              ),
            ),
          ),
        // Obsolete badge
        if (widget.source.isObsolete ?? false)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.error.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              "OBSOLETE",
              style: TextStyle(
                color: theme.error,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 9.0,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
      bool sourceNotEmpty, bool updateAvailable, ColorScheme theme) {
    if (_isLoading) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
          ),
        ),
      );
    }

    if (!sourceNotEmpty) {
      return _buildGlowingButton(
        icon: Icons.download_rounded,
        onPressed: _handleSourceAction,
        theme: theme,
        isPrimary: true,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlowingButton(
          icon:
              updateAvailable ? Icons.update_rounded : FontAwesome.trash_solid,
          onPressed: () => _handleUpdateOrDelete(updateAvailable),
          theme: theme,
          isPrimary: updateAvailable,
          isDestructive: !updateAvailable,
        ),
        const SizedBox(width: 8),
        _buildGlowingButton(
          icon: FontAwesome.ellipsis_vertical_solid,
          onPressed: () async {
            Get.to(() => SourcePreferenceWidget(
                  source: widget.source,
                  sourcePreference: [],
                ));
          },
          theme: theme,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildGlowingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ColorScheme theme,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    Color buttonColor;
    Color iconColor;
    Color glowColor;

    if (isDestructive) {
      buttonColor = theme.errorContainer.withOpacity(0.8);
      iconColor = theme.onErrorContainer;
      glowColor = theme.error;
    } else if (isPrimary) {
      buttonColor = theme.primaryContainer.withOpacity(0.9);
      iconColor = theme.onPrimaryContainer;
      glowColor = theme.primary;
    } else {
      buttonColor = theme.tertiaryContainer.withOpacity(0.8);
      iconColor = theme.onTertiaryContainer;
      glowColor = theme.tertiary;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: glowColor.withOpacity(0.2),
          highlightColor: glowColor.withOpacity(0.1),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: glowColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleUpdateOrDelete(bool updateAvailable) async {
    if (updateAvailable) {
      setState(() => _isLoading = true);
      widget.source.isManga!
          ? await ref.watch(
              fetchMangaSourcesListProvider(id: widget.source.id, reFresh: true)
                  .future)
          : await ref.watch(
              fetchAnimeSourcesListProvider(id: widget.source.id, reFresh: true)
                  .future);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } else {
      AlertDialogBuilder(context)
        ..setTitle("Delete Extension")
        ..setMessage("Are you sure you want to delete this extension?")
        ..setPositiveButton("Yes", () async {
          final sourcePrefsIds = isar.sourcePreferences
              .filter()
              .sourceIdEqualTo(widget.source.id!)
              .findAllSync()
              .map((e) => e.id!)
              .toList();
          final sourcePrefsStringIds = isar.sourcePreferenceStringValues
              .filter()
              .sourceIdEqualTo(widget.source.id!)
              .findAllSync()
              .map((e) => e.id)
              .toList();
          isar.writeTxnSync(() {
            if (widget.source.isObsolete ?? false) {
              isar.sources.deleteSync(widget.source.id!);
            } else {
              isar.sources.putSync(widget.source
                ..sourceCode = ""
                ..isAdded = false
                ..isPinned = false);
            }
            isar.sourcePreferences.deleteAllSync(sourcePrefsIds);
            isar.sourcePreferenceStringValues
                .deleteAllSync(sourcePrefsStringIds);
          });
        })
        ..setNegativeButton("No", null)
        ..show();
    }
  }
}
