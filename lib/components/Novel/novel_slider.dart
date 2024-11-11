// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/components/Common/slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';

typedef ButtonTapCallback = void Function(String? index);

class NovelSlider extends StatefulWidget {
  final String? title;
  final String? chapter;
  final int totalImages;
  final ScrollController scrollController;
  final ButtonTapCallback handleChapter;
  bool isNext;
  bool isPrev;
  bool isLoading;
  bool hasError;
  List<dynamic> chapterWords;

  NovelSlider({
    super.key,
    required this.title,
    required this.chapter,
    required this.totalImages,
    required this.scrollController,
    required this.handleChapter,
    required this.isNext,
    required this.isPrev,
    required this.isLoading,
    required this.hasError,
    required this.chapterWords,
  });

  @override
  State<NovelSlider> createState() => _SlidebarState();
}

class _SlidebarState extends State<NovelSlider> {
  bool _areBarsVisible = false;
  double _scrollProgress = 0.0;
  int _currentPage = 1;
  double textSize = 18.0;

  void _toggleBarsVisibility() {
    setState(() {
      _areBarsVisible = !_areBarsVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    if (widget.scrollController.hasClients && widget.totalImages > 0) {
      final maxScrollExtent = widget.scrollController.position.maxScrollExtent;
      final currentScroll = widget.scrollController.position.pixels;
      final progress = currentScroll / maxScrollExtent;

      setState(() {
        _scrollProgress = progress.clamp(0.0, 1.0);
        _currentPage = ((progress * (widget.totalImages - 1)) + 1).round();
      });
    }
  }

  void _onProgressBarTap(double progress) {
    if (widget.scrollController.hasClients) {
      final targetPage = (progress * (widget.totalImages - 1)).round();

      widget.scrollController.jumpTo(
        targetPage *
            (widget.scrollController.position.maxScrollExtent /
                (widget.totalImages - 1)),
      );
    }
  }

  String selectedFontFamily = "Roboto";
  Color selectedBackgroundColor = Colors.black;
  Color selectedTextColor = Colors.white;

  void showSliderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setBottomState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 650,
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      "Page Settings",
                      style:
                          GoogleFonts.getFont(selectedFontFamily, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Iconsax.text),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: CustomSlider(
                          min: 12,
                          max: 40,
                          divisions: 10,
                          value: double.parse(textSize.toStringAsFixed(1)),
                          onChanged: (newValue) {
                            setBottomState(() {
                              textSize = newValue;
                            });
                            setState(() {
                              this.textSize;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text(textSize.toStringAsFixed(1))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      "Roboto",
                      "Lato",
                      "Poppins",
                      "Oswald",
                      "Raleway",
                      "Montserrat",
                      "Merriweather",
                      "Noto Sans",
                      "Open Sans",
                    ].map((font) {
                      return ChoiceChip(
                        label: Text(font, style: GoogleFonts.getFont(font)),
                        selected: selectedFontFamily == font,
                        onSelected: (isSelected) {
                          if (isSelected) {
                            setBottomState(() {
                              selectedFontFamily = font;
                            });
                            setState(() {
                              this.selectedFontFamily;
                            });
                          }
                        },
                        selectedColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        labelStyle: TextStyle(
                          color: selectedFontFamily == font
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.inverseSurface,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text("Background Color",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Colors.white,
                        Colors.black,
                        Colors.grey,
                        Colors.green.shade100,
                        Colors.purple.shade100,
                        Colors.brown.shade100,
                        Colors.red.shade100,
                        Colors.lightBlue.shade100,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () {
                            setBottomState(() {
                              selectedBackgroundColor = color;
                            });
                            setState(() {
                              this.selectedBackgroundColor;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedBackgroundColor == color
                                      ? color // Highlight selected background color
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: color,
                                ),
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              const SizedBox(height: 20,),
                  Text("Text Color",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Colors.black,
                        Colors.white,
                        Colors.grey.shade300,
                        Colors.teal.shade300,
                        Colors.deepOrange.shade400,
                        Colors.purple.shade300,
                        Colors.blueGrey.shade300,
                        Colors.green.shade400,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () {
                            setBottomState(() {
                              selectedTextColor = color;
                            });
                            setState(() {
                              this.selectedTextColor;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedTextColor == color
                                      ? color
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: color,
                                ),
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                        borderRadius: BorderRadius.circular(5),
                        color: selectedBackgroundColor),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "This is a preview for text settings",
                        style: GoogleFonts.getFont(selectedFontFamily,
                            fontSize: textSize, color: selectedTextColor),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: selectedBackgroundColor,
        body: Stack(
          children: [
            GestureDetector(
              onTap: _toggleBarsVisibility,
              child: Center(
                child: widget.isLoading
                    ? const CircularProgressIndicator()
                    : widget.hasError
                        ? const Text('Failed to load data')
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: ListView.builder(
                              itemCount: widget.chapterWords.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  widget.chapterWords.toString(),
                                  style: GoogleFonts.getFont(selectedFontFamily,
                                      fontSize: textSize,
                                      color: selectedTextColor),
                                );
                              },
                            ),
                          ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _areBarsVisible ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: selectedTextColor,),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title!.length > 25
                                ? '${widget.title!.substring(0, 25)}...'
                                : widget.title!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: selectedTextColor),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.chapter!,
                            style: TextStyle(fontSize: 12, color: selectedTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => showSliderBottomSheet(context),
                      icon: Icon(
                        Ionicons.settings,
                        color: selectedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _areBarsVisible ? 25 : -100,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: widget.isPrev
                                ? Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.5)
                                : Colors.white.withOpacity(0.5),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              color: widget.isPrev
                                  ? selectedTextColor
                                  : Colors.white.withOpacity(0.5),
                                  size: 30,
                            ),
                            onPressed: () {
                              widget.handleChapter('left');
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: widget.isNext
                                ? Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.5)
                                : Colors.white.withOpacity(0.5),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: widget.isNext
                                  ? selectedTextColor
                                  : Colors.white.withOpacity(0.5),
                                  size: 30,
                            ),
                            onPressed: () {
                              widget.handleChapter('right');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollProgress);
    super.dispose();
  }
}
