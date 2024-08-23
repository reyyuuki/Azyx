import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:text_scroll/text_scroll.dart';

class SearchAnime extends StatefulWidget {
  String name;
  SearchAnime({super.key, required this.name});



  @override
  State<SearchAnime> createState() => _SearchpageState();
}

class _SearchpageState extends State<SearchAnime> {
  List<dynamic>? data;


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

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 80, 
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).colorScheme.secondary,
              filled: true,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          GridView.builder(
            physics:
                const NeverScrollableScrollPhysics(), 
            shrinkWrap: true, 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 20.0, 
              childAspectRatio:
                  0.5, 
            ),
            itemCount: data!.length,
            itemBuilder: (context, index) {
              final item = data![index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/detailspage',
                arguments: {"id": item['id'], "image": item['poster']}
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      width: 230,
                      child: Hero(
                        tag: item['id'],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: item['poster'],
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextScroll(
                        item['name'],
                        mode: TextScrollMode.bouncing,
                        velocity: const Velocity(pixelsPerSecond: Offset(40, 0)),
                        delayBefore: const Duration(milliseconds: 500),
                        pauseBetween: const Duration(milliseconds: 1000),
                        textAlign: TextAlign.center,
                        selectable: true,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
