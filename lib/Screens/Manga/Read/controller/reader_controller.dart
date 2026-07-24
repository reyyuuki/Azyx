import 'dart:developer';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:anymex_extension_runtime_bridge/Models/Page.dart';
import 'package:anymex_extension_runtime_bridge/Models/Source.dart';
import 'package:get/get.dart';
import 'package:azyx/Screens/Manga/Read/view/manga_page_view_custom.dart';
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
