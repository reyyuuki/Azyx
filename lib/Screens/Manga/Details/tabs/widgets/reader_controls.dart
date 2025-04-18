// ignore_for_file: invalid_use_of_protected_member

import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/chapter_item.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/back_button.dart';
import 'package:azyx/Widgets/common/search_widget.dart';
import 'package:azyx/Widgets/common/slider_bar.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReaderControls extends StatefulWidget {
  final String mangaTitle;
  final Rx<String> chapterTitle;
  final Rx<int> totalImages;
  final Rx<int> currentPage;
  final Rx<bool> isShowed;
  final ScrollController scrollController;
  final List<Chapter> chapterList;
  final void Function(bool isNext) onNavigate;
  final void Function(String link) onChapterChaged;
  const ReaderControls(
      {super.key,
      required this.chapterTitle,
      required this.mangaTitle,
      required this.isShowed,
      required this.scrollController,
      required this.chapterList,
      required this.currentPage,
      required this.onNavigate,
      required this.onChapterChaged,
      required this.totalImages});

  @override
  State<ReaderControls> createState() => _ReaderControlsState();
}

class _ReaderControlsState extends State<ReaderControls> {
  final RxList<Chapter> filteredList = RxList();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(updateProgress);
    filteredList.value = widget.chapterList;
  }

  void updateProgress() async {
    if (widget.scrollController.hasClients && widget.totalImages > 0) {
      final currentScroll = widget.scrollController.position.pixels;
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final progress = currentScroll / maxScroll;
      widget.currentPage.value =
          ((progress * (widget.totalImages.value - 1)) + 1).round();
    }
  }

  void _onProgressBarTap(double progress) {
    if (widget.scrollController.hasClients) {
      final maxScrollExtent = widget.scrollController.position.maxScrollExtent;
      final targetScroll =
          (progress / (widget.totalImages.value - 1)) * maxScrollExtent;
      widget.scrollController.jumpTo(
        targetScroll,
      );
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(updateProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => AnimatedContainer(
              transform: Matrix4.identity()
                ..translate(0.0, widget.isShowed.value ? 0 : -100),
              padding: const EdgeInsets.fromLTRB(10,30,10,10),
              width: Get.width,
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const CustomBackButton(),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AzyXText(
                                text: widget.mangaTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color: Theme.of(context).colorScheme.primary,
                                fontVariant: FontVariant.bold,
                                fontSize: 18,
                              ),
                              AzyXText(
                                text: widget.chapterTitle.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade400,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        chapterBottomSheet();
                      },
                      child: glowingButton(context, Broken.menu_1)),
                ],
              ),
            ),
          ),
          Obx(
            () => AnimatedContainer(
                transform: Matrix4.identity()
                  ..translate(0.0, widget.isShowed.value ? 0 : 100),
                curve: Curves.elasticOut,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                width: Get.width,
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () => widget.onNavigate(false),
                        child: glowingButton(context, Broken.previous)),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(1.glowMultiplier()),
                              blurRadius: 10.blurMultiplier(),
                              spreadRadius: 2.spreadMultiplier())
                        ]),
                        child: Obx(
                          () => CustomSlider(
                            value: widget.totalImages.value > 0
                                ? widget.currentPage.value.toDouble()
                                : 0.0,
                            max: widget.totalImages.value > 0
                                ? widget.totalImages.value.toDouble()
                                : 0.0,
                            onChanged: (value) {
                              _onProgressBarTap(value);
                              widget.currentPage.value = value.round();
                            },
                            min: 0.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () => widget.onNavigate(true),
                        child: glowingButton(context, Broken.next))
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Container glowingButton(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(1.glowMultiplier()),
                blurRadius: 10.blurMultiplier(),
                spreadRadius: 2.spreadMultiplier())
          ]),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.inversePrimary,
        size: 25,
        shadows: [
          BoxShadow(
              color: Theme.of(context).colorScheme.inversePrimary,
              blurRadius: 10.blurMultiplier(),
              spreadRadius: 2.spreadMultiplier())
        ],
      ),
    );
  }

  void chapterBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        builder: (context) {
          return AzyXGradientContainer(
            height: Get.height * 0.7,
            padding: const EdgeInsets.all(10),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                AzyXText(
                  text: "Chapters List",
                  textAlign: TextAlign.center,
                  fontVariant: FontVariant.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 10,
                ),
                SearchBox(
                  name: "Search Chapter",
                  ontap: (value) {
                    if (value.isNotEmpty) {
                      filteredList.value = widget.chapterList
                          .where((ch) => ch.title!.contains(value))
                          .toList();
                    } else {
                      filteredList.value = widget.chapterList;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => Column(
                    children: filteredList.value.map((ch) {
                      return GestureDetector(
                        onTap: () {
                          widget.onChapterChaged(ch.link!);
                          Get.back();
                        },
                        child: ChapterItem(
                          chapter: ch,
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        });
  }
}
