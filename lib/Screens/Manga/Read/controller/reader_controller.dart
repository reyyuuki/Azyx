import 'dart:developer';

import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:dartotsu_extension_bridge/Models/Page.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:get/get.dart';
import 'package:manga_page_view/manga_page_view.dart';

enum Mode { webtoon, left, right, standard }

class ReaderController extends GetxController {
  final RxList<PageUrl> pagesList = RxList();
  final Rx<int> totalImages = 0.obs;
  final Rx<int> _currentPage = 0.obs;
  final Rx<String> chapterTitle = ''.obs;
  final Rx<String> chapterUrl = ''.obs;
  final Rx<bool> isShowed = true.obs;
  final Rx<Mode> selectedMode = Mode.webtoon.obs;
  MangaPageViewController pageViewController = MangaPageViewController();

  void _setupPageViewListener() {
    pageViewController.addPageChangeListener((i) => _currentPage.value = i);
  }

  Future<void> loadPages(
      {required Source source, required List<Chapter> chapterList}) async {
    try {
      pagesList.value = [];
      // final pages =
      //     await getPagesList(source: source, mangaId: chapterUrl.value);
      // pagesList.value = pages!;
      // totalImages.value = pages.length;
      // _currentPage.value = 1;
      // final index = chapterList.indexWhere((i) => i.link == chapterUrl.value);
      // chapterTitle.value = chapterList[index].title!;
    } catch (e) {
      log("Error: $e");
      azyxSnackBar(e.toString());
    }
  }

  void navigateChapter(bool isNext,
      {required Source source, required List<Chapter> chapterList}) {
    final index = chapterList.indexWhere((i) => i.link == chapterUrl.value);
    if (index == -1) return;
    if (isNext && index > 0) {
      chapterUrl.value = chapterList[index - 1].link!;
      loadPages(source: source, chapterList: chapterList);
      azyxSnackBar('${chapterList[index - 1].number} chapter');
    } else if (!isNext && index < chapterList.length - 1) {
      chapterUrl.value = chapterList[index + 1].link!;
      loadPages(source: source, chapterList: chapterList);
      azyxSnackBar('${chapterList[index + 1].number} chapter');
    } else {
      azyxSnackBar('No Chapter Avail');
    }
  }
}
