import 'dart:developer';

import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/reader_controls.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/api/Mangayomi/Eval/dart/model/page.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/get_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Mode { webtoon, left, right, standard }

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
  final Rx<int> _currentPage = 0.obs;
  final Rx<String> chapterTitle = ''.obs;
  final Rx<String> chapterUrl = ''.obs;
  final Rx<bool> isShowed = true.obs;
  final ScrollController scrollController = ScrollController();
  final PageController _pageController = PageController();
  final Rx<Mode> selectedMode = Mode.webtoon.obs;

  @override
  void initState() {
    super.initState();
    chapterUrl.value = widget.link;
    loadPages();
  }

  Future<void> loadPages() async {
    try {
      pagesList.value = [];
      final pages =
          await getPagesList(source: widget.source, mangaId: chapterUrl.value);
      pagesList.value = pages!;
      totalImages.value = pages.length;
      _currentPage.value = 1;
      final index =
          widget.chapterList.indexWhere((i) => i.link == chapterUrl.value);
      chapterTitle.value = widget.chapterList[index].title!;
    } catch (e) {
      log("Error: $e");
      azyxSnackBar(e.toString());
    }
  }

  void navigateChapter(bool isNext) {
    final index =
        widget.chapterList.indexWhere((i) => i.link == chapterUrl.value);
    if (index == -1) return;
    if (isNext && index > 0) {
      chapterUrl.value = widget.chapterList[index - 1].link!;
      loadPages();
      azyxSnackBar(
        '${widget.chapterList[index - 1].number} chapter',
      );
    } else if (!isNext && index < widget.chapterList.length - 1) {
      chapterUrl.value = widget.chapterList[index + 1].link!;
      loadPages();
      azyxSnackBar(
        '${widget.chapterList[index + 1].number} chapter',
      );
    } else {
      azyxSnackBar(
        'No Chapter Avail',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => pagesList.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GestureDetector(
                  onTap: () {
                    isShowed.value = !isShowed.value;
                    log("tapped");
                  },
                  child: selectedMode.value == Mode.webtoon
                      ? SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              ...pagesList.map((p) {
                                return CachedNetworkImage(
                                  imageUrl: p.url,
                                  fit: BoxFit.cover,
                                  httpHeaders: {
                                    'Referer': widget.source.baseUrl!,
                                  },
                                  placeholder: (context, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      height: 300,
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        )
                      : _pageView())),
          ReaderControls(
            scrollController: scrollController,
            selectedMode: selectedMode,
            totalImages: totalImages,
            mangaTitle: widget.mangaTitle,
            chapterTitle: chapterTitle,
            isShowed: isShowed,
            chapterList: widget.chapterList,
            currentPage: _currentPage,
            onNavigate: (isNext) => navigateChapter(isNext),
            onChapterChaged: (link) {
              chapterUrl.value = link;
              loadPages();
            },
          ),
          Positioned(
              bottom: 0,
              width: Get.width,
              child: Obx(
                () => Text(
                  "${_currentPage.value} / ${totalImages.value}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: "Poppins-Bold"),
                ),
              ))
        ],
      ),
    );
  }

  Widget _pageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        _currentPage.value = index;
      },
      scrollDirection:
          selectedMode.value == Mode.standard ? Axis.vertical : Axis.horizontal,
      reverse: selectedMode.value == Mode.left,
      itemCount: pagesList.length,
      itemBuilder: (context, index) => Center(
        child: CachedNetworkImage(
          imageUrl: pagesList[index].url,
          fit: BoxFit.cover,
          httpHeaders: {
            'Referer': widget.source.baseUrl!,
          },
          placeholder: (context, index) {
            return Container(
              alignment: Alignment.center,
              height: 300,
              child: const CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
