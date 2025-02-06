import 'dart:developer';

import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/reader_controls.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/page.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/get_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadPage extends StatefulWidget {
  final String mangaTitle;
  final String link;
  final Source source;
  final List<Chapter> chapterList;
  const ReadPage(
      {super.key,
      required this.source,
      required this.link,
      required this.chapterList,
      required this.mangaTitle});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  final RxList<PageUrl> pagesList = RxList();
  final Rx<int> totalImages = 0.obs;
  final Rx<String> chapterTitle = ''.obs;
  final Rx<String> chapterUrl = ''.obs;
  final Rx<bool> isShowed = false.obs;

  @override
  void initState() {
    super.initState();
    loadPages(widget.link);
  }

  Future<void> loadPages(String url) async {
    try {
      final pages = await getPagesList(source: widget.source, mangaId: url);
      pagesList.value = pages!;
      chapterTitle.value =
          widget.chapterList.firstWhere((i) => i.link == url).title!;
    } catch (e) {
      log("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () {
                isShowed.value = !isShowed.value;
                log("tapped");
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...pagesList.map((p) {
                      return CachedNetworkImage(
                          imageUrl: p.url, fit: BoxFit.cover);
                    })
                  ],
                ),
              ),
            ),
          ),
          ReaderControls(
            totalImages: totalImages,
            mangaTitle: widget.mangaTitle,
            chapterTitle: chapterTitle,
            isShowed: isShowed,
          )
        ],
      ),
    );
  }
}
