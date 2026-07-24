import 'dart:developer';
import 'dart:io';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/reader_controls.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:flutter/material.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:azyx/Widgets/subsampling_scale_image_view/subsampling_image_provider.dart';
import 'package:azyx/Screens/Manga/Read/view/manga_page_view_custom.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
class ReadPage extends StatefulWidget {
  final String mangaTitle;
  final String mangaImage;
  final String link;
  final Source source;
  final List<Chapter> chapterList;
  final String? syncId;
  final String? mediaId;
  final int? initialPage;
  const ReadPage({
    super.key,
    required this.source,
    required this.link,
    required this.mangaImage,
    required this.chapterList,
    required this.mangaTitle,
    this.mediaId,
    this.syncId,
    this.initialPage,
  });
  @override
  State<ReadPage> createState() => _ReadPageState();
}
class _ReadPageState extends State<ReadPage> {
  bool _isFirstLoad = true;
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
  bool _isLoadingNext = false;
  int _loadGeneration = 0;
  final List<Chapter> pagesChapters = [];
  final Rx<int> relativeCurrentPage = 0.obs;
  final Rx<int> relativeTotalPages = 0.obs;
  final Set<String> _loadedChapterLinks = {};
  @override
  void initState() {
    super.initState();
    log('[AzyX Reader] initState: widget.link = ${widget.link}');
    log(
      '[AzyX Reader] initState: chapterList length = ${widget.chapterList.length}',
    );
    _currentPage.value = widget.initialPage ?? 1;
    chapterUrl.value = widget.link;
    loadPages();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    updateEntry();
  }
  void localHistoryEntry() {
    log("media id: ${widget.mediaId}");
    final entry = LocalHistoryItem()
      ..mediaId = int.tryParse(widget.mediaId ?? '')
      ..title = widget.mangaTitle
      ..image = widget.mangaImage
      ..link = chapterUrl.value
      ..sourceName = widget.source.name
      ..progress = chapterTitle.value
      ..currentPage = _currentPage.value
      ..mediaType = HistoryMediaType.manga
      ..chapterList = widget.chapterList
      ..mangaSourceJson = jsonEncode(widget.source.toJson());
    Future.microtask(() => localHistoryController.addToReadingHistory(entry));
  }
  void updateEntry() async {
    localHistoryEntry();
    if (serviceHandler.userData.value.name != null) {
      await serviceHandler.updateListEntry(
        serviceHandler.currentMedia.value,
        isAnime: false,
        syncId: widget.syncId,
      );
    }
  }
  Future<void> loadPages() async {
    final generation = ++_loadGeneration;
    final targetUrl = chapterUrl.value;
    log('[AzyX Reader] loadPages gen=$generation url=$targetUrl');
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    try {
      pagesList.value = [];
      pagesChapters.clear();
      _loadedChapterLinks.clear();
      _loadedChapterLinks.add(targetUrl);
      final index = widget.chapterList.indexWhere((i) => i.link == targetUrl);
      log(
        '[AzyX Reader] loadPages: found at index=$index in chapterList(${widget.chapterList.length})',
      );
      if (index == -1) {
        log(
          '[AzyX Reader] ERROR: link not found in chapterList! Dumping first 5 links:',
        );
        for (int i = 0; i < widget.chapterList.length && i < 5; i++) {
          log('  chapterList[$i].link = ${widget.chapterList[i].link}');
        }
        return;
      }
      final currentChapter = widget.chapterList[index];
      log(
        '[AzyX Reader] loadPages: chapter title=${currentChapter.title}, link=${currentChapter.link}',
      );
      chapterTitle.value = currentChapter.title ?? '';
      final pages = await sourceController.activeMangaSource.value!.methods
          .getPageList(
            DEpisode(
              episodeNumber: '1',
              url: targetUrl,
              name: currentChapter.title ?? '',
            ),
          );
      log(
        '[AzyX Reader] loadPages gen=$generation returned ${pages.length} pages, currentGen=$_loadGeneration',
      );
      if (pages.isNotEmpty) {
        log('[AzyX Reader] FIRST PAGE URL: ${pages.first.url}');
      }
      if (generation != _loadGeneration) {
        log('[AzyX Reader] loadPages: stale gen=$generation discarded');
        return;
      }
      final newChapters = List<Chapter>.filled(pages.length, currentChapter);
      pagesChapters.addAll(newChapters);
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      pagesList.value = pages;
      totalImages.value = pages.length;
      relativeCurrentPage.value = 0;
      relativeTotalPages.value = pages.length;
      hasPreviousChapter.value = index < widget.chapterList.length - 1;
      hasNextChapter.value = index > 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == _loadGeneration) {
          if (_isFirstLoad) {
            if (widget.initialPage != null && widget.initialPage! > 0) {
              pageViewController.moveToPage(widget.initialPage!);
            }
            _isFirstLoad = false;
          } else {
            pageViewController.jumpToPage(0);
          }
        }
      });
    } catch (e) {
      if (generation != _loadGeneration) return;
      log("[AzyX Reader] Error: $e");
      azyxSnackBar(e.toString());
    }
  }
  void _checkPreloadNext(int index) {
    if (_isLoadingNext) return;
    final totalLoaded = pagesList.length;
    if (totalLoaded == 0) return;
    if (index >= totalLoaded - 5) {
      _loadNextChapter();
    }
  }
  Future<void> _loadNextChapter() async {
    final currentLink = pagesChapters.isEmpty
        ? chapterUrl.value
        : pagesChapters.last.link;
    final index = widget.chapterList.indexWhere((c) => c.link == currentLink);
    if (index == -1 || index == 0) return;
    final nextChapter = widget.chapterList[index - 1];
    if (nextChapter.link == null ||
        _loadedChapterLinks.contains(nextChapter.link)) {
      return;
    }
    _loadedChapterLinks.add(nextChapter.link!);
    _isLoadingNext = true;
    try {
      final pages = await sourceController.activeMangaSource.value!.methods
          .getPageList(
            DEpisode(
              episodeNumber: '1',
              url: nextChapter.link ?? '',
              name: nextChapter.title ?? '',
            ),
          );
      if (pages.isNotEmpty) {
        final currentChapter = widget.chapterList[index];
        final transitionUrl = PageUrl(
          'azyx://transition?from=${Uri.encodeComponent(currentChapter.title ?? '')}&to=${Uri.encodeComponent(nextChapter.title ?? '')}',
        );
        final newChapters = [
          nextChapter,
          ...List<Chapter>.filled(pages.length, nextChapter),
        ];
        pagesChapters.addAll(newChapters);
        pagesList.add(transitionUrl);
        pagesList.addAll(pages);
        totalImages.value = pagesList.length;
      }
    } catch (e) {
      log("Error loading next chapter: $e");
      _loadedChapterLinks.remove(nextChapter.link);
    } finally {
      _isLoadingNext = false;
    }
  }
  int _getPageIndexInChapter(int absoluteIndex) {
    if (absoluteIndex < 0 || absoluteIndex >= pagesChapters.length) return 0;
    final currentCh = pagesChapters[absoluteIndex];
    int count = 0;
    for (int i = 0; i <= absoluteIndex; i++) {
      if (pagesChapters[i].link == currentCh.link) {
        if (pagesList[i].url.startsWith('azyx://transition')) continue;
        count++;
      }
    }
    return count;
  }
  int _getTotalPagesInChapter(int absoluteIndex) {
    if (absoluteIndex < 0 || absoluteIndex >= pagesChapters.length) return 0;
    final currentCh = pagesChapters[absoluteIndex];
    int count = 0;
    for (int i = 0; i < pagesChapters.length; i++) {
      if (pagesChapters[i].link == currentCh.link) {
        if (pagesList[i].url.startsWith('azyx://transition')) continue;
        count++;
      }
    }
    return count;
  }
  void navigateChapter(bool isNext) {
    final index = widget.chapterList.indexWhere(
      (i) => i.link == chapterUrl.value,
    );
    Utils.log(
      "next: ${hasNextChapter.value} / previous: ${hasPreviousChapter.value} ",
    );
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
  int getAbsoluteIndex(int relativeIndex) {
    final absIndex = _currentPage.value;
    if (absIndex < 0 || absIndex >= pagesChapters.length) return 0;
    final currentCh = pagesChapters[absIndex];
    int firstPageAbsIndex = -1;
    for (int i = 0; i < pagesChapters.length; i++) {
      if (pagesChapters[i].link == currentCh.link) {
        if (pagesList[i].url.startsWith('azyx://transition')) continue;
        firstPageAbsIndex = i;
        break;
      }
    }
    if (firstPageAbsIndex == -1) return 0;
    return firstPageAbsIndex + relativeIndex;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() {
            if (pagesList.isEmpty) {
              return const Center(child: LoadingIndicatorM3E());
            }
            return GestureDetector(
              onTap: () => isShowed.value = !isShowed.value,
              behavior: HitTestBehavior.translucent,
              child: MangaPageView(
                onTap: () => isShowed.value = !isShowed.value,
                pageCount: pagesList.length,
                controller: pageViewController,
                mode: readingLayout.value,
                options: MangaPageViewOptions(
                  mainAxisOverscroll: false,
                  crossAxisOverscroll: false,
                  minZoomLevel: switch (readingLayout.value) {
                    MangaPageViewMode.continuous => 0.75,
                    MangaPageViewMode.paged => 1.0,
                  },
                  maxZoomLevel: 8.0,
                  pageWidthLimit: Platform.isAndroid || Platform.isIOS
                      ? double.infinity
                      : pageWidth.value,
                  edgeIndicatorContainerSize: 240,
                  zoomOvershoot: true,
                  initialPageSize: const Size(300, 300),
                  precacheAhead: readingLayout.value == MangaPageViewMode.paged
                      ? 2
                      : 0,
                  precacheBehind: readingLayout.value == MangaPageViewMode.paged
                      ? 2
                      : 0,
                ),
                onPageChange: (index) {
                  _currentPage.value = index;
                  if (index < 0 || index >= pagesChapters.length) return;
                  final url = (index < pagesList.length)
                      ? pagesList[index].url
                      : '';
                  if (url.startsWith('azyx://transition')) {
                    _checkPreloadNext(index);
                    return;
                  }
                  final chapter = pagesChapters[index];
                  if (chapter.link != chapterUrl.value) {
                    chapterUrl.value = chapter.link ?? '';
                    chapterTitle.value = chapter.title ?? '';
                    final chIndex = widget.chapterList.indexWhere(
                      (c) => c.link == chapter.link,
                    );
                    if (chIndex != -1) {
                      hasPreviousChapter.value =
                          chIndex < widget.chapterList.length - 1;
                      hasNextChapter.value = chIndex > 0;
                      relativeTotalPages.value = _getTotalPagesInChapter(index);
                    }
                    updateEntry();
                  }
                  relativeCurrentPage.value = _getPageIndexInChapter(index) - 1;
                  localHistoryEntry();
                  _checkPreloadNext(index);
                },
                direction: readingDirection.value,
                pageBuilder: (context, index) {
                  final page = pagesList[index];
                  final url = page.url;
                  final chapterLink =
                      (index >= 0 && index < pagesChapters.length)
                      ? (pagesChapters[index].link ?? '')
                      : '';
                  if (url.startsWith('azyx://transition')) {
                    final uri = Uri.parse(url);
                    final from = uri.queryParameters['from'] ?? '';
                    final to = uri.queryParameters['to'] ?? '';
                    return ReaderTransitionWidget(fromTitle: from, toTitle: to);
                  }
                  if (url.startsWith('http')) {
                    return CachedNetworkImage(
                      imageUrl: url,
                      cacheKey: '$chapterLink::$url',
                      fit: BoxFit.contain,
                      httpHeaders: (page.headers?.isEmpty ?? true)
                          ? {
                              'Referer':
                                  sourceController
                                      .activeMangaSource
                                      .value
                                      ?.baseUrl ??
                                  'AzyX',
                              'User-Agent':
                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                            }
                          : page.headers,
                      placeholder: (context, _) => Container(
                        alignment: Alignment.center,
                        height: 300,
                        child: const LoadingIndicatorM3E(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        alignment: Alignment.center,
                        height: 300,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else {
                    return SubsamplingImageProvider(
                      key: ValueKey('${chapterLink}_${url}_$index'),
                      page: page,
                      fit: BoxFit.contain,
                      cropBorders: false,
                      isContinuousMode:
                          readingLayout.value == MangaPageViewMode.continuous,
                      placeholder: Container(
                        alignment: Alignment.center,
                        height: 300,
                        child: const LoadingIndicatorM3E(),
                      ),
                    );
                  }
                },
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
                              : Colors.white54,
                        ),
                      ),
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
                              : Colors.white54,
                        ),
                      ),
                    ],
                  );
                },
                onStartEdgeDrag: hasPreviousChapter.value
                    ? () => navigateChapter(false)
                    : null,
                onEndEdgeDrag: hasNextChapter.value
                    ? () => navigateChapter(true)
                    : null,
              ),
            );
          }),
          ReaderControls(
            controller: pageViewController,
            pageWidth: pageWidth,
            selectedMode: readingLayout,
            selectedDirection: readingDirection,
            totalImages: relativeTotalPages,
            mangaTitle: widget.mangaTitle,
            chapterTitle: chapterTitle,
            isShowed: isShowed,
            chapterList: widget.chapterList,
            currentPage: relativeCurrentPage,
            onNavigate: navigateChapter,
            onChapterChaged: (link) {
              chapterUrl.value = link;
              loadPages();
            },
            onPageSelected: (relIndex) {
              final absIndex = getAbsoluteIndex(relIndex);
              pageViewController.jumpToPage(absIndex);
            },
          ),
          Positioned(
            bottom: 8,
            width: Get.width,
            child: Obx(() {
              final cur = relativeCurrentPage.value;
              final tot = relativeTotalPages.value;
              if (tot == 0) return const SizedBox.shrink();
              return Text(
                "${cur + 1} / $tot",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins-Bold",
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
class ReaderTransitionWidget extends StatelessWidget {
  final String fromTitle;
  final String toTitle;
  const ReaderTransitionWidget({
    super.key,
    required this.fromTitle,
    required this.toTitle,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            width: 100,
            color: colors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            fromTitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            toTitle,
            style: TextStyle(
              color: colors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: 100,
            color: colors.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
