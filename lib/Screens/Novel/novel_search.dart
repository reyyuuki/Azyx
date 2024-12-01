// ignore_for_file: must_be_immutable, file_names

import 'dart:developer';
import 'package:daizy_tv/Provider/sources_provider.dart';
import 'package:daizy_tv/components/Novel/novel_gridlist.dart';
import 'package:daizy_tv/components/Novel/novel_serachList.dart';
import 'package:daizy_tv/utils/sources/Manga/Extenstions/mangakakalot_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class NovelSearch extends StatefulWidget {
  String name;
  NovelSearch({super.key, required this.name});

  @override
  State<NovelSearch> createState() => _SearchpageState();
}

class _SearchpageState extends State<NovelSearch> {
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
    final provider = Provider.of<SourcesProvider>(context, listen: false);
    try {
      final response =
          await provider.novelInstance.scrapeNovelSearchData(widget.name);
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
              "Serach Novel",
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
                      labelText: "Search Novel",
                      hintText: 'Search Novel',
                      labelStyle:
                          TextStyle(color: Theme.of(context).colorScheme.primary),
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
                              color: Theme.of(context).colorScheme.inversePrimary,
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
                  ? NovelGridlist(data: data)
                  : NovelSerachlist(
                      data: data,
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
