// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:developer';

import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Screens/Anime/Details/tabs/floater.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anify_episodes_list.dart';
import 'package:azyx/Widgets/anime/episodes_list.dart';
import 'package:azyx/Widgets/anime/mapped_title.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_normal_card.dart';
import 'package:azyx/Widgets/common/search_widget.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/api/Mangayomi/Search/search.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchSection extends StatefulWidget {
  final String image;
  final int id;
  final Rx<Source> selectedSource;
  final AnilistMediaData mediaData;
  final RxList<Source> installedExtensions;
  final Rx<String> animeTitle;
  final Rx<String> totalEpisodes;
  final RxList<Episode> episodelist;
  final Rx<bool> hasError;
  Function(String link) onChanged;
  Function(String) onTitleChanged;
  Function(Source) onSourceChanged;

  WatchSection(
      {super.key,
      required this.id,
      required this.image,
      required this.installedExtensions,
      required this.totalEpisodes,
      required this.selectedSource,
      required this.episodelist,
      required this.hasError,
      required this.onChanged,
      required this.onTitleChanged,
      required this.onSourceChanged,
      required this.mediaData,
      required this.animeTitle});

  @override
  State<WatchSection> createState() => _WatchSectionState();
}

class _WatchSectionState extends State<WatchSection> {
  final RxList<WrongTitleSearch> wrongTitleSearchData = RxList();
  final RxList<Episode> filteredList = RxList();
  TextEditingController wrongTitle = TextEditingController();
  final Rx<int> searchNumber = 1.obs;
  final Rx<bool> searchError = false.obs;

  @override
  void initState() {
    super.initState();
    filteredList.value = widget.episodelist;
  }

  Future<void> wrongTitleSearch(String query, BuildContext context) async {
    try {
      final response = await search(
          source: widget.selectedSource.value,
          query: query,
          page: 1,
          filterList: []);
      if (response != null) {
        final data = response.toJson()['list'];
        for (var item in data) {
          wrongTitleSearchData.add(WrongTitleSearch.fromJson(item));
        }
      } else {
        searchError.value = true;
        azyxSnackBar("Something went wrong");
      }
    } catch (e) {
      searchError.value = true;
      azyxSnackBar("Something went wrong");
      log("Error while searching for wrong title: $e");
    }
  }

  void handleEpisodes(String value) {
    if (value.isNotEmpty) {
      filteredList.value =
          widget.episodelist.where((i) => i.title!.contains(value)).toList();
    } else {
      filteredList.value = widget.episodelist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(15),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            DropdownButtonFormField(
                value: widget.selectedSource.value,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Choose Source',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryFixedVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                items: widget.installedExtensions.map((item) {
                  return DropdownMenuItem<Source>(
                      value: item, child: AzyXText(text: item.name!));
                }).toList(),
                onChanged: (value) {
                  widget.onSourceChanged(value!);
                }),
            const SizedBox(
              height: 20,
            ),
            MappedTitle(
                name: "Total Episodes",
                animeTitle: widget.animeTitle,
                totalEpisodes: widget.totalEpisodes),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AzyXText(
                  text: "Episodes",
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
                      Broken.image,
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
                  wrongTitleSearchData.value = [];
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
              ontap: (value) {
                handleEpisodes(value);
              },
              name: "Search Episodes",
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() => widget.hasError.value
                ? Image.asset('assets/images/sticker.png', fit: BoxFit.contain)
                : widget.episodelist.isEmpty
                    ? AzyXContainer(
                        height: Get.height * 0.5,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      )
                    : widget.episodelist.first.desc.isEmpty
                        ? EpisodesList(
                            episodeList: widget.episodelist,
                            image: widget.image,
                            selectedSource: widget.selectedSource.value,
                            title: widget.animeTitle.value,
                            id: widget.id,
                          )
                        : AnifyEpisodesWidget(
                            data: widget.mediaData,
                            id: widget.id,
                            title: widget.animeTitle.value,
                            anifyEpisodes: widget.episodelist,
                            selectedSource: widget.selectedSource.value,
                            image: widget.image,
                          )),
          ],
        ),
        FloaterWidget(
          title: widget.animeTitle.value,
          icon: Icons.movie_filter,
          name: "Watch",
        )
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
            height: Get.height * 0.7,
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
                    searchError.value = false;
                    wrongTitleSearchData.value = [];
                    wrongTitleSearch(value, context);
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
                    child: searchError.value
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
                                        widget.episodelist.value = [];
                                        Navigator.pop(context);
                                        widget.onChanged(item.link!);
                                        widget.onTitleChanged(item.title!);
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
