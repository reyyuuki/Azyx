// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math' as math;

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainCarousale extends StatefulWidget {
  final List<Anime> data;
  final bool isManga;
  const MainCarousale({super.key, required this.data, required this.isManga});

  @override
  State<MainCarousale> createState() => _MainCarousaleState();
}

class _MainCarousaleState extends State<MainCarousale>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entryController;
  late AnimationController _bgCrossfadeController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  int _previousIndex = 0;
  double _pageDelta = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(_onScroll);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bgCrossfadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bgCrossfadeController.value = 1.0;

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
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutQuart,
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
    _bgCrossfadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: 460,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
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
            offset: Offset(0, 30 * (1 - entryValue)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 460,
            child: Stack(
              children: [
                _buildBackgroundBlur(),
                GestureDetector(
                  onPanDown: (_) => _stopAutoPlay(),
                  onPanEnd: (_) => _startAutoPlay(),
                  onPanCancel: () => _startAutoPlay(),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.data.length,
                    onPageChanged: (i) {
                      _previousIndex = _currentIndex;
                      _currentIndex = i;
                      _bgCrossfadeController.forward(from: 0);
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      return _buildCard(index);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (widget.data.length > 1) ...[
            const SizedBox(height: 20),
            _SlideIndicator(
              count: widget.data.length,
              current: _currentIndex,
              progress: _pageDelta,
              onTap: (i) {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlur() {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _bgCrossfadeController,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - _bgCrossfadeController.value,
              child: _BgImage(
                url:
                    widget
                        .data[_previousIndex % widget.data.length]
                        .bannerImage ??
                    widget.data[_previousIndex % widget.data.length].image ??
                    '',
              ),
            ),
            Opacity(
              opacity: _bgCrossfadeController.value,
              child: _BgImage(
                url:
                    widget.data[_currentIndex].bannerImage ??
                    widget.data[_currentIndex].image ??
                    '',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(int index) {
    final anime = widget.data[index];
    double diff = (index - _pageDelta);
    double absDiff = diff.abs().clamp(0.0, 1.0);

    double scale = 1.0 - (absDiff * 0.08);
    double translateY = absDiff * 20;
    double rotateY = diff * 0.02;
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
          parallaxOffset: diff * 30,
          onTap: () => _navigateToDetails(anime),
        ),
      ),
    );
  }

  void _navigateToDetails(Anime anime) {
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

class _BgImage extends StatelessWidget {
  final String url;
  const _BgImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: url.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        ),
      ),
    );
  }
}

class _CinematicCard extends StatelessWidget {
  final Anime anime;
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: -8,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(parallaxOffset, 0),
                child: CachedNetworkImage(
                  imageUrl: anime.bannerImage ?? anime.image ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const ShimmerEffect(
                      height: 460,
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
                      Colors.black.withOpacity(0.02),
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.92),
                    ],
                    stops: const [0.0, 0.25, 0.5, 1.0],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopChips(),
                    const Spacer(),
                    _buildBottomContent(context, colorScheme),
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
                size: 12,
              ),
              const SizedBox(width: 5),
              Text(
                isManga ? "MANGA" : "ANIME",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (rating > 0) ...[
          const SizedBox(width: 8),
          _GlassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        _GlassChip(
          child: Icon(
            Icons.more_horiz_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomContent(BuildContext context, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 85,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: CachedNetworkImage(
              imageUrl: anime.image ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ShimmerEffect(height: 120, width: 85),
              errorWidget: (_, __, ___) =>
                  Container(color: Colors.grey.shade900),
            ),
          ),
        ),
        const SizedBox(width: 16),
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
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
              if (anime.description != null &&
                  anime.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  anime.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isManga
                              ? Icons.auto_stories_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isManga ? "Read" : "Watch",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Icon(
                      Icons.bookmark_add_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
      ),
      child: child,
    );
  }
}

class _SlideIndicator extends StatelessWidget {
  final int count;
  final int current;
  final double progress;
  final Function(int) onTap;

  const _SlideIndicator({
    required this.count,
    required this.current,
    required this.progress,
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
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 3.5,
            width: active ? 32 : 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: active
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withOpacity(0.15),
            ),
          ),
        );
      }),
    );
  }
}
