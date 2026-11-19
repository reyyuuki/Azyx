import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:flutter/material.dart';

class AzChip extends StatelessWidget {
  final String label;
  final bool isOn;
  final bool? isActive;
  final VoidCallback? onTap;
  final Widget? leading;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const AzChip({
    super.key,
    required this.label,
    this.isOn = false,
    this.isActive,
    this.onTap,
    this.leading,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final tones = AzTonesProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final active = isActive ?? isOn;

    final bgColor = active
        ? tones.soft
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final textColor = active
        ? tones.accent
        : colorScheme.onSurface.withValues(alpha: 0.88);

    final chip = Container(
      height: 28.0,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AzTokens.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14.0,
              color: textColor,
            ),
            const SizedBox(width: 6.0),
          ] else if (leading != null) ...[
            leading!,
            const SizedBox(width: 6.0),
          ],
          Text(
            label,
            style: AzTokens.chipText(color: textColor),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }

    return chip;
  }
}
