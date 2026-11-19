import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/widgets/glass_surface.dart';
import 'package:flutter/material.dart';

class DetailsTopBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const DetailsTopBar({
    super.key,
    required this.onSearchTap,
    this.onBackTap,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = AzTokens.isExpanded(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.fromLTRB(18.0, topPadding + 12.0, 18.0, 12.0),
        child: Row(
          children: [
            if (showBackButton)
              GlassSurface(
                borderRadius: 21.0,
                child: InkWell(
                  onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(21.0),
                  child: SizedBox(
                    width: 42.0,
                    height: 42.0,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18.0,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            GlassSurface(
              borderRadius: 21.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(21.0),
                child: SizedBox(
                  height: 42.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Search anime',
                        style: AzTokens.body(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 10.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            '/',
                            style: AzTokens.chipText(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
