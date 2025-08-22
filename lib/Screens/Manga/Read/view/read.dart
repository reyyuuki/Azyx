import 'dart:developer';
import 'dart:io';

import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/reader_controls.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartotsu_extension_bridge/Models/Page.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manga_page_view/manga_page_view.dart';

class ReadPage extends StatefulWidget {
  final String mangaTitle;
  final String link;
  final Source source;
  final List<Chapter> chapterList;
  final String? syncId;
  const ReadPage(
      {super.key,
      required this.source,
      required this.link,
      required this.chapterList,
      required this.mangaTitle,
      this.syncId});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  final RxList<PageUrl> pagesList = RxList();
  final Rx<int> totalImages = 0.obs;
  final Rx<int> _currentPage = 1.obs;
  final Rx<String> chapterTitle = ''.obs;
  final Rx<String> chapterUrl = ''.obs;
  final Rx<bool> isShowed = true.obs;
  final Rx<bool> hasNextChapter = true.obs;
  final Rx<bool> hasPreviousChapter = true.obs;
  final Rx<MangaPageViewMode> readingLayout = MangaPageViewMode.continuous.obs;
  final Rx<double> pageWidth = (Get.width - 200).obs;
  final Rx<MangaPageViewDirection> readingDirection =
      MangaPageViewDirection.down.obs;

  final MangaPageViewController pageViewController = MangaPageViewController();

  @override
  void initState() {
    super.initState();
    chapterUrl.value = widget.link;
    loadPages();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    updateEntry();
    // pageViewController.addPageChangeListener((e) {
    //   Utils.log(
    //       'DX => ${pageViewController.getCurrentOffset()?.dx.toString()}');
    //   Utils.log(
    //       'DY => ${pageViewController.getCurrentOffset()?.dy.toString()}');
    // });
    // pageViewController.addPageChangeListener((i) {
    //   Utils.log(i.toString());
    //   _currentPage.value = i;
    // });
  }

  void updateEntry() async {
    if (serviceHandler.userData.value.name != null) {
      log(anilistAddToListController.manga.value.status!);
      await serviceHandler.updateListEntry(
          anilistAddToListController.manga.value,
          isAnime: false,
          syncId: widget.syncId);
    }
  }

  Future<void> loadPages() async {
    try {
      pagesList.value = [];
      final pages = await sourceController.activeMangaSource.value!.methods
          .getPageList(DEpisode(
              episodeNumber: chapterTitle.value, url: chapterUrl.value));
      pagesList.value = pages;
      totalImages.value = pages.length;
      final index =
          widget.chapterList.indexWhere((i) => i.link == chapterUrl.value);
      chapterTitle.value = widget.chapterList[index].title!;
      hasPreviousChapter.value = index < widget.chapterList.length - 1;
      hasNextChapter.value = index > 0;
      Utils.log(
          "next: ${hasNextChapter.value} / previous: ${hasPreviousChapter.value} ${index.toString()}");
    } catch (e) {
      log("Error: $e");
      azyxSnackBar(e.toString());
    }
  }

  void navigateChapter(bool isNext) {
    final index =
        widget.chapterList.indexWhere((i) => i.link == chapterUrl.value);

    Utils.log(
        "next: ${hasNextChapter.value} / previous: ${hasPreviousChapter.value} ");
    if (index == -1) return;
    if (isNext && index > 0) {
      chapterUrl.value = widget.chapterList[index - 1].link!;
      loadPages();
      azyxSnackBar('${widget.chapterList[index - 1].number} chapter');
    } else if (!isNext && index < widget.chapterList.length - 1) {
      chapterUrl.value = widget.chapterList[index + 1].link!;
      loadPages();
      azyxSnackBar('${widget.chapterList[index + 1].number} chapter');
    } else {
      azyxSnackBar('No Chapter Avail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() {
            if (pagesList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return GestureDetector(
                onTap: () => isShowed.value = !isShowed.value,
                behavior: HitTestBehavior.translucent,
                child: MangaPageView(
                  pageCount: pagesList.length,
                  controller: pageViewController,
                  mode: readingLayout.value,
                  options: MangaPageViewOptions(
                    // padding: MediaQuery.paddingOf(context),
                    mainAxisOverscroll: false,
                    crossAxisOverscroll: false,
                    minZoomLevel: switch (readingLayout.value) {
                      MangaPageViewMode.continuous => 0.75,
                      MangaPageViewMode.paged => 1.0
                    },
                    maxZoomLevel: 8.0,
                    // initialOffset: Offset(200, 0),
                    // initialPageIndex: 10,

                    // spacing: spacedPages.value ? 20 : 0,
                    pageWidthLimit: Platform.isAndroid || Platform.isIOS
                        ? double.infinity
                        : pageWidth.value,
                    edgeIndicatorContainerSize: 240,
                    zoomOvershoot: true,
                    initialPageSize: const Size(300, 300),
                    precacheAhead:
                        readingLayout.value == MangaPageViewMode.paged ? 2 : 0,
                    precacheBehind:
                        readingLayout.value == MangaPageViewMode.paged ? 2 : 0,
                  ),
                  onPageChange: (index) {
                    _currentPage.value = index;
                    Utils.log('page: ${_currentPage.value}/$index');
                  },
                  direction: readingDirection.value,
                  pageBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: pagesList[index].url,
                    fit: BoxFit.cover,
                    httpHeaders: {
                      'Referer':
                          sourceController.activeMangaSource.value?.baseUrl ??
                              'AzyX',
                    },
                    placeholder: (context, _) => Container(
                      alignment: Alignment.center,
                      height: 300,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                  startEdgeDragIndicatorBuilder: (context, info) {
                    return Column(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: info.isTriggered ? 1.6 : 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          child: Icon(
                            hasPreviousChapter.value
                                ? Icons.skip_previous_rounded
                                : Icons.block_rounded,
                            color: info.isTriggered
                                ? Colors.white
                                : Colors.white54,
                            size: 36,
                          ),
                        ),
                        Text(
                          hasPreviousChapter.value
                              ? 'Previous chapter'
                              : "No previous chapter",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: info.isTriggered
                                  ? Colors.white
                                  : Colors.white54),
                        )
                      ],
                    );
                  },
                  endEdgeDragIndicatorBuilder: (context, info) {
                    return Column(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: info.isTriggered ? 1.6 : 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          child: Icon(
                            hasNextChapter.value
                                ? Icons.skip_next_rounded
                                : Icons.block_rounded,
                            color: info.isTriggered
                                ? Colors.white
                                : Colors.white54,
                            size: 36,
                          ),
                        ),
                        Text(
                          hasNextChapter.value
                              ? 'Next chapter'
                              : "No next chapter",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: info.isTriggered
                                  ? Colors.white
                                  : Colors.white54),
                        )
                      ],
                    );
                  },
                  onStartEdgeDrag: hasPreviousChapter.value
                      ? () => navigateChapter(false)
                      : null,
                  onEndEdgeDrag:
                      hasNextChapter.value ? () => navigateChapter(true) : null,
                ));
          }),
          ReaderControls(
            controller: pageViewController,
            pageWidth: pageWidth,
            selectedMode: readingLayout,
            selectedDirection: readingDirection,
            totalImages: totalImages,
            mangaTitle: widget.mangaTitle,
            chapterTitle: chapterTitle,
            isShowed: isShowed,
            chapterList: widget.chapterList,
            currentPage: _currentPage,
            onNavigate: navigateChapter,
            onChapterChaged: (link) {
              chapterUrl.value = link;
              loadPages();
            },
          ),
          Positioned(
            bottom: 8,
            width: Get.width,
            child: Obx(() => Text(
                  "${_currentPage.value} / ${totalImages.value}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: "Poppins-Bold"),
                )),
          ),
        ],
      ),
    );
  }

  // Widget _pageView() {
  //   return PageView.builder(
  //     // controller: pageViewController,
  //     onPageChanged: (index) => _currentPage.value = index + 1,
  //     scrollDirection:
  //         selectedMode.value == Mode.standard ? Axis.vertical : Axis.horizontal,
  //     reverse: selectedMode.value == Mode.left,
  //     itemCount: pagesList.length,
  //     itemBuilder: (context, index) => Center(
  //       child: CachedNetworkImage(
  //         imageUrl: pagesList[index].url,
  //         fit: BoxFit.cover,
  //         httpHeaders: {
  //           'Referer': widget.source.baseUrl!,
  //         },
  //         placeholder: (context, _) => Container(
  //           alignment: Alignment.center,
  //           height: 300,
  //           child: const CircularProgressIndicator(),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
