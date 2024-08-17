import 'dart:convert';
import 'dart:ui';

import 'package:daizy_tv/components/Poster.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;

class Details extends StatefulWidget {
  final String id;
  const Details({super.key, required this.id});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  dynamic AnimeData;
  String? cover;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://aniwatch-ryan.vercel.app/anime/info?id=${widget.id}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newResponse = await http.get(Uri.parse(
            'https://consumet-api-two-nu.vercel.app/meta/anilist/info/${jsonData['anime']['info']['anilistId']}'));

        if (newResponse.statusCode == 200) {
          final newData = jsonDecode(newResponse.body);
          setState(() {
            AnimeData = jsonData['anime'];
            cover = newData['cover'];
          });
        }
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
    if (AnimeData == null || cover == null) {
      return const Center(child: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        title: Text(AnimeData['info']['name']),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.play_back),
        ),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              CoverImage(),
              Expanded(
                child: Container(
                  height: 1000,
                  margin: const EdgeInsets.only(top: 200),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                    color: Color.fromARGB(255, 18, 18, 18),
                  ),
                ),
              ),
              Poster(imageUrl: AnimeData['info']['poster']),
              Positioned(
                top: 340,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AnimeData['info']['name'].length > 80
                              ? AnimeData['info']['name'].substring(0, 75) +
                                  "..."
                              : AnimeData['info']['name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Ionicons.star,
                            color: Colors.yellow,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            AnimeData['moreInfo']['malscore'],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      genres(),
                      const SizedBox(
                        height: 30,
                      ),
                      AnimeInfo(),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          AnimeData['info']['description'],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Positioned CoverImage() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              cover!,
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding AnimeInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Japanese: "),
                SizedBox(
                  height: 5,
                ),
                Text("Aired: "),
                SizedBox(
                  height: 5,
                ),
                Text("Premiered: "),
                SizedBox(
                  height: 5,
                ),
                Text("Duration: "),
                SizedBox(
                  height: 5,
                ),
                Text("Status: "),
                SizedBox(
                  height: 5,
                ),
                Text("Rating: "),
                SizedBox(
                  height: 5,
                ),
                Text("Quality: "),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AnimeData['moreInfo']['japanese'].length > 13
                  ? AnimeData['moreInfo']['japanese'].substring(0, 13)
                  : AnimeData['moreInfo']['japanese']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['aired']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['premiered']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['duration']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['moreInfo']['status']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['info']['stats']['rating']),
              const SizedBox(
                height: 5,
              ),
              Text(AnimeData['info']['stats']['quality']),
            ],
          ),
        ],
      ),
    );
  }

  Wrap genres() {
    return Wrap(
      spacing: 8.0, // Space between items
      runSpacing: 2.0, // Space between lines
      children: AnimeData['moreInfo']['genres'].map<Widget>((genre) {
        return Chip(
          label: Text(
            genre,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
