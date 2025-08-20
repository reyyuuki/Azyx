// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, file_names

import 'dart:developer';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/AlertDialogBuilder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../main.dart';

class ExtensionListTileWidget extends StatefulWidget {
  final Source source;
  final ItemType mediaType;

  const ExtensionListTileWidget({
    super.key,
    required this.source,
    required this.mediaType,
  });

  @override
  State<ExtensionListTileWidget> createState() =>
      _ExtensionListTileWidgetState();
}

class _ExtensionListTileWidgetState extends State<ExtensionListTileWidget>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  double _installProgress = 0.0;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
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

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

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
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _handleSourceAction() async {
    setState(() {
      _isLoading = true;
      _installProgress = 0.0;
    });

    _progressController.reset();
    _progressController.forward();

    try {
      // More realistic progress animation
      for (int i = 0; i <= 90; i += 15) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() => _installProgress = i / 100);
        }
      }

      await widget.source.extensionType
          ?.getManager()
          .installSource(widget.source);
      await sourceController.sortExtensions();

      // Complete the progress quickly
      if (mounted) {
        setState(() => _installProgress = 1.0);
        // Immediately hide loading state after completion
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _isLoading = false;
          _installProgress = 0.0;
        });
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _installProgress = 0.0;
        });
      }
    }
  }

  List<Source> get _installedExtensions {
    switch (widget.mediaType) {
      case ItemType.manga:
        return sourceController.installedMangaExtensions.value;
      case ItemType.anime:
        return sourceController.installedExtensions.value;
      case ItemType.novel:
        return sourceController.installedNovelExtensions.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final updateAvailable = widget.source.hasUpdate ?? false;
    final sourceNotEmpty =
        _installedExtensions.any((e) => e.id == widget.source.id);

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
                if (_isLoading)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.surfaceVariant.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _installProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primary,
                                theme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildIconContainer(theme, updateAvailable),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ShaderMask(
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: _buildSubtitleRow(theme)),
                                const SizedBox(width: 8),
                                _buildExtensionTypeBadge(theme),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildButtons(sourceNotEmpty, updateAvailable, theme),
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

  Widget _buildExtensionTypeBadge(ColorScheme theme) {
    if (widget.source.extensionType == null) return const SizedBox();

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.primaryContainer.withOpacity(0.4),
        border: Border.all(
          color: theme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: getExtensionIcon(widget.source.extensionType!),
          fit: BoxFit.cover,
          placeholder: (context, url) => Icon(
            Icons.extension,
            color: theme.onPrimaryContainer,
            size: 16,
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.extension,
            color: theme.onPrimaryContainer,
            size: 16,
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
                  child: widget.source.iconUrl?.isEmpty ?? true
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
        if (widget.source.isNsfw ?? false)
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

  Widget _buildButtons(
      bool sourceNotEmpty, bool updateAvailable, ColorScheme theme) {
    void onTap() async {
      if (updateAvailable) {
        setState(() => _isLoading = true);
        try {
          widget.source.extensionType!.getManager().update([widget.source.id!]);
          await sourceController.sortExtensions();
        } catch (e) {
          log("Update Failed => ${e.toString()}");
        }
        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else {
        AlertDialogBuilder(context)
          ..setTitle("Delete Extension")
          ..setMessage("Are you sure you want to delete this extension?")
          ..setPositiveButton("Yes", () async {
            setState(() => _isLoading = true);
            try {
              log("Uninstalling => ${widget.source.id}");
              await widget.source.extensionType!
                  .getManager()
                  .uninstallSource(widget.source);
              await sourceController.sortExtensions();
            } catch (e) {
              log("Uninstall Failed => ${e.toString()}");
            }
            if (mounted) {
              setState(() => _isLoading = false);
            }
          })
          ..setNegativeButton("No", () => Get.back())
          ..show();
      }
    }

    return !sourceNotEmpty
        ? Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.onPrimaryContainer,
                        value:
                            _installProgress == 0.0 ? null : _installProgress,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _isLoading ? null : () => _handleSourceAction(),
                    icon: Icon(
                      Icons.download,
                      color: theme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
          )
        : SizedBox(
            width: 104,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: updateAvailable
                        ? theme.tertiaryContainer
                        : theme.errorContainer.withAlpha(122),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onTap,
                    icon: Icon(
                      size: 16,
                      updateAvailable ? Icons.update : Broken.trash,
                      color: updateAvailable
                          ? theme.onTertiaryContainer
                          : theme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {},
                    icon: Icon(
                      Iconsax.setting_2_bold,
                      size: 16,
                      color: theme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
