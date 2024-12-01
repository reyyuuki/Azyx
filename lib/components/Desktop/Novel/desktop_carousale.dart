import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NovelDesktopCarousale extends StatelessWidget {
  dynamic novelData;

  NovelDesktopCarousale({super.key, this.novelData});

  @override
  Widget build(BuildContext context) {
    if (novelData == null) {
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
      items: novelData!.map<Widget>((novel) {
        final title =
            novel['title'] ?? "N/A";
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/novelDetail', arguments: {
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
                      height: 380,
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
                            height: 300,
                            width: 200,
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
                                const SizedBox(height: 5,),
                                Text( novel['description'] != null ? novel['description'].length > 400 ? '${novel['description'].substring(0,400)}...': novel['description'] : "N/A", style: const TextStyle(fontSize: 18),),
                                const SizedBox(height: 10,),
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
                                        Icons.book_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                            size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Read now",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary, fontFamily: "Poppins-Bold"),
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
