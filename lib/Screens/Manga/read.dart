// ignore_for_file: must_be_immutable
import 'dart:developer';
import 'dart:io';
import 'package:azyx/api/Mangayomi/Eval/dart/model/page.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/get_pages_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:azyx/Provider/sources_provider.dart';
import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/components/Manga/sliderBar.dart';
import 'package:azyx/Hive_Data/appDatabase.dart';
import 'package:azyx/utils/sources/Manga/Base/extract_class.dart';
import 'package:azyx/utils/sources/Manga/SourceHandler/sourcehandler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Read extends StatefulWidget {
  final String mangaId;
  String chapterLink;
  String image;
  final Source source;
  final dynamic chapterList;
  final String mangatitle;

  Read(
      {super.key,
      required this.mangaId,
      required this.chapterLink,
      required this.image,
      required this.source,
      required this.mangatitle,
      required this.chapterList});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  dynamic chapterData;
  List<PageUrl>? chapterImages;
  String? currentChapter;
  String? mangaTitle;
  String? url;
  ExtractClass? source;
  late MangaSourcehandler sourcehandler;

  bool isLoading = true;
  bool hasError = false;
  bool isNext = true;
  bool isPrev = true;

  @override
  void initState() {
    super.initState();
    sourcehandler =
        Provider.of<SourcesProvider>(context, listen: false).getMangaInstance();
    fetchChapterData();
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> fetchChapterData() async {
    try {
      log(widget.chapterLink.split('/').take(3).join('/'));
      final resp = await getPagesList(
          mangaId: widget.chapterLink, source: widget.source);
      final dataProvider = Provider.of<Data>(context, listen: false);
      if (resp != null && resp.toString().isNotEmpty) {
        log("data: $resp");
        setState(() {
          chapterImages = resp;
          currentChapter = widget.chapterList
              .firstWhere((i) => i['url'] == widget.chapterLink)['name'];
          mangaTitle = widget.mangatitle;
          isLoading = false;
        });

        log(currentChapter.toString());
        dataProvider.addReadsManga(
            mangaId: widget.mangaId,
            mangaTitle: widget.mangatitle,
            currentChapter: widget.chapterLink,
            mangaImage: widget.image,
            currentChapterTitle: currentChapter!);
        // final progress = resp['currentChapter'].split(" ").last;
        // log(progress);
        // final anilist = Provider.of<AniListProvider>(context, listen: false);
        // if (progress != null) {
        //   anilist.userData?['name'] != null
        //       ? anilist.addToAniList(
        //           mediaId: int.parse(widget.mangaId),
        //           progress: int.parse(progress))
        //       : [];
        // }
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
      final data = await getPagesList(source: widget.source, mangaId: url!);
      if (data != null && data.isNotEmpty) {
        final index = widget.chapterList.indexWhere((i) => i['url'] == url);
        log("chapter: index $index");
        setState(() {
          chapterImages = data;
          // isNext = widget.chapterList[index - 1]?['url'] != null;
          // isPrev = widget.chapterList[index + 1]?['url'] != null;
          // chapterData = data;
          isLoading = false;
        });

        dataProvider.addReadsManga(
            mangaId: widget.mangaId,
            mangaTitle: mangaTitle!,
            currentChapter: url!,
            mangaImage: widget.image,
            currentChapterTitle: currentChapter!);
        // final progress = data['currentChapter'].split(" ").last;
        // log(progress);
        // final anilist = Provider.of<AniListProvider>(context, listen: false);
        // if (progress != null) {
        //   anilist.userData?['name'] != null
        //       ? anilist.addToAniList(
        //           mediaId: int.parse(widget.mangaId),
        //           progress: int.parse(progress))
        //       : [];
        // }
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
  if (direction == 'right' || direction == 'left') {
    int index = widget.chapterList.indexWhere((i) => i['name'] == currentChapter);

    // Boundary checks
    if ((direction == 'right' && index <= 0) || 
        (direction == 'left' && index >= widget.chapterList.length - 1)) {
      log("No more chapters in the $direction direction");
      return;
    }

    int newIndex = direction == 'right' ? index - 1 : index + 1;
    log("$index / $newIndex");

    setState(() {
      url = widget.chapterList[newIndex]['url'] ?? '';
      currentChapter = widget.chapterList[newIndex]['name'];
      isLoading = true;
    });

    await fetchChapterImages();

    setState(() {
      isNext = newIndex > 0; 
      isPrev = newIndex < widget.chapterList.length - 1;
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Sliderbar(
      title: isLoading ? '??' : mangaTitle ?? "Unknown",
      chapter: isLoading ? 'Chapter ?' : currentChapter ?? "Unknown",
      totalImages: chapterImages?.length ?? 0,
      scrollController: _scrollController,
      handleChapter: handleChapter,
      isNext: isNext,
      isPrev: isPrev,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError
                ? const Text('Failed to load data')
                : (Platform.isAndroid || Platform.isIOS
                    ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        itemCount: chapterImages!.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            filterQuality: FilterQuality.high,
                            httpHeaders: {
                              'Referer': widget.chapterLink
                                  .split('/')
                                  .take(3)
                                  .join('/')
                            },
                            imageUrl: chapterImages![index].url,
                            fit: BoxFit.cover,
                            placeholder: (context, progress) => SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          );
                        },
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: _scrollController,
                          itemCount: chapterImages!.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              filterQuality: FilterQuality.high,
                              httpHeaders: {'Referer': widget.chapterLink},
                              imageUrl: chapterImages![index].url,
                              fit: BoxFit.cover,
                              placeholder: (context, progress) => SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: const Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            );
                          },
                        ),
                      )),
      ),
    );
  }
}
