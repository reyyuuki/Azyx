// ignore_for_file: must_be_immutable

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class MainCarousale extends StatefulWidget {
  final List<Anime> data;
  final bool isManga;
  const MainCarousale({super.key, required this.data, required this.isManga});

  @override
  State<MainCarousale> createState() => _MainCarousaleState();
}

class _MainCarousaleState extends State<MainCarousale>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 800 && screenWidth <= 1200;
    final isMobile = screenWidth <= 800;

    if (widget.data.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              AzyXText(
                text: "Loading amazing content...",
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
    }

    // Dynamic height based on screen size
    double carouselHeight = isDesktop ? 600 : (isTablet ? 550 : 500);
    double viewportFraction = isDesktop ? 0.8 : (isTablet ? 0.9 : 1.0);
    double horizontalMargin = isDesktop ? 40 : (isTablet ? 30 : 20);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isDesktop ? 30 : 20),
        child: Column(
          children: [
            // Enhanced carousel with responsive design
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: carouselHeight),
              child: CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: carouselHeight,
                  viewportFraction: viewportFraction,
                  initialPage: 0,
                  enableInfiniteScroll: widget.data.length > 1,
                  reverse: false,
                  autoPlay: widget.data.length > 1,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.easeInOutCubic,
                  enlargeCenterPage: true,
                  enlargeFactor: isDesktop ? 0.15 : 0.1,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: widget.data.map<Widget>((anime) {
                  return _buildCarouselItem(anime, isDarkMode, isDesktop,
                      isTablet, isMobile, horizontalMargin);
                }).toList(),
              ),
            ),

            // Enhanced dot indicator with animation
            if (widget.data.length > 1) ...[
              const SizedBox(height: 20),
              _buildDotIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(Anime anime, bool isDarkMode, bool isDesktop,
      bool isTablet, bool isMobile, double horizontalMargin) {
    return GestureDetector(
      onTap: () => _navigateToDetails(anime),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin * 0.5, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 32 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.15),
              blurRadius: isDesktop ? 30 : 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            if (isDesktop)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isDesktop ? 32 : 24),
          child: Stack(
            children: [
              // Background image with parallax effect
              _buildBackgroundImage(anime, isDesktop),

              // Gradient overlay with improved blending
              _buildGradientOverlay(isDarkMode, isDesktop),

              // Content layout - responsive
              _buildContentLayout(anime, isDesktop, isTablet, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(Anime anime, bool isDesktop) {
    return Positioned.fill(
      child: Hero(
        tag: "${anime.id}MainCarousaleBackground",
        child: CachedNetworkImage(
          imageUrl: anime.bannerImage ?? anime.image ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.7),
                ],
              ),
            ),
            child: const Center(
              child: ShimmerEffect(height: 480, width: double.infinity),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.image_not_supported,
              size: isDesktop ? 80 : 60,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(bool isDarkMode, bool isDesktop) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ]
                : [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.85),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContentLayout(
      Anime anime, bool isDesktop, bool isTablet, bool isMobile) {
    if (isDesktop) {
      return _buildDesktopLayout(anime);
    } else if (isTablet) {
      return _buildTabletLayout(anime);
    } else {
      return _buildMobileLayout(anime);
    }
  }

  Widget _buildDesktopLayout(Anime anime) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side - Poster image
            SizedBox(
              width: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPosterImage(anime, 220, 330),
                  const SizedBox(height: 20),
                  _buildRatingStars(anime.rating, isDesktop: true),
                ],
              ),
            ),

            const SizedBox(width: 40),

            // Right side - Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMediaTypeBadge(isDesktop: true),
                  const SizedBox(height: 16),
                  _buildTitle(anime, fontSize: 36, isDesktop: true),
                  const SizedBox(height: 16),
                  _buildDescription(anime, maxLines: 8, fontSize: 16),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(Anime anime) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPosterImage(anime, 180, 270),
            const SizedBox(height: 20),
            _buildRatingStars(anime.rating),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMediaTypeBadge(),
                  const SizedBox(height: 12),
                  _buildTitle(anime, fontSize: 24),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildDescription(anime, maxLines: 6, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Anime anime) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildPosterImage(anime, 140, 200),
            const SizedBox(height: 15),
            _buildRatingStars(anime.rating),
            const SizedBox(height: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(anime, fontSize: 20),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildDescription(anime, maxLines: 5, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage(Anime anime, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Hero(
        tag: "${anime.id}MainCarousale",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: anime.image ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ],
                ),
              ),
              child: ShimmerEffect(height: height, width: width),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.error.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.broken_image,
                size: 40,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTypeBadge({bool isDesktop = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: isDesktop ? 8 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isManga
              ? [Colors.purple.shade600, Colors.purple.shade800]
              : [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                (widget.isManga ? Colors.purple : Colors.blue).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isManga ? Icons.menu_book : Icons.play_circle_fill,
            color: Colors.white,
            size: isDesktop ? 18 : 14,
          ),
          const SizedBox(width: 6),
          AzyXText(
            text: widget.isManga ? "MANGA" : "ANIME",
            fontSize: isDesktop ? 13 : 11,
            fontVariant: FontVariant.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(Anime anime,
      {required double fontSize, bool isDesktop = false}) {
    return AzyXText(
      text: anime.title ?? "Unknown Title",
      maxLines: isDesktop ? 3 : 2,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontVariant: FontVariant.bold,
      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
      color: Colors.white,
    );
  }

  Widget _buildDescription(Anime anime,
      {required int maxLines, required double fontSize}) {
    return AzyXText(
      text: anime.description ?? "No description available",
      fontSize: fontSize,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      color: Colors.white.withOpacity(0.9),
    );
  }

  Widget _buildRatingStars(String? ratingStr, {bool isDesktop = false}) {
    double rating = 0.0;
    if (ratingStr != null && ratingStr.isNotEmpty && ratingStr != "N/A") {
      try {
        if (ratingStr.contains('%')) {
          final percentage = double.parse(ratingStr.replaceAll('%', '').trim());
          rating = (percentage / 20);
        } else {
          rating = double.parse(ratingStr) / 2;
        }
        rating = rating.clamp(0.0, 5.0);
      } catch (e) {
        rating = 0.0;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            double diff = rating - index;
            IconData icon;
            if (diff >= 0.75) {
              icon = Icons.star_rounded;
            } else if (diff >= 0.25) {
              icon = Icons.star_half_rounded;
            } else {
              icon = Icons.star_border_rounded;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                icon,
                color: Colors.amber,
                size: isDesktop ? 22 : 18,
              ),
            );
          }),
        ),
        if (rating > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade600, Colors.amber.shade800],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AzyXText(
              text: "${rating.toStringAsFixed(1)} ★",
              fontSize: isDesktop ? 14 : 12,
              fontVariant: FontVariant.bold,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDotIndicator() {
    int visibleDots = widget.data.length > 12 ? 12 : widget.data.length;

    int displayedIndex = _currentIndex;
    if (widget.data.length > 12) {
      double ratio = _currentIndex / (widget.data.length - 1);
      displayedIndex = (ratio * (visibleDots - 1)).round();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visibleDots, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: displayedIndex == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: displayedIndex == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  void _navigateToDetails(Anime anime) {
    widget.isManga
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaDetailsScreen(
                smallMedia: CarousaleData(
                  id: anime.id!,
                  image: anime.image!,
                  title: anime.title!,
                ),
                tagg: "${anime.id}MainCarousale",
              ),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDetailsScreen(
                smallMedia: CarousaleData(
                  id: anime.id!,
                  image: anime.image!,
                  title: anime.title!,
                ),
                tagg: "${anime.id}MainCarousale",
              ),
            ),
          );
  }
}
