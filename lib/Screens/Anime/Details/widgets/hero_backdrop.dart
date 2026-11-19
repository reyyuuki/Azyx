import 'dart:ui';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HeroBackdrop extends StatelessWidget {
  final String? bannerUrl;
  final String? coverUrl;
  final double height;

  const HeroBackdrop({
    super.key,
    this.bannerUrl,
    this.coverUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final tones = AzTonesProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasBanner = bannerUrl != null && bannerUrl!.isNotEmpty;
    final imageUrl = hasBanner ? bannerUrl! : (coverUrl ?? '');

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              hasBanner
                  ? Opacity(
                      opacity: 0.55,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 1400,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    )
                  : ClipRect(
                      child: Transform.scale(
                        scale: 1.25,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 38.0, sigmaY: 38.0),
                          child: Opacity(
                            opacity: 0.50,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 800,
                              errorWidget: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -0.6),
                  radius: 0.9,
                  colors: [
                    tones.glow,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.15),
                    colorScheme.surface.withValues(alpha: 0.85),
                    colorScheme.surface,
                  ],
                  stops: const [0.0, 0.7, 0.96],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
