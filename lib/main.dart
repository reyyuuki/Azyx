import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late InfiniteScrollController controller;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = InfiniteScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
          SizedBox(
            child: InfiniteCarousel.builder(
                  itemCount: 10,
                   itemExtent: 120,
                  center: true,
                  anchor: 0.0,
                  velocityFactor: 0.2,  
                  onIndexChanged: (index) {},
                  controller: controller,
                  axisDirection: Axis.horizontal,
                  loop: true,
                  itemBuilder: (context, itemIndex, realIndex) {
                    return
                    Container(width: 200, height: 400, child: Column(
                      children: [
                       SizedBox(width: 200, height: 300, child: ClipRRect(borderRadius: BorderRadius.circular(50) , child:Image.network("https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx16498-73IhOXpJZiMF.jpg", fit: BoxFit.cover,),))
                      ],
                    ),
                     );
            },
                    ),
          ) ]
        ),
      ),),
    );
  }
}


