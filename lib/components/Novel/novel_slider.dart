// ignore_for_file: prefer_const_constructors
import 'package:azyx/components/Common/slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';

typedef ButtonTapCallback = void Function(String? index);

class NovelSlider extends StatefulWidget {
  final String? title;
  final String? chapter;
  final int totalImages;
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
  double textSize = 18.0;

  void _toggleBarsVisibility() {
    setState(() {
      _areBarsVisible = !_areBarsVisible;
    });
  }

  @override
  void initState() {
    super.initState();
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
                      const SizedBox(
                        width: 10,
                      ),
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
                      const SizedBox(
                        width: 10,
                      ),
                      Text(textSize.toStringAsFixed(1))
                    ],
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
                        for (var entry in {
                          'White': Colors.white,
                          'Black': Colors.black,
                          'Grey': Colors.grey,
                          'Light Green': Colors.green.shade100,
                          'Light Purple': Colors.purple.shade100,
                          'Light Brown': Colors.brown.shade100,
                          'Light Red': Colors.red.shade100,
                          'Light Blue': Colors.lightBlue.shade100,
                        }.entries)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(entry.key,
                                  style: GoogleFonts.getFont(selectedFontFamily,
                                      color: selectedTextColor)),
                              selected: selectedBackgroundColor == entry.value,
                              onSelected: (isSelected) {
                                if (isSelected) {
                                  setBottomState(() {
                                    selectedBackgroundColor = entry.value;
                                  });

                                  setState(() {
                                    selectedBackgroundColor;
                                  });
                                }
                              },
                              selectedColor: entry.value,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              labelStyle: TextStyle(
                                color: selectedBackgroundColor == entry.value
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                        for (var entry in {
                          'Black': Colors.black,
                          'White': Colors.white,
                          'Grey': Colors.grey.shade300,
                          'Teal': Colors.teal.shade300,
                          'Deep Orange': Colors.deepOrange.shade400,
                          'Purple': Colors.purple.shade300,
                          'Blue Grey': Colors.blueGrey.shade300,
                          'Green': Colors.green.shade400,
                        }.entries)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(entry.key,
                                  style:
                                      GoogleFonts.getFont(selectedFontFamily)),
                              selected: selectedTextColor == entry.value,
                              onSelected: (isSelected) {
                                if (isSelected) {
                                  setBottomState(() {
                                    selectedTextColor = entry.value;
                                  });

                                  setState(() {
                                    selectedTextColor;
                                  });
                                }
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              labelStyle: TextStyle(
                                color: selectedTextColor == entry.value
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
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
                              selectedFontFamily;
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: selectedTextColor,
                      ),
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
                            style: TextStyle(
                                fontSize: 16, color: selectedTextColor),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.chapter!,
                            style: TextStyle(
                                fontSize: 12, color: selectedTextColor),
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
    super.dispose();
  }
}
