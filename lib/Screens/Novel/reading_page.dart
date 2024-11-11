import 'dart:developer';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/components/Manga/sliderBar.dart';
import 'package:daizy_tv/components/Novel/novel_slider.dart';
import 'package:daizy_tv/utils/scraper/Novel/wuxia_novel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NovelRead extends StatefulWidget {
  final String novelId;
  String chapterLink;
  String image;
  String title;

  NovelRead({
    super.key,
    required this.novelId,
    required this.chapterLink,
    required this.image,
    required this.title
  });

  @override
  State<NovelRead> createState() => _ReadState();
}

class _ReadState extends State<NovelRead> {
  dynamic chapterData;
  List<dynamic>? chapterWords;
  String? currentChapter;
  String? url;

  bool isLoading = true;
  bool hasError = false;
  bool isNext = true;
  bool isPrev = true;

  @override
  void initState() {
    super.initState();
    fetchChapterData();
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> fetchChapterData() async {
 
    try {
      
        final resp = await scrapeNovelWords(widget.chapterLink);
        final dataProvider = Provider.of<Data>(context, listen: false);
        
        if (resp.isNotEmpty) {
          setState(() {
            chapterWords = resp['words'];
            currentChapter = resp['currentChapter'];
            chapterData = resp;
            isLoading = false;
            isNext = resp['nextChapterId'] != null;
            isPrev = resp['prevChapterId'] != null;
          });

          dataProvider.addReadsNovel(
          novelId: widget.novelId,
          noveltitle: widget.title,
          currentChapter: widget.chapterLink,
          image: widget.image,
        );
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
          log('Error: Chapter data is empty');
        }
    } catch (e) {
      log('Error: $e');
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
    try {
      final dataProvider = Provider.of<Data>(context, listen: false);
      final data = await scrapeNovelWords(url!);
      if (data.isNotEmpty) {
        setState(() {
          chapterWords = data['words'];
          currentChapter = data['currentChapter'];
          isNext = data['nextChapterId'] != null;
          isPrev = data['prevChapterId'] != null;
          chapterData = data;
          isLoading = false;
        });

        dataProvider.addReadsNovel(
          novelId: widget.novelId,
          noveltitle: widget.title,
          currentChapter: url!,
          image: widget.image,
        );

      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

 void handleChapter(String? direction) async {
  if ((direction == 'right' && chapterData['nextChapterId'] != null) ||
      (direction == 'left' && chapterData['prevChapterId'] != null)) {
        log(direction == 'right '? 'isright' : 'isleft');
        setState(() {
          url = direction == 'right' ? chapterData['nextChapterId'] : chapterData['prevChapterId'];
        });
 
    setState(() {
      isNext = false;
      isPrev = false;
      isLoading = true;
    });

    await fetchChapterImages();

    setState(() {
      isNext = chapterData['nextChapterId'] != null;
      isPrev = chapterData['prevChapterId'] != null;
    });

  }
}


  @override
Widget build(BuildContext context) {
  if (hasError) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 100),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                hasError = false;
              });
              fetchChapterData(); // Retry fetching data
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  if (isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  return NovelSlider(
    title: isLoading ? 'Unknown' : widget.title,
    chapter: isLoading ? 'Chapter ?' : currentChapter ?? "Unknown",
    totalImages: chapterWords?.length ?? 0,
    scrollController: _scrollController,
    handleChapter: handleChapter,
    isNext: isNext,
    isPrev: isPrev,
    isLoading: isLoading,
    hasError: hasError,
    chapterWords: chapterWords!,
  );
}

}
