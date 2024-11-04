import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:text_scroll/text_scroll.dart';

class Mangacarousale extends StatelessWidget {
  final dynamic mangaData;
  final List<String> generes = ["Action", "Adventure", "Fantasy"];

  Mangacarousale({super.key, this.mangaData});

  @override
  Widget build(BuildContext context) {
    if (mangaData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      height: 440,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          height: 560,
          viewportFraction: 0.73,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
          scrollDirection: Axis.horizontal,
        ),
        itemCount: mangaData!.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          final manga = mangaData[index];
          final tagg = "${manga['id']}MainCarosalemanga";
          
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/mangaDetail',
                  arguments: {"id": manga['id'].toString(), "image": manga['coverImage']['large'], "tagg": tagg});
            },
            child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: 280,
                              width: 230,
                              child: Hero(
                                tag: "${manga['id']}MainCarousale",
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: manga['coverImage']['large'],
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  height: 30,
                                  decoration:  BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(15),
                                          topLeft: Radius.circular(10))),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      manga['type'] ?? 'N/A',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              Theme.of(context).colorScheme.onPrimaryFixedVariant,
                                          fontFamily: "Poppins-Bold"),
                                    ),
                                  )),
                                )),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 30,
                                  decoration:  BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          topLeft: Radius.circular(25))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          manga['averageScore'] != null
                                              ? (manga['averageScore'] / 10)
                                                  .toStringAsFixed(1)
                                              : 'N/A',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                                              fontFamily: "Poppins-Bold"),
                                        ),
                                        Icon(
                                          Iconsax.star1,
                                          size: 18,
                                          color:
                                              Theme.of(context).colorScheme.onPrimaryFixedVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextScroll(
                          manga['title']['english'] ?? manga['title']['romaji'] ?? 'Unknown',
                          mode: TextScrollMode.bouncing,
                          velocity:
                              const Velocity(pixelsPerSecond: Offset(30, 0)),
                          delayBefore: const Duration(milliseconds: 500),
                          pauseBetween: const Duration(milliseconds: 1000),
                          textAlign: TextAlign.center,
                          selectable: true,
                          style: const TextStyle(
                              fontSize: 16, fontFamily: "Poppins-Bold"),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: manga['genres'] != null ? (manga?['genres'] as String)
                              .split(', ')
                              .take(3)
                              .map((item) {
                            return Container(
                              height: 30,
                              margin: const EdgeInsets.only(right: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryFixedVariant,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Text(
                                    item.length > 6 ? '${item.substring(0,5)}..' : item,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: "Poppins-Bold",
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }).toList() : []
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryFixedVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Watch now",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Poppins-Bold",
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.book,
                                  color: Colors.white,
                                )
                              ]),
                        ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
