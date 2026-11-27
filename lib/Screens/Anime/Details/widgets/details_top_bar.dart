import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/glass_surface.dart';
import 'package:flutter/material.dart';

class DetailsTopBar extends StatefulWidget {
  final VoidCallback? onBackTap;
  final bool showBackButton;
  final String? title;
  final String categoryLabel;

  const DetailsTopBar({
    super.key,
    this.onBackTap,
    this.showBackButton = true,
    this.title,
    this.categoryLabel = 'Anime',
  });

  @override
  State<DetailsTopBar> createState() => _DetailsTopBarState();
}

class _DetailsTopBarState extends State<DetailsTopBar> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tones = AzTonesProvider.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isNarrow = MediaQuery.of(context).size.width < 680;

    if (!widget.showBackButton) {
      return const SizedBox.shrink();
    }

    final hasTitle = widget.title != null && widget.title!.trim().isNotEmpty;

    return RepaintBoundary(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
          padding: EdgeInsets.fromLTRB(
            isNarrow ? 16.0 : AzTokens.horizontalPadding,
            topPadding + 12.0,
            isNarrow ? 16.0 : AzTokens.horizontalPadding,
            12.0,
          ),
          child: Row(
            children: [
              Flexible(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedScale(
                    scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    child: GlassSurface(
                      borderRadius: 24.0,
                      blurSigma: 26.0,
                      fillColor: colorScheme.surfaceContainer.withValues(
                        alpha: _isHovered ? 0.82 : 0.68,
                      ),
                      borderColor: tones.accent.withValues(
                        alpha: _isHovered ? 0.42 : 0.22,
                      ),
                      borderWidth: 0.8,
                      child: InkWell(
                        onTap:
                            widget.onBackTap ??
                            () => Navigator.of(context).maybePop(),
                        onTapDown: (_) => setState(() => _isPressed = true),
                        onTapUp: (_) => setState(() => _isPressed = false),
                        onTapCancel: () => setState(() => _isPressed = false),
                        borderRadius: BorderRadius.circular(24.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: tones.accent.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16.5,
                                  color: tones.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (hasTitle) ...[
                                Text(
                                  widget.categoryLabel,
                                  style: AzTokens.caption(
                                    colorScheme.onSurfaceVariant,
                                    12.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    '/',
                                    style: AzTokens.caption(
                                      colorScheme.onSurfaceVariant.withValues(
                                        alpha: 0.55,
                                      ),
                                      12.5,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    widget.title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AzTokens.body(
                                      color: colorScheme.onSurface,
                                      weight: FontWeight.w600,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ] else
                                Text(
                                  'Back',
                                  style: AzTokens.body(
                                    color: colorScheme.onSurface,
                                    weight: FontWeight.w600,
                                    size: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
