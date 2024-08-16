import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class Carousel extends StatelessWidget {
  final List<dynamic>? animeData;

  const Carousel({super.key, this.animeData});

@override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(
          child: Center(child: CircularProgressIndicator()));
    }


   return SizedBox(
            height: 480,
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
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(color: const Color.fromRGBO(255, 255, 255, 0.2), borderRadius: BorderRadius.circular(20), boxShadow: [new BoxShadow( color: const Color.fromRGBO(255, 255, 255, 0.2) ,blurRadius: 10.0,),]),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 280,
                                    width: 220,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        anime['poster'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    anime['name'].length > 20 ? anime['name'].substring(0,15) + "..." : anime['name'] ,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 10),
                                       Container(
                                            decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5),), color: Color.fromARGB(255, 161, 212, 242)),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                 child: Text(anime['otherInfo'][3],style: const TextStyle(color: Colors.black, fontSize: 12),),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Container(
                                             color: const Color.fromARGB(194, 250, 248, 226),
                                             
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Ionicons.logo_closed_captioning,
                                                    size: 12,
                                                    color: Colors.black,
                                                  ),
                                                  const SizedBox(width: 1),
                                                  Text(anime['episodes']['sub'].toString(),style: const TextStyle(color: Colors.black, fontSize: 12),),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),

                                          Container(
                                            color: const Color.fromARGB(226, 220, 189, 218),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Ionicons.mic,
                                                    size: 12,
                                                    color: Colors.black,
                                                  ),
                                                  const SizedBox(width: 1),
                                                  Text(anime['episodes']['dub'].toString(),style: const TextStyle(color: Colors.black, fontSize: 12),),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2,),
                                           Container(
                                            color: const Color.fromARGB(224, 192, 245, 175),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Ionicons.time,
                                                    size: 12,
                                                    color: Colors.black,
                                                  ),
                                                  const SizedBox(width: 1),
                                                  Text(anime['otherInfo'][1],style: const TextStyle(color: Colors.black, fontSize: 12),),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2,),
                                         Container(
                                            color: const Color.fromARGB(255, 235, 149, 136),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                 child: Text(anime['otherInfo'][0],style: const TextStyle(color: Colors.black, fontSize: 12),),
                                            ),
                                          ),
                                       
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                   
                                       Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: Colors.white),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Center(child: Text("Action", style: TextStyle(fontSize: 12),)),
                                            ),
                                          ),
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: Colors.white),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Center(child: Text("Adventure", style: TextStyle(fontSize: 12),)),
                                            ),
                                          ),
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                                border: Border.all(width:1, color: Colors.white),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Center(child: Text("Fantasy", style: TextStyle(fontSize: 12),)),
                                            ),
                                          )
                                        ],
                                      ),
                                  
                                  const SizedBox(height: 20),
                                  Container(
                                    width: 150,
                                    height: 40,
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                    child: const Center(child: Text("Watch now", style: TextStyle(fontSize: 16),)),
                                  ),
                                ],
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
