import 'dart:convert';

import 'package:daizy_tv/Theme/themes.dart';
import 'package:daizy_tv/components/Carousel.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:daizy_tv/components/ReusableList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

List<dynamic>?  spotlightAnime;
List<dynamic>?  trendingAnime;
List<dynamic>?  latestEpisodesAnime;
List<dynamic>?  topUpComingAnime;



 @override
  void initState() {
    super.initState();
    fetchData();
  }

Future<void> fetchData() async {
  try{

  final response = await http.get(Uri.parse("https://aniwatch-ryan.vercel.app/anime/home"));
  if(response.statusCode == 200){
    final jsonData = jsonDecode(response.body);
    setState(() {
      spotlightAnime = jsonData['spotlightAnimes'];
      trendingAnime = jsonData['trendingAnimes'];
      latestEpisodesAnime = jsonData['latestEpisodeAnimes'];
      topUpComingAnime = jsonData['topUpcomingAnimes'];
    });
  }
  else{
    throw Exception("Failed to load data");
  }
  } catch(error){
    // ignore: avoid_print
    print("Failed to load data");
  }
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
          children: [
            const Header(),
            const SizedBox(height: 10.0,),
            const Center(child: Text("Latest Release", style: TextStyle(fontSize: 30),)),
            const SizedBox(height: 10.0,),
            Carousel(animeData: spotlightAnime,),
            const SizedBox(height: 30.0,),
        
        ReusableList(name: 'Popular',data : trendingAnime),
        const SizedBox(height: 10,),
        ReusableList(name: 'Latest Episodes', data : latestEpisodesAnime),
        const SizedBox(height: 10,),
        ReusableList(name: 'Top Upcoming', data : topUpComingAnime),
        const SizedBox(height: 10,),  
          ],
        ),
      ),
    ),
  );
}

 
}
