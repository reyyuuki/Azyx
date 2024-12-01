import 'dart:developer';
import 'dart:io';
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

  Read({
    super.key,
    required this.mangaId,
    required this.chapterLink,
    required this.image,
  });

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  dynamic chapterData;
  List<dynamic>? chapterImages;
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
    log(widget.chapterLink);
    sourcehandler =
        Provider.of<SourcesProvider>(context, listen: false).getMangaInstance();
    fetchChapterData();
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> fetchChapterData() async {
    try {
      final resp = await sourcehandler.fetchPages(widget.chapterLink);
      final dataProvider = Provider.of<Data>(context, listen: false);
      if (resp != null && resp.toString().isNotEmpty) {
        setState(() {
          chapterImages = resp['images'];
          currentChapter = resp['currentChapter'];
          mangaTitle = resp['title'];
          chapterData = resp;
          isLoading = false;
          isNext = resp['nextChapter'] != null;
          isPrev = resp['previousChapter'] != null;
        });

        // log(currentChapter.toString());
        dataProvider.addReadsManga(
            mangaId: widget.mangaId,
            mangaTitle: resp['title'],
            currentChapter: widget.chapterLink,
            mangaImage: widget.image,
            currentChapterTitle: resp['currentChapter']);
        final progress = resp['currentChapter'].split(" ").last;
        log(progress);
        final anilist = Provider.of<AniListProvider>(context, listen: false);
        if (progress != null) {
          anilist.userData?['name'] != null
              ? anilist.addToAniList(
                  mediaId: int.parse(widget.mangaId),
                  progress: int.parse(progress))
              : [];
        }
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
      final data = await sourcehandler.fetchPages(url!);
      if (data != null && data.toString().isNotEmpty) {
        setState(() {
          chapterImages = data['images'];
          currentChapter = data['currentChapter'];
          isNext = data['nextChapter'] != null;
          isPrev = data['previousChapter'] != null;
          chapterData = data;
          isLoading = false;
        });

        dataProvider.addReadsManga(
            mangaId: widget.mangaId,
            mangaTitle: mangaTitle!,
            currentChapter: url!,
            mangaImage: widget.image,
            currentChapterTitle: data['currentChapter']);
        final progress = data['currentChapter'].split(" ").last;
        log(progress);
        final anilist = Provider.of<AniListProvider>(context, listen: false);
        if (progress != null) {
          anilist.userData?['name'] != null
              ? anilist.addToAniList(
                  mediaId: int.parse(widget.mangaId),
                  progress: int.parse(progress))
              : [];
        }
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
    if ((direction == 'right' && chapterData['nextChapter'] != null) ||
        (direction == 'left' && chapterData['previousChapter'] != null)) {
      log(direction == 'right ' ? 'isright' : 'isleft');
      setState(() {
        url = direction == 'right'
            ? chapterData['nextChapter']
            : chapterData['previousChapter'];
      });

      setState(() {
        isNext = false;
        isPrev = false;
        isLoading = true;
      });

      await fetchChapterImages();

      setState(() {
        isNext = chapterData['nextChapter'] != null;
        isPrev = chapterData['previousChapter'] != null;
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
                            httpHeaders: {'Referer': widget.chapterLink},
                            imageUrl: chapterImages![index]['image'],
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
                              imageUrl: chapterImages![index]['image'],
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
