// ignore_for_file: must_be_immutable

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class MainCarousale extends StatelessWidget {
  final List<Anime> data;
  final bool isManga;
  const MainCarousale({super.key, required this.data, required this.isManga});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode!;
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 490),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 490,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          enlargeFactor: 0.1,
          scrollDirection: Axis.horizontal,
        ),
        items: data.map<Widget>((anime) {
          return GestureDetector(
            onTap: () {
              isManga
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MangaDetailsScreen(
                                smallMedia: CarousaleData(
                                    id: anime.id!,
                                    image: anime.image!,
                                    title: anime.title!),
                                tagg: "${anime.id}MainCarousale",
                              )))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AnimeDetailsScreen(
                                smallMedia: CarousaleData(
                                    id: anime.id!,
                                    image: anime.image!,
                                    title: anime.title!),
                                tagg: "${anime.id}MainCarousale",
                              )));
            },
            child: AzyXContainer(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 480,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                            imageUrl: anime.bannerImage ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const ShimmerEffect(
                                height: 230, width: double.infinity)),
                      ),
                    ),
                    Positioned.fill(
                      child: AzyXContainer(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [
                                        Colors.black87,
                                        const Color.fromARGB(87, 0, 0, 0)
                                      ]
                                    : [
                                        const Color.fromARGB(204, 30, 28, 28),
                                        const Color.fromARGB(53, 0, 0, 0)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            width: 130,
                            child: Hero(
                              tag: "${anime.id}MainCarousale",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                    imageUrl: anime.image ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const ShimmerEffect(
                                          height: 180,
                                          width: 130,
                                        )),
                              ),
                            ),
                          ),
                          30.height,
                          _buildRatingStars(anime.rating),
                          20.height,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     if (anime.status != null)
                          //       _buildStatusBadge(anime.status!,
                          //           Theme.of(context).colorScheme),
                          //     10.width,
                          //     Container(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 12, vertical: 6),
                          //       decoration: BoxDecoration(
                          //         color: Colors.lightBlue.withOpacity(0.6),
                          //         borderRadius: BorderRadius.circular(12),
                          //         border: Border.all(
                          //             width: 1, color: Colors.lightBlue),
                          //         boxShadow: [
                          //           BoxShadow(
                          //             color: Colors.lightBlue
                          //                 .withOpacity(1.glowMultiplier()),
                          //             blurRadius: 8,
                          //             offset: const Offset(0, 2),
                          //           ),
                          //         ],
                          //       ),
                          //       child: Row(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Icon(
                          //             isManga
                          //                 ? Icons.menu_book
                          //                 : Icons.movie_filter,
                          //             color: Colors.white,
                          //             size: 14,
                          //           ),
                          //           const SizedBox(width: 6),
                          //           AzyXText(
                          //             text: isManga ? "MANGA" : "ANIME",
                          //             fontSize: 11,
                          //             fontVariant: FontVariant.bold,
                          //             color: Colors.white,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     10.width,
                          //     Container(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 12, vertical: 6),
                          //       decoration: BoxDecoration(
                          //         color: Colors.pinkAccent.withOpacity(0.6),
                          //         borderRadius: BorderRadius.circular(12),
                          //         border:
                          //             Border.all(width: 1, color: Colors.pink),
                          //         boxShadow: [
                          //           BoxShadow(
                          //             color: Colors.pinkAccent
                          //                 .withOpacity(1.glowMultiplier()),
                          //             blurRadius: 8,
                          //             offset: const Offset(0, 2),
                          //           ),
                          //         ],
                          //       ),
                          //       child: Row(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Icon(
                          //             isManga
                          //                 ? Icons.chrome_reader_mode
                          //                 : Icons.play_circle_fill,
                          //             color: Colors.white,
                          //             size: 14,
                          //           ),
                          //           const SizedBox(width: 6),
                          //           AzyXText(
                          //             text: isManga ? "Read" : "View",
                          //             fontSize: 11,
                          //             fontVariant: FontVariant.bold,
                          //             color: Colors.white,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // 10.height,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AzyXText(
                                  text: anime.title!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 20,
                                  fontVariant: FontVariant.bold,
                                  textAlign: TextAlign.center,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Flexible(
                                  child: AzyXText(
                                    text: anime.description!,
                                    fontSize: 12,
                                    fontVariant: FontVariant.bold,
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status, colorScheme).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(width: 1, color: _getStatusColor(status, colorScheme)),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status, colorScheme).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AzyXText(
        text: _formatStatus(status),
        fontSize: 11,
        fontVariant: FontVariant.bold,
        color: Colors.white,
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    status = status.toLowerCase();
    if (status.contains('ongoing') || status.contains('releasing')) {
      return Colors.green.shade600;
    } else if (status.contains('completed') || status.contains('finished')) {
      return colorScheme.primary;
    } else if (status.contains('upcoming') ||
        status.contains('not yet aired')) {
      return Colors.orange.shade600;
    }
    return colorScheme.secondary;
  }

  String _formatStatus(String status) {
    if (status.toLowerCase().contains('not yet aired')) {
      return 'Coming Soon';
    }
    return status
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Widget _buildRatingStars(String? ratingStr) {
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
                size: 18,
              ),
            );
          }),
        ),
        5.height,
        if (rating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AzyXText(
              text: rating.toStringAsFixed(1),
              fontSize: 12,
              fontVariant: FontVariant.bold,
              color: Colors.amber,
            ),
          ),
      ],
    );
  }
}
