import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class Carousel extends StatelessWidget {
  final List<dynamic>? animeData;

  const Carousel({super.key, this.animeData});

  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: Center(child: CircularProgressIndicator()));
    }
    return SizedBox(
      height: 440,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 560,
          aspectRatio: 16 / 9,
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
        items: animeData!.map((anime) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/detailspage',
                      arguments:{"id": anime['id']});
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(174, 56, 55, 55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 280,
                          width: 230,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              anime['poster'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          anime['name'].length > 20
                              ? anime['name'].substring(0, 15) + "..."
                              : anime['name'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                    child: Text(
                                  "Action",
                                  style: TextStyle(fontSize: 12),
                                )),
                              ),
                            ),
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                    child: Text(
                                  "Adventure",
                                  style: TextStyle(fontSize: 12),
                                )),
                              ),
                            ),
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                    child: Text(
                                  "Fantasy",
                                  style: TextStyle(fontSize: 12),
                                )),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Text(
                              "Watch now",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 5,),
                            Icon(Ionicons.play_circle,
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
