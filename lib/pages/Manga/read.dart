import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/components/Manga/ProgressBar.dart';
import 'package:daizy_tv/components/Manga/ReadingHeader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Read extends StatefulWidget {
  final String? mangaId;
  final String? chapterId;

  const Read({super.key, this.mangaId, this.chapterId});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  List<dynamic>? chapterList;
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
        Progressbar(show: show)
      ],
    ));
  }

}
