// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class MainCarousale extends StatefulWidget {
  final List<Media> data;
  final bool isManga;
  const MainCarousale({super.key, required this.data, required this.isManga});

  @override
  State<MainCarousale> createState() => _MainCarousaleState();
}

class _MainCarousaleState extends State<MainCarousale>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entryController;
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
      viewportFraction: 0.74,
      initialPage: initialPage,
    );
    _pageController.addListener(_onScroll);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _entryController.forward();
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
        duration: const Duration(milliseconds: 800),
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
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: 380,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: LoadingIndicatorM3E(color: colorScheme.primary),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        final entryValue = CurvedAnimation(
          parent: _entryController,
          curve: Curves.easeOutCubic,
        ).value;

        return Opacity(
          opacity: entryValue,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - entryValue)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 6),
          SizedBox(
            height: 380,
            child: PageView.builder(
              controller: _pageController,
              clipBehavior: Clip.none,
              itemCount: widget.data.length,
              onPageChanged: (i) {
                _currentIndex = i;
                setState(() {});
              },
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
          if (widget.data.length > 1) ...[
            const SizedBox(height: 16),
            _SlideIndicator(
              count: widget.data.length,
              current: _currentIndex,
              onTap: (i) {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final anime = widget.data[index];
    double diff = (index - _pageDelta);
    double absDiff = diff.abs().clamp(0.0, 1.0);

    double scale = 1.0 - (absDiff * 0.08);
    double translateY = absDiff * 14;
    double rotateY = diff * -0.06;
    double cardOpacity = 1.0 - (absDiff * 0.35);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotateY)
        ..scale(scale)
        ..translate(0.0, translateY),
      child: Opacity(
        opacity: cardOpacity.clamp(0.0, 1.0),
        child: _CinematicCard(
          anime: anime,
          isManga: widget.isManga,
          parallaxOffset: diff * 24,
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

class _CinematicCard extends StatelessWidget {
  final Media anime;
  final bool isManga;
  final double parallaxOffset;
  final VoidCallback onTap;

  const _CinematicCard({
    required this.anime,
    required this.isManga,
    required this.parallaxOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(parallaxOffset, 0),
                child: CachedNetworkImage(
                  imageUrl: anime.image ?? anime.bannerImage ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const ShimmerEffect(
                      height: 380,
                      width: double.infinity,
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      Container(color: colorScheme.surfaceContainerHighest),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopChips(),
                    const Spacer(),
                    _buildBottomInfo(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopChips() {
    final rating = _parseRating(anime.rating);
    return Row(
      children: [
        _GlassChip(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isManga
                    ? Icons.auto_stories_rounded
                    : Icons.play_circle_rounded,
                color: Colors.white,
                size: 11,
              ),
              const SizedBox(width: 4),
              Text(
                isManga ? "MANGA" : "ANIME",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        if (rating > 0) ...[
          const SizedBox(width: 6),
          _GlassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                const SizedBox(width: 3),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                anime.title ?? "Unknown",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  if (anime.type != null && anime.type!.isNotEmpty) ...[
                    Text(
                      anime.type!.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildDotSeparator(),
                  ],
                  if (anime.episodes != null && anime.episodes! > 0) ...[
                    Text(
                      isManga
                          ? "${anime.episodes} Chs"
                          : "${anime.episodes} Eps",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _buildDotSeparator(),
                  ],
                  if (anime.status != null && anime.status!.isNotEmpty) ...[
                    Flexible(
                      child: Text(
                        anime.status!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                isManga ? Icons.auto_stories_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        "•",
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 7),
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

class _GlassChip extends StatelessWidget {
  final Widget child;
  const _GlassChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            width: active ? 14 : 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: active
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.15),
            ),
          ),
        );
      }),
    );
  }
}
