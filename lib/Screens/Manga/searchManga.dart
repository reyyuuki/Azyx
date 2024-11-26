
// ignore_for_file: must_be_immutable, file_names

import 'dart:developer';
import 'package:daizy_tv/components/Anime/_gridlist.dart';
import 'package:daizy_tv/components/Manga/_manga_list.dart';
import 'package:daizy_tv/utils/api/Anilist/Manga/manga_search.dart';
import 'package:daizy_tv/utils/sources/Manga/Extenstions/mangakakalot_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';

class SearchManga extends StatefulWidget {
  String name;
  SearchManga({super.key, required this.name});

  @override
  State<SearchManga> createState() => _SearchpageState();
}

class _SearchpageState extends State<SearchManga> {
  dynamic data;
  bool isGrid = true;
  final mangaScrapper = MangakakalotUnofficial();

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
    try {
      final response = await searchAnilistManga(widget.name);
      if (response.toString().isNotEmpty) {
        setState(() {
          data = response;
        });
      } else {
        log('Failed to load data');
      }
    } catch (e) {
      log('Error fetching data: $e');
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
                    prefixIcon: const Icon(Iconsax.search_normal),
                    hintText: 'Search Manga',
                    labelText: 'Search Manga',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    fillColor:
                        Theme.of(context).colorScheme.surface,
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
                      fontFamily: "Poppins-Bold",
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
            child: isGrid
                ? GridList(data: data, route: '/mangaDetail',)
                : MangaSearchList(data: data, ),
          ),
        ],
      ),
    );
  }
}
