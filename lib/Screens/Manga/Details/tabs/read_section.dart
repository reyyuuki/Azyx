// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:developer';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Screens/Manga/Details/tabs/widgets/chapter_item.dart';
import 'package:azyx/Screens/Manga/Read/view/read.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/mapped_title.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_normal_card.dart';
import 'package:azyx/Widgets/common/search_widget.dart';
import 'package:azyx/Widgets/custom_drop_down.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadSection extends StatefulWidget {
  final String image;
  final int id;
  final Rx<Source> selectedSource;
  final RxList<Source> installedExtensions;
  final Rx<String> animeTitle;
  final Rx<String> totalEpisodes;
  final RxList<Chapter> chaptersList;
  final Rx<bool> hasError;
  final Rx<String> syncId;
  Function(List<DEpisode>) onChanged;
  Function(String) onTitleChanged;
  Function() onSourceChanged;

  ReadSection(
      {super.key,
      required this.id,
      required this.image,
      required this.installedExtensions,
      required this.totalEpisodes,
      required this.selectedSource,
      required this.chaptersList,
      required this.hasError,
      required this.onChanged,
      required this.onTitleChanged,
      required this.onSourceChanged,
      required this.syncId,
      required this.animeTitle});

  @override
  State<ReadSection> createState() => _WatchSectionState();
}

class _WatchSectionState extends State<ReadSection> {
  final RxList<WrongTitleSearch> wrongTitleSearchData = RxList();
  final RxList<Chapter> filteredList = RxList();
  TextEditingController wrongTitle = TextEditingController();
  final Rx<int> searchNumber = 1.obs;

  @override
  void initState() {
    super.initState();
    filteredList.value = widget.chaptersList;
  }

  Future<void> wrongTitleSearch(String query, BuildContext context) async {
    try {
      final response = await sourceController.activeMangaSource.value!.methods
          .search(query, 1, []);
      if (response.list.isNotEmpty) {
        final data = response.list;
        for (var item in data) {
          wrongTitleSearchData.add(WrongTitleSearch(
              image: item.cover, title: item.title, link: item.url));
        }
      }
    } catch (e) {
      log("Error while searching for wrong title: $e");
    }
  }

  void handleEpisodes(String value) {
    if (value.isNotEmpty) {
      filteredList.value =
          widget.chaptersList.where((i) => i.title!.contains(value)).toList();
    } else {
      filteredList.value = widget.chaptersList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        CustomSourceDropdown(
          items: sourceController.installedMangaExtensions,
          selectedSource: sourceController.activeMangaSource.value,
          sourceController: sourceController,
          labelText: 'Choose Source',
          onChanged: (value) {
            if (value != null) {
              final matched = sourceController.installedMangaExtensions
                  .firstWhere((i) => "${i.name}_${i.extensionType}" == value);
              widget.onSourceChanged();
              sourceController.activeMangaSource.value = matched;
              sourceController.setActiveSource(matched);
              setState(() {});
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        MappedTitle(
            name: "Total Chapters",
            animeTitle: widget.animeTitle,
            totalEpisodes: widget.totalEpisodes),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AzyXText(
              text: "Chapters",
              fontVariant: FontVariant.bold,
              fontSize: 25,
            ),
            AzyXContainer(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary,
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
                  Broken.arrow_3,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  shadows: [
                    BoxShadow(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        blurRadius: 10.blurMultiplier(),
                        spreadRadius: 2.spreadMultiplier())
                  ],
                ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
            onTap: () {
              widget.hasError.value = false;
              wrongTitle.text = widget.animeTitle.value;
              wrongTitleSearch(wrongTitle.text, context);
              wrongTitleSheet(context);
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Wrong Title?",
                style: TextStyle(
                    fontFamily: "Poppins-Bold",
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    decorationThickness: 2,
                    color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.right,
              ),
            )),
        const SizedBox(
          height: 10,
        ),
        SearchBox(
          name: "Search Chapter",
          ontap: () {},
          onChanged: (value) {
            handleEpisodes(value);
          },
        ),
        const SizedBox(
          height: 20,
        ),
        Obx(() => widget.hasError.value
            ? Image.asset(
                'assets/images/sticker.png',
                fit: BoxFit.contain,
              )
            : widget.chaptersList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: filteredList.map((ch) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ReadPage(
                                  syncId: widget.syncId.value,
                                  source: widget.selectedSource.value,
                                  chapterList: widget.chaptersList,
                                  link: ch.link!,
                                  mangaTitle: widget.animeTitle.value);
                            }));
                          },
                          child: ChapterItem(
                            chapter: ch,
                          ));
                    }).toList(),
                  )),
        100.height
      ],
    );
  }

  void wrongTitleSheet(context) {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) {
          return AzyXGradientContainer(
            height: Get.height * 0.9,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Column(
              children: [
                AzyXText(
                  text: widget.selectedSource.value.name!,
                  fontVariant: FontVariant.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onSubmitted: (value) async {
                    widget.hasError.value = false;
                    wrongTitleSearchData.value = [];
                    final data = await sourceController
                        .activeMangaSource.value!.methods
                        .search(value, 1, []);
                    final result = data.list;
                    for (var item in result) {
                      wrongTitleSearchData.add(WrongTitleSearch(
                          image: item.cover,
                          title: item.title,
                          link: item.url));
                    }
                  },
                  controller: wrongTitle,
                  decoration: InputDecoration(
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerLowest,
                    labelText: "Search",
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    prefixIcon: const Icon(Broken.search_normal),
                    prefixIconColor: Theme.of(context).colorScheme.primary,
                    isDense: true,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  () => Expanded(
                    child: widget.hasError.value
                        ? Image.asset(
                            'assets/images/sticker.png',
                            fit: BoxFit.contain,
                          )
                        : wrongTitleSearchData.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : GridView(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.52,
                                        crossAxisSpacing: 1.0),
                                children: wrongTitleSearchData.map((item) {
                                  return GestureDetector(
                                      onTap: () async {
                                        widget.chaptersList.value = [];
                                        Navigator.pop(context);
                                        final data = await sourceController
                                            .activeMangaSource.value!.methods
                                            .getDetail(
                                          DMedia.withUrl(item.link!),
                                        );
                                        widget.onChanged(
                                            data.episodes!.reversed.toList());
                                        widget.onTitleChanged(item.title!);
                                        widget.chaptersList.value =
                                            mChapterToChapter(
                                                data.episodes!, item.title!);
                                      },
                                      child: AzyXCard(
                                        item: item,
                                      ));
                                }).toList()),
                  ),
                )
              ],
            ),
          );
        });
  }
}
