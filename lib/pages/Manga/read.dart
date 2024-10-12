import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/components/Manga/sliderBar.dart';
import 'package:daizy_tv/dataBase/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';



class Read extends StatefulWidget {
  final String mangaId;
  String chapterId;
  String image;

   Read({super.key,required this.mangaId,required this.chapterId,required this.image});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  List<dynamic>? chapterList;
  List<dynamic>? chapterImages;
  String? currentChapter;
  String? mangaTitle;
  int? index;
  
  bool show = true;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchChapterData();
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> fetchChapterData() async {
     String url =
        '${dotenv.get("KAKALOT_URL")}api/manga/';
    try {
      final resp = await http.get(Uri.parse(url + widget.chapterId));
      final provider = Provider.of<Data>(context, listen: false);
      if (resp.statusCode == 200) {
        final tempData = jsonDecode(resp.body);
        setState(() {
          chapterList = tempData['chapterListIds'];
          chapterImages = tempData['images'];
          currentChapter = tempData['currentChapter'];
          mangaTitle = tempData['title'];
          index = tempData['chapterListIds']
              ?.indexWhere((chapter) => chapter['name'] == currentChapter);
          isLoading = false;
        });
        provider.addReadsManga(
            mangaId: widget.mangaId,
            mangaTitle: tempData['title'],
            currentChapter: currentChapter.toString(),
            mangaImage: widget.image);
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      log(e.toString());
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

    Future<void> fetchChapterImages() async {
    setState(() {
      isLoading = true;
    });
     String url =
        '${dotenv.get("KAKALOT_URL")}api/manga/';
    try {
      final provider = Provider.of<Data>(context, listen: false);
      final resp = await http.get(
          Uri.parse('$url${widget.mangaId}/${chapterList?[index!]['id']}'));
      if (resp.statusCode == 200) {
        final tempData = jsonDecode(resp.body);
        setState(() {
          chapterImages = tempData['images'];
          currentChapter = tempData['currentChapter'];
          isLoading = false;
        });
        provider.addReadsManga(
            mangaId: widget.mangaId,
            mangaTitle: mangaTitle!,
            currentChapter: currentChapter.toString(),
            mangaImage: widget.image)
            ;
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      log(e.toString());
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void handleChapter(String ? direction) {

     if (direction == 'right') {
      index = ((chapterList?.indexWhere(
                  (chapter) => chapter['name'] == currentChapter))! -
              1)
          .clamp(0, chapterList!.length - 1);
          log(index.toString());
    } else {
      index = ((chapterList?.indexWhere(
                  (chapter) => chapter['name'] == currentChapter))! +
              1)
          .clamp(0, chapterList!.length - 1);
    }
    fetchChapterImages();
  }


  @override
  Widget build(BuildContext context) {
    

    return Sliderbar(
      title: isLoading ? '??' : mangaTitle ?? "Unknown",
      chapter: isLoading ? 'Chapter ?' : currentChapter ?? "Unknown",
      totalImages: chapterImages?.length ?? 0,
      scrollController: _scrollController,
      handleChapter: handleChapter,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError
                ? const Text('Failed to load data')
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: chapterImages!.length,
                    itemBuilder: (context, index) {
                       return CachedNetworkImage(
                        imageUrl: chapterImages![index]['image'],
                        fit: BoxFit.cover,
                        placeholder: (context, progress) => SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: const Center(
                              child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator())),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      );
                    },
                  ),
      ),
    );
  }

}
