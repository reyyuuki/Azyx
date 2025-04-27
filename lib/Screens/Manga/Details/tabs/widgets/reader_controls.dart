// ignore_for_file: invalid_use_of_protected_member

import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/chapter_item.dart';
import 'package:azyx/Screens/Manga/Read/read.dart';
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
  final Rx<Mode> selectedMode;
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
      required this.selectedMode,
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
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
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
                        settingsBottomSheet();
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(1.glowMultiplier()),
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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(1.glowMultiplier()),
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

  void settingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AzyXGradientContainer(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  children: [
                    Icon(Icons.settings,
                        size: 24, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AzyXText(
                          text: "Reading Settings",
                          fontVariant: FontVariant.bold,
                          fontSize: 20,
                        ),
                        AzyXText(
                          text: "Customize your experience",
                          fontVariant: FontVariant.regular,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    chapterBottomSheet();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book,
                                color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: 12),
                            const AzyXText(
                              text: "Chapters List",
                              fontVariant: FontVariant.bold,
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.white.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const AzyXText(
                  text: "Reading Mode",
                  fontVariant: FontVariant.bold,
                  fontSize: 16,
                ),
                const SizedBox(height: 16),

                Obx(
                  () => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildReadingModeCard(
                        icon: Icons.keyboard_arrow_right,
                        title: "Left to Right",
                        mode: Mode.left,
                        isSelected:
                            (widget.selectedMode.value == Mode.left).obs,
                      ),
                      _buildReadingModeCard(
                        icon: Icons.keyboard_arrow_left,
                        title: "Right to Left",
                        mode: Mode.right,
                        isSelected:
                            (widget.selectedMode.value == Mode.right).obs,
                      ),
                      _buildReadingModeCard(
                        icon: Icons.vertical_align_bottom,
                        title: "Webtoon",
                        mode: Mode.webtoon,
                        isSelected:
                            (widget.selectedMode.value == Mode.webtoon).obs,
                      ),
                      _buildReadingModeCard(
                        icon: Icons.chrome_reader_mode,
                        title: "Standard",
                        mode: Mode.standard,
                        isSelected:
                            (widget.selectedMode.value == Mode.standard).obs,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingModeCard(
      {required IconData icon,
      required String title,
      required RxBool isSelected,
      required Mode mode}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected.value
              ? Theme.of(context).colorScheme.primary
              : Colors.white.withOpacity(0.2),
          width: isSelected.value ? 2 : 1,
        ),
        color: isSelected.value
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
      ),
      child: InkWell(
        onTap: () {
          widget.selectedMode.value = mode;
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected.value
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AzyXText(
                  text: title,
                  fontVariant: FontVariant.bold,
                  fontSize: 13,
                  color: isSelected.value
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
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
                10.height,
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
