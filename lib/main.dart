import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  void callbackFunction(int index, CarouselPageChangedReason reason) {
    // Do something when the page changes.
    print('Current page: $index');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightmode,
      darkTheme: darkmode,
      color: Theme.of(context).colorScheme.surface,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children:[ 
              Header(),
              SizedBox(height: 25.0,),
          SizedBox(
            width: 300,
            height: 500,
child: CarouselSlider(
   
   options: CarouselOptions(
      height: 580,
      aspectRatio: 16/9,
      viewportFraction: 0.8,
      initialPage: 0,
      enableInfiniteScroll: true,
      reverse: false,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 3),
      autoPlayAnimationDuration: Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: true,
      enlargeFactor: 0.3,
      onPageChanged: callbackFunction,
      scrollDirection: Axis.horizontal,
   ),
   items: [1, 2, 3, 4, 5, 6].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(color: const Color.fromRGBO(255, 255, 255, 0.5), borderRadius: BorderRadius.circular(20) ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Prevent overflow by minimizing column height
                              children: [
                                Container(
                                  height: 280,
                                  width: 200,
                                  child: Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx16498-73IhOXpJZiMF.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0), 
                                const Text(
                                  "Attack on tittan",
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 8.0),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                Text(
                                  "10.0",
                                  style: TextStyle(fontSize: 16),
                                ),
                                  ],
                                ), 
                                
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 30,
                                      decoration: BoxDecoration(border: Border.all(width: 2.0, color: const Color.fromARGB(255, 49, 42, 42)) , borderRadius: BorderRadius.circular(20)),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Center(child: Text("Action")),
                                      ),
                                    ),
                                     Container(
                                      height: 30,
                                      decoration: BoxDecoration(border: Border.all(width: 2.0, color: const Color.fromARGB(255, 49, 42, 42)) , borderRadius: BorderRadius.circular(20)),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Center(child: Text("Action")),
                                      ),
                                    ),
                                     Container(
                                      height: 30,
                                      decoration: BoxDecoration(border: Border.all(width: 2.0, color: const Color.fromARGB(255, 49, 42, 42)) , borderRadius: BorderRadius.circular(20)),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Center(child: Text("Action")),
                                      ),
                                    )
                                  ],
                                  
                                 ),
                                 const SizedBox(height: 40),
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
          ),), ]
        ),
      ),),
    );
  }
}


