import 'dart:convert';

import 'package:daizy_tv/components/Manga/sliderBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



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
    bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  final ScrollController _scrollController = ScrollController();

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
          isLoading = false;
          hasError = false;
        });
      } 
    } catch (error) {
      // Handle errors
      isLoading = false;
      hasError = true;
    }
  }

  void handleChapter(String ? direction) {

    int currentIndex = data != null ? chapterListIds!.indexWhere((item) => item["id"] == widget.chapterId) : -1;

    if (currentIndex == -1) {
      print("Chapter not found");
      
    }

    if (direction == 'right'){
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
    
    return Sliderbar(
      title: isLoading ? '??' : data['title'],
      chapter: isLoading ? 'Chapter ?' : data['currentChapter'],
      totalImages: chapterList?.length ?? 0,
      scrollController: _scrollController,
      handleChapter: handleChapter,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError
                ? const Text('Failed to load data')
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: chapterList!.length,
                    itemBuilder: (context, index) {
                      return Image.network(chapterList![index]['image']);
                    },
                  ),
      ),
    );
  }

}
