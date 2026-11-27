import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/baked_blur_image.dart';
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
              ClipRect(
                child: Transform.scale(
                  scale: 1.12,
                  child: BakedBlurImage(
                    url: imageUrl,
                    fallbackUrl: coverUrl,
                    blurSigma: 12.0,
                    opacity: 0.58,
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
