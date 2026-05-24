import 'dart:developer';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/AlertDialogBuilder.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

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
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double _installProgress = 0.0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleSourceAction() async {
    setState(() {
      _isLoading = true;
      _installProgress = 0.0;
    });

    try {
      for (int i = 0; i <= 90; i += 15) {
        await Future.delayed(const Duration(milliseconds: 80));
        if (mounted) setState(() => _installProgress = i / 100);
      }
      await widget.source.install();
      if (mounted) {
        setState(() => _installProgress = 1.0);
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _installProgress = 0.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _installProgress = 0.0;
        });
        azyxSnackBar(e.toString());
      }
    }
  }

  List<Source> get _installedExtensions {
    switch (widget.mediaType) {
      case ItemType.manga:
        return sourceController.installedMangaExtensions;
      case ItemType.anime:
        return sourceController.installedExtensions;
      case ItemType.novel:
        return sourceController.installedNovelExtensions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final updateAvailable = widget.source.hasUpdate ?? false;
    final isInstalled = _installedExtensions.any((e) => e.id == widget.source.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            if (_isLoading)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _installProgress,
                  minHeight: 2,
                  backgroundColor: theme.surfaceContainerHighest,
                  color: theme.primary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _buildIcon(theme, updateAvailable),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.source.name!,
                          style: TextStyle(
                            color: theme.onSurface,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildMeta(theme),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildActions(isInstalled, updateAvailable, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme theme, bool updateAvailable) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: updateAvailable ? _pulseAnimation.value : 1.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.source.iconUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: widget.source.iconUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Icon(
                            Icons.extension_rounded,
                            color: theme.primary,
                            size: 22,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.extension_rounded,
                            color: theme.primary,
                            size: 22,
                          ),
                        )
                      : Icon(
                          Icons.extension_rounded,
                          color: theme.primary,
                          size: 22,
                        ),
                ),
              ),
              if (updateAvailable)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeta(ColorScheme theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "v${widget.source.version!}",
            style: TextStyle(
              color: theme.onSecondaryContainer,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: theme.surfaceContainerHighest.withOpacity(0.6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: widget.source.managerIcon,
              fit: BoxFit.cover,
              placeholder: (_, __) => Icon(
                Icons.extension,
                color: theme.onSurface.withOpacity(0.5),
                size: 12,
              ),
              errorWidget: (_, __, ___) => Icon(
                Icons.extension,
                color: theme.onSurface.withOpacity(0.5),
                size: 12,
              ),
            ),
          ),
        ),
        if (widget.source.isNsfw ?? false) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.errorContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "18+",
              style: TextStyle(
                color: theme.onErrorContainer,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(
    bool isInstalled,
    bool updateAvailable,
    ColorScheme theme,
  ) {
    if (_isLoading && !isInstalled) {
      return SizedBox(
        width: 20,
        height: 20,
        child: LoadingIndicatorM3E(color: theme.primary),
      );
    }

    if (!isInstalled) {
      return IconButton(
        onPressed: _handleSourceAction,
        icon: Icon(Icons.download_rounded, color: theme.primary, size: 22),
        style: IconButton.styleFrom(
          backgroundColor: theme.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: LoadingIndicatorM3E(),
          )
        else
          IconButton(
            onPressed: () => _onInstalledTap(updateAvailable),
            padding: const EdgeInsets.all(8),
            style: IconButton.styleFrom(
              backgroundColor: updateAvailable
                  ? theme.primary.withOpacity(0.1)
                  : theme.errorContainer.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              updateAvailable ? Icons.update_rounded : Broken.trash,
              color: updateAvailable ? theme.primary : theme.error,
              size: 18,
            ),
          ),
      ],
    );
  }

  void _onInstalledTap(bool updateAvailable) {
    if (updateAvailable) {
      setState(() => _isLoading = true);
      widget.source.update().then((_) {
        return sourceController.fetchRepos();
      }).catchError((e) {
        azyxSnackBar(e.toString());
      }).whenComplete(() {
        if (mounted) setState(() => _isLoading = false);
      });
    } else {
      AlertDialogBuilder(context)
        ..setTitle("Remove Extension")
        ..setMessage("Remove ${widget.source.name}?")
        ..setPositiveButton("Remove", () async {
          if (!mounted) return;
          setState(() => _isLoading = true);
          try {
            await widget.source.uninstall();
          } catch (e) {
            azyxSnackBar('$e');
          }
          if (mounted) setState(() => _isLoading = false);
        })
        ..setNegativeButton("Cancel", () => Get.back())
        ..show();
    }
  }
}
