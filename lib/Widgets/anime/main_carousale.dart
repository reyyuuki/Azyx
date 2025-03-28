// ignore_for_file: must_be_immutable

import 'package:azyx/Classes/anime_class.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/shimmer_effect.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class MainCarousale extends StatelessWidget {
  final List<Anime> animeData;
  const MainCarousale({super.key, required this.animeData});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode!;
    if (animeData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 230),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 230,
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
        items: animeData.map<Widget>((anime) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnimeDetailsScreen(
                            smallMedia: anime,
                            tagg: "${anime.id}MainCarousale",
                          )));
            },
            child: AzyXContainer(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 230,
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
                                      Colors.white.withAlpha(20),
                                      Colors.white.withAlpha(20)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  Positioned.fill(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 150,
                          width: 100,
                          child: Hero(
                            tag: "${anime.id}MainCarousale",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                  imageUrl: anime.image ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const ShimmerEffect(
                                        height: 150,
                                        width: 100,
                                      )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AzyXText(
                                text: anime.title!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 20,
                                fontVariant: FontVariant.bold,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Flexible(
                                child: AzyXText(
                                  text: anime.description!,
                                  fontSize: 12,
                                  fontVariant: FontVariant.bold,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
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
          );
        }).toList(),
      ),
    );
  }
}
