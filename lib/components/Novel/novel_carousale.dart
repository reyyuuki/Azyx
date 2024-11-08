import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NovelCarousale extends StatelessWidget {
  dynamic animeData;
  String route;

  NovelCarousale({super.key, this.animeData, required this.route});

  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CarouselSlider(
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
      items: animeData!.map<Widget>((novel) {
        final title =
            novel['title'] ?? "N/A";
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, route, arguments: {
                  "id": novel['id'].toString(),
                  "image": novel['image'] ?? '',
                  "tagg": "${novel['id']}MainCarousale"
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
                      height: 230,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: novel['image'] ??
                              novel['image'],
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
                            height: 150,
                            width: 100,
                            child: Hero(
                              tag: "${novel['id']}MainCarousale",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: novel['image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 190,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.length > 30
                                      ? '${title.substring(0, 30)}...'
                                      : title,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: "Poppins-Bold"),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  (novel['description'] as String?)?.length !=
                                              null &&
                                          (novel['description'] as String)
                                                  .length >
                                              85
                                      ? '${(novel['description'] as String).substring(0, 85)}...'
                                      : novel['description'] ?? "N/A",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.play_circle_fill,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Play now",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary),
                                        )
                                      ],
                                    ),
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
