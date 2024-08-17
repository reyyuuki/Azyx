import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daizy_tv/components/Carousel.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:daizy_tv/components/ReusableList.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<dynamic>? spotlightAnime;
  List<dynamic>? trendingAnime;
  List<dynamic>? latestEpisodesAnime;
  List<dynamic>? topUpComingAnime;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse("https://aniwatch-ryan.vercel.app/anime/home"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          spotlightAnime = jsonData['spotlightAnimes'];
          trendingAnime = jsonData['trendingAnimes'];
          latestEpisodesAnime = jsonData['latestEpisodeAnimes'];
          topUpComingAnime = jsonData['topUpcomingAnimes'];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      // ignore: avoid_print
      print("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Header(),
              const SizedBox(
                height: 40.0,
              ),
              Carousel(
                animeData: spotlightAnime,
              ),
              const SizedBox(
                height: 30.0,
              ),
              ReusableList(name: 'Popular', data: trendingAnime),
              const SizedBox(
                height: 10,
              ),
              ReusableList(name: 'Latest Episodes', data: latestEpisodesAnime),
              const SizedBox(
                height: 10,
              ),
              ReusableList(name: 'Top Upcoming', data: topUpComingAnime),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
