import 'dart:async';
import 'dart:math' as math;

import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class MainCarousale extends StatefulWidget {
  final List<Media> data;
  final bool isManga;
  const MainCarousale({super.key, required this.data, required this.isManga});

  @override
  State<MainCarousale> createState() => _MainCarousaleState();
}

class _MainCarousaleState extends State<MainCarousale> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  double _pageDelta = 0;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.data.isNotEmpty ? widget.data.length ~/ 2 : 0;
    _currentIndex = initialPage;
    _pageDelta = initialPage.toDouble();
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: initialPage,
    );
    _pageController.addListener(_onScroll);
    _startAutoPlay();
  }

  void _onScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page ?? 0;
    setState(() {
      _pageDelta = page;
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.data.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentIndex + 1) % widget.data.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoPlay() => _autoPlayTimer?.cancel();

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: LoadingIndicatorM3E(color: colorScheme.primary),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 6),
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            itemCount: widget.data.length,
            onPageChanged: (i) {
              _currentIndex = i;
              setState(() {});
            },
            itemBuilder: (context, index) {
              return _buildHeroCard(index);
            },
          ),
        ),
        if (widget.data.length > 1) ...[
          const SizedBox(height: 10),
          _SlideIndicator(
            count: widget.data.length,
            current: _currentIndex,
            onTap: (i) {
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildHeroCard(int index) {
    final anime = widget.data[index];
    double diff = (index - _pageDelta);
    double absDiff = diff.abs().clamp(0.0, 1.0);

    double scale = 1.0 - (absDiff * 0.04);
    double cardOpacity = 1.0 - (absDiff * 0.2);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: cardOpacity.clamp(0.0, 1.0),
        child: _HeroCardContent(
          anime: anime,
          isManga: widget.isManga,
          index: index,
          onTap: () => _navigateToDetails(anime),
        ),
      ),
    );
  }

  void _navigateToDetails(Media anime) {
    HapticFeedback.lightImpact();
    _stopAutoPlay();
    final screen = widget.isManga
        ? MangaDetailsScreen(
            smallMedia: CarousaleData(
              id: anime.id!,
              image: anime.image!,
              title: anime.title!,
            ),
            tagg: "${anime.id}MainCarousale",
          )
        : AnimeDetailsScreen(
            smallMedia: CarousaleData(
              id: anime.id!,
              image: anime.image!,
              title: anime.title!,
            ),
            tagg: "${anime.id}MainCarousale",
          );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _startAutoPlay());
  }
}

class _HeroCardContent extends StatelessWidget {
  final Media anime;
  final bool isManga;
  final int index;
  final VoidCallback onTap;

  const _HeroCardContent({
    required this.anime,
    required this.isManga,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgUrl = (anime.bannerImage != null && anime.bannerImage!.isNotEmpty)
        ? anime.bannerImage!
        : (anime.image ?? '');

    final rating = _parseRating(anime.rating);

    return Obx(() {
      final rMult = uiSettingController.radiusMultiplier;
      final cardRadius = (18.0 * rMult).clamp(4.0, 36.0);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: bgUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const ShimmerEffect(
                      height: 195,
                      width: double.infinity,
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      Container(color: colorScheme.surfaceContainerHighest),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.92),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.15),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "#${index + 1} SPOTLIGHT",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        if (rating > 0) ...[const SizedBox(width: 6)],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anime.title ?? "Unknown",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (anime.type != null && anime.type!.isNotEmpty) ...[
                          Text(
                            anime.type!.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _buildDot(),
                        ],
                        if (anime.episodes != null && anime.episodes! > 0) ...[
                          Text(
                            isManga
                                ? "${anime.episodes} Chapters"
                                : "${anime.episodes} Episodes",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _buildDot(),
                        ],
                        if (anime.status != null &&
                            anime.status!.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              anime.status!.toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isManga
                                    ? Icons.auto_stories_rounded
                                    : Icons.play_arrow_rounded,
                                color: colorScheme.onPrimary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isManga ? "Read Now" : "Watch Now",
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        "•",
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8),
      ),
    );
  }

  double _parseRating(String? r) {
    if (r == null || r.isEmpty || r == "N/A") return 0;
    try {
      if (r.contains('%')) {
        return double.parse(r.replaceAll('%', '').trim()) / 20;
      }
      return (double.parse(r) / 2).clamp(0.0, 5.0);
    } catch (_) {
      return 0;
    }
  }
}

class _SlideIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Function(int) onTap;

  const _SlideIndicator({
    required this.count,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visible = math.min(count, 7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visible, (i) {
        final active = i == current % visible;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            width: active ? 16 : 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: active
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        );
      }),
    );
  }
}
