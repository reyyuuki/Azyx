// ignore_for_file: must_be_immutable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ionicons/ionicons.dart';

class DesktopCarousale extends StatelessWidget {
  dynamic animeData;
  String route;
  String name;

  DesktopCarousale({super.key, this.animeData, required this.route, required this.name});


  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 380,
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
      items: animeData!.map<Widget>((anime) {
        final title =
            anime['title']['english'] ?? anime['title']['romaji'] ?? "N/A";
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, route, arguments: {
                  "id": anime['id'].toString(),
                  "image": anime['coverImage']['large'] ?? '',
                  "tagg": "${anime['id']}MainCarousale"
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: anime['bannerImage'] ??
                              anime['coverImage']['large'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Container(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.black87,
                                    Color.fromARGB(87, 0, 0, 0)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20)))),
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 300,
                            width: 200,
                            child: Hero(
                              tag: "${anime['id']}MainCarousale",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: anime['coverImage']['large'],
                                  fit: BoxFit.cover,
                                ),
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
                                Text(
                                 title,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: "Poppins-Bold"),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                (anime['description'] as String?)?.length !=
                                              null &&
                                          (anime['description'] as String)
                                                  .length >
                                              505
                                      ? '${(anime['description'].replaceAll(RegExp(r'[<>]'), '') as String).substring(0, 505)}...'
                                      : anime['description'].replaceAll(RegExp(r'[<>]'), '') ?? "N/A",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 140,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      Icon(
                                        name == "Play" ?
                                        Icons.play_circle_fill : Ionicons.book,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "$name now",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary, fontFamily: "Poppins-Bold", fontSize: 16),
                                      )
                                    ],
                                  ),
                                )
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
          },
        );
      }).toList(),
    );
  }
}
