import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/components/Manga/readingHeader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';


class Read extends StatefulWidget {
  final String? mangaId;
  String? chapterId;

   Read({super.key, this.mangaId, this.chapterId});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  List<dynamic>? chapterList;
  List<dynamic>? chapterListIds;
  dynamic data;
  bool show = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String url =
        'https://anymey-proxy.vercel.app/cors?url=https://manga-ryan.vercel.app/api/manga/${widget.mangaId}/${widget.chapterId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          data = jsonData;
          chapterList = jsonData['images'];
          chapterListIds = jsonData['chapterListIds'];
        });
      } else {
        // Handle non-200 responses
        print('Failed to load data');
      }
    } catch (error) {
      // Handle errors
      print(error);
    }
  }

  void handleChapter(bool next) {

    int currentIndex = data != null ? chapterListIds!.indexWhere((item) => item["id"] == widget.chapterId) : -1;

    if (currentIndex == -1) {
      print("Chapter not found");
      return;
    }

    if (next){
      if (currentIndex < chapterListIds!.length - 1) {
        widget.chapterId = chapterListIds![currentIndex + 1]['id'];
         print('Next chapter ID: ${widget.chapterId}');
        fetchData();
      } else {
        print("No more chapters");
      }
    } else {
      if (currentIndex > 0) {
        widget.chapterId = chapterListIds![currentIndex - 1]['id'];
        fetchData();
      } else {
        print("No previous chapters");
      }
    }
  }


  void _toggleShow() {
    setState(() {
      show = !show; // Toggle the boolean variable
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
        body: Stack(
      children: [
        GestureDetector(
          onTap: _toggleShow,
          child: ListView(
            children: [
              if(chapterList != null)
              ...chapterList!.map<Widget>((image) => 
              CachedNetworkImage(imageUrl: image['image'],)
               )
            ],
          ),
        ),
        Readingheader(show: show, data: data),
        Positioned(
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: show
          ? Container(
              color: const Color.fromARGB(178, 24, 23, 23),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Row(
                  children: [
                  
                    Transform.rotate(
                      angle: 3.14, // 180 degrees in radians
                      child: GestureDetector(onTap:() => handleChapter(true), child: const Icon(Ionicons.play)),
                    ),
                    LinearPercentIndicator(
                      lineHeight: 10,
                      width: 280,
                      barRadius: const Radius.circular(10),
                    ),
                    GestureDetector(onTap:() => handleChapter(false), child: const Icon(Ionicons.play)),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    )
      ],
    ));
  }

}
