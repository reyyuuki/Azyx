// ignore_for_file: must_be_immutable, file_names

import 'dart:developer';
import 'package:azyx/components/Anime/_gridlist.dart';
import 'package:azyx/components/Manga/_manga_list.dart';
import 'package:azyx/utils/api/Anilist/Manga/manga_search.dart';
import 'package:azyx/utils/sources/Manga/Extenstions/mangakakalot_unofficial.dart';
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              hoverColor: Colors.transparent,
              alignment: Alignment.topLeft,
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 40,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Serach Manga",
              style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 30),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      setState(() {
                        data = null;
                      });
                      handleSearch(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.search_normal),
                      labelText: "Search Manga",
                      hintText: 'Search Manga',
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              width: 1)),
                      fillColor: Theme.of(context).colorScheme.surface,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isGrid = !isGrid;
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHigh),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  iconSize: 30,
                  icon: Icon(isGrid ? Ionicons.grid : Iconsax.menu_15,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: data == null ? const Center(child: CircularProgressIndicator(),) : (isGrid
                  ? GridList(
                      data: data,
                      route: '/mangaDetail',
                    )
                  : MangaSearchList(
                      data: data,
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
