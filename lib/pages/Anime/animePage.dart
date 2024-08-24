import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daizy_tv/components/Anime/carousel.dart';
import 'package:daizy_tv/components/Header.dart';
import 'package:daizy_tv/components/Anime/reusableList.dart';

class Animepage extends StatefulWidget {
  const Animepage({super.key});

  @override
  State<Animepage> createState() => _HomepageState();
}

class _HomepageState extends State<Animepage> {
  dynamic spotlightAnime;
  dynamic trendingAnime;
  dynamic latestEpisodesAnime;
  dynamic topUpComingAnime;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse("https://aniwatch-ryan.vercel.app/anime/home"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          spotlightAnime = jsonData['spotlightAnimes'];
          trendingAnime = jsonData['trendingAnimes'];
          latestEpisodesAnime = jsonData['latestEpisodeAnimes'];
          topUpComingAnime = jsonData['topUpcomingAnimes'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      setState(() {
        errorMessage = "Failed to load data: $error";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Header(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 50,
                child: TextField(
                  onSubmitted: (String value) {
                    Navigator.pushNamed(
                      context,
                      '/searchAnime',
                      arguments: {"name": value},
                    );
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Anime...',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    fillColor: Theme.of(context).colorScheme.secondary,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Carousel(animeData: trendingAnime),
            const SizedBox(height: 30.0),
            ReusableList(name: 'Popular', data: spotlightAnime),
            const SizedBox(height: 10),
            ReusableList(name: 'Latest Episodes', data: latestEpisodesAnime),
            const SizedBox(height: 10),
            ReusableList(name: 'Top Upcoming', data: topUpComingAnime),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
