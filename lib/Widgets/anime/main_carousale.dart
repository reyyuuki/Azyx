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
  late PageController _mobileController;
  late PageController _desktopController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  double _pageDelta = 0;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.data.isNotEmpty ? widget.data.length ~/ 2 : 0;
    _currentIndex = initialPage;
    _pageDelta = initialPage.toDouble();
    _mobileController = PageController(
      viewportFraction: 0.9,
      initialPage: initialPage,
    );
    _desktopController = PageController(
      viewportFraction: 1.0,
      initialPage: initialPage,
    );
    _mobileController.addListener(_onMobileScroll);
    _startAutoPlay();
  }

  void _onMobileScroll() {
    if (!_mobileController.hasClients) return;
    final page = _mobileController.page ?? 0;
    setState(() {
      _pageDelta = page;
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.data.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % widget.data.length;
      if (_desktopController.hasClients) {
        _desktopController.animateToPage(
          next,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
      if (_mobileController.hasClients) {
        _mobileController.animateToPage(
          next,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoPlay() => _autoPlayTimer?.cancel();

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _mobileController.removeListener(_onMobileScroll);
    _mobileController.dispose();
    _desktopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 950;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: isDesktop ? 380 : 200,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: LoadingIndicatorM3E(color: colorScheme.primary),
          ),
        ),
      );
    }

    if (isDesktop) {
      return _buildDesktopCarousel(context, colorScheme);
    }

    return _buildMobileCarousel(context, colorScheme);
  }

  Widget _buildMobileCarousel(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 6),
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _mobileController,
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
              _mobileController.animateToPage(
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

  Widget _buildDesktopCarousel(BuildContext context, ColorScheme colorScheme) {
    return Container(
      height: 380,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PageView.builder(
              controller: _desktopController,
              itemCount: widget.data.length,
              onPageChanged: (i) {
                _currentIndex = i;
                setState(() {});
              },
              itemBuilder: (context, index) {
                return _buildDesktopSlideContent(context, index, colorScheme);
              },
            ),
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    final prev = (_currentIndex - 1 + widget.data.length) % widget.data.length;
                    _desktopController.animateToPage(
                      prev,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  onPressed: () {
                    final next = (_currentIndex + 1) % widget.data.length;
                    _desktopController.animateToPage(
                      next,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSlideContent(BuildContext context, int index, ColorScheme colorScheme) {
    final anime = widget.data[index];
    final rating = _parseRating(anime.rating);
    final eps = anime.episodes?.toString();

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: (anime.bannerImage != null && anime.bannerImage!.isNotEmpty)
                ? anime.bannerImage!
                : (anime.image ?? ''),
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.94),
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.5, 0.9],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.88),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.65],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${(index % widget.data.length) + 1} Spotlight',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (anime.type != null && anime.type!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        anime.type!.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  anime.title ?? 'Unknown',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins-Bold',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (anime.description != null && anime.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    _cleanDescription(anime.description!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.5,
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  if (eps != null && eps.isNotEmpty) ...[
                    Text(
                      '$eps Episodes',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (anime.status != null && anime.status!.isNotEmpty) ...[
                    Text(
                      anime.status!.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _navigateToDetails(anime),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isManga
                                ? Icons.auto_stories_rounded
                                : Icons.play_arrow_rounded,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isManga ? 'Read Now' : 'Watch Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: colorScheme.onPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _navigateToDetails(anime),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  _SlideIndicator(
                    count: widget.data.length,
                    current: _currentIndex,
                    onTap: (i) {
                      _desktopController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _cleanDescription(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'~!.*?!~', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
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
    if (widget.isManga) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MangaDetailsScreen(
            smallMedia: CarousaleData(
              id: anime.id!,
              image: anime.image!,
              title: anime.title!,
            ),
            tagg: "${anime.id}MainCarousale",
          ),
        ),
      ).then((_) => _startAutoPlay());
    } else {
      Navigator.push(
        context,
        AnimeDetailsScreen.route(
          smallMedia: CarousaleData(
            id: anime.id!,
            image: anime.image!,
            title: anime.title!,
          ),
          tagg: "${anime.id}MainCarousale",
        ),
      ).then((_) => _startAutoPlay());
    }
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
