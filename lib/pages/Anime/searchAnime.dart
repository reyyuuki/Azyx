import 'dart:convert';
import 'dart:ui';
import 'package:daizy_tv/components/Anime/_gridlist.dart';
import 'package:daizy_tv/pages/Anime/_search_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';

class SearchAnime extends StatefulWidget {
  String name;
  SearchAnime({super.key, required this.name});

  @override
  State<SearchAnime> createState() => _SearchpageState();
}

class _SearchpageState extends State<SearchAnime> {
  dynamic data;
  bool isGrid = false;

  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    fetchdata();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> fetchdata() async {
    String url =
        'https://aniwatch-ryan.vercel.app/anime/search?q=${widget.name}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsondata = jsonDecode(response.body);
        setState(() {
          data = jsondata['animes'];
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void handleSearch(String text) {
    widget.name = text;
    fetchdata();
  }

  void changList(bool list) {
    setState(() {
      isGrid = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          const SizedBox(height: 45),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                ),
              ),
              SizedBox(
                height: 55,
                width: 280,
                child: TextField(
                  controller: _controller,
                  onSubmitted: (value) {
                    handleSearch(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Anime',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    filled: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Search Results",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            changList(true);
                          },
                          child: Icon(
                            Iconsax.menu_15,
                            color: isGrid
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            changList(false);
                          },
                          child: Icon(
                            Ionicons.grid,
                            color: !isGrid
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut, // Bouncing effect
                  ),
                  child: child,
                );
              },
              child: isGrid
                ? GridList(data: data)
                : SearchList(data: data)
            ),
          ),
        ],
      ),
    );
  }
}
