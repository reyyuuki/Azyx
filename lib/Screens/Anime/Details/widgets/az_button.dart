import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:flutter/material.dart';

enum AzButtonVariant {
  primary,
  tonal,
  tonalOn,
  square,
}

class AzButton extends StatefulWidget {
  final String? label;
  final dynamic icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final AzButtonVariant variant;
  final bool isSquare;
  final bool isOn;
  final double? width;
  final String? semanticsLabel;

  const AzButton({
    super.key,
    this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.onPressed,
    this.variant = AzButtonVariant.primary,
    this.isSquare = false,
    this.isOn = false,
    this.width,
    this.semanticsLabel,
  });

  const AzButton.primary({
    super.key,
    required String this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.onPressed,
    this.width,
    this.semanticsLabel,
  })  : variant = AzButtonVariant.primary,
        isSquare = false,
        isOn = false;

  const AzButton.tonal({
    super.key,
    required String this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.onPressed,
    this.isOn = false,
    this.width,
    this.semanticsLabel,
  })  : variant = isOn ? AzButtonVariant.tonalOn : AzButtonVariant.tonal,
        isSquare = false;

  const AzButton.square({
    super.key,
    required this.icon,
    this.onTap,
    this.onPressed,
    this.isOn = false,
    this.semanticsLabel,
  })  : variant = AzButtonVariant.square,
        label = null,
        trailing = null,
        width = 50.0,
        isSquare = true;

  @override
  State<AzButton> createState() => _AzButtonState();
}

class _AzButtonState extends State<AzButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tones = AzTonesProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    switch (widget.variant) {
      case AzButtonVariant.primary:
        bg = tones.accent;
        fg = tones.onAccent;
        break;
      case AzButtonVariant.tonal:
        bg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
        fg = colorScheme.onSurface;
        break;
      case AzButtonVariant.tonalOn:
        bg = tones.soft;
        fg = tones.accent;
        break;
      case AzButtonVariant.square:
        bg = widget.isOn
            ? tones.soft
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
        fg = widget.isOn ? tones.accent : colorScheme.onSurface;
        break;
    }

    Widget? resolvedIcon;
    if (widget.icon is IconData) {
      resolvedIcon = Icon(widget.icon as IconData, size: 20.0, color: fg);
    } else if (widget.icon is Widget) {
      resolvedIcon = IconTheme(
        data: IconThemeData(color: fg, size: 20.0),
        child: widget.icon as Widget,
      );
    }

    final effectiveOnTap = widget.onTap ?? widget.onPressed;

    final child = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        height: 50.0,
        width: widget.isSquare ? 50.0 : widget.width,
        padding: widget.isSquare
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 18.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AzTokens.radiusButton),
        ),
        alignment: widget.width != null ? Alignment.center : null,
        child: Row(
          mainAxisSize:
              widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (resolvedIcon != null) ...[
              resolvedIcon,
              if (widget.label != null) const SizedBox(width: 8.0),
            ],
            if (widget.label != null)
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  widget.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AzTokens.buttonText(color: fg),
                ),
              ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 6.0),
              IconTheme(
                data: IconThemeData(color: fg, size: 18.0),
                child: widget.trailing!,
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => _animController.forward(),
          onTapUp: (_) => _animController.reverse(),
          onTapCancel: () => _animController.reverse(),
          onTap: effectiveOnTap,
          behavior: HitTestBehavior.opaque,
          child: child,
        ),
      ),
    );
  }
}
