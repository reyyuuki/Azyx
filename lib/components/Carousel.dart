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
      height: 450,
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
                      arguments: anime['id']);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(175, 25, 24, 24),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(255, 255, 255, 0.2),
                          blurRadius: 5,
                        ),
                      ]),
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
                                  border:
                                      Border.all(width: 1, color: Colors.white),
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
                                  border:
                                      Border.all(width: 1, color: Colors.white),
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
                                border:
                                    Border.all(width: 1, color: Colors.white),
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
                        const SizedBox(height: 20),
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 253, 89, 144),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(width: 1, color: Colors.white)),
                          child: const Center(
                              child: Text(
                            "Read more...",
                            style: TextStyle(fontSize: 16),
                          )),
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
