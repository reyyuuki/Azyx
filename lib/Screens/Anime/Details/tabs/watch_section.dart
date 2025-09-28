// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:developer';

import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/episode_class.dart';
import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/anime/anify_episodes_list.dart';
import 'package:azyx/Widgets/anime/episodes_list.dart';
import 'package:azyx/Widgets/anime/mapped_title.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_normal_card.dart';
import 'package:azyx/Widgets/common/search_widget.dart';
import 'package:azyx/Widgets/custom_drop_down.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchSection extends StatefulWidget {
  final String image;
  final String id;
  final AnilistMediaData mediaData;
  final RxList<Source> installedExtensions;
  final Rx<String> animeTitle;
  final Rx<String> totalEpisodes;
  final RxList<Episode> episodelist;
  final Rx<bool> hasError;
  Function(String link) onChanged;
  Function(String) onTitleChanged;
  Function(String) onSourceChanged;

  WatchSection({
    super.key,
    required this.id,
    required this.image,
    required this.installedExtensions,
    required this.totalEpisodes,
    required this.episodelist,
    required this.hasError,
    required this.onChanged,
    required this.onTitleChanged,
    required this.onSourceChanged,
    required this.mediaData,
    required this.animeTitle,
  });

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
      final response = await sourceController.activeSource.value!.methods
          .search(query, 1, []);
      if (response.list.isNotEmpty) {
        final data = response.list;
        for (var item in data) {
          wrongTitleSearchData.add(
            WrongTitleSearch(
              image: item.cover,
              title: item.title,
              link: item.url,
            ),
          );
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
      filteredList.value = widget.episodelist
          .where((i) => i.title!.contains(value))
          .toList();
    } else {
      filteredList.value = widget.episodelist;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            Obx(
              () => CustomSourceDropdown(
                items: sourceController.installedExtensions,
                sourceController: sourceController,
                selectedSource:
                    sourceController.activeSource.value ??
                    sourceController.installedExtensions.first,
                labelText: 'Choose Source',
                onChanged: (value) {
                  if (value != null) {
                    final matched = sourceController.installedExtensions
                        .firstWhere(
                          (i) => "${i.name}_${i.extensionType}" == value,
                        );
                    widget.onSourceChanged(value);
                    sourceController.activeSource.value = matched;
                    sourceController.setActiveSource(matched);
                    log(
                      'current: ${sourceController.activeSource.value?.name}',
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.04),
                          Colors.white.withOpacity(0.08),
                        ]
                      : [Colors.white, Colors.white],
                ),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: MappedTitle(
                name: "Total Episodes",
                animeTitle: widget.animeTitle,
                totalEpisodes: widget.totalEpisodes,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.04),
                          Colors.white.withOpacity(0.08),
                        ]
                      : [Colors.white, Colors.white],
                ),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AzyXText(
                    text: "Episodes",
                    fontVariant: FontVariant.bold,
                    fontSize: 24,
                    textAlign: TextAlign.start,
                  ),
                  GestureDetector(
                    onTap: () {
                      searchError.value = false;
                      wrongTitleSearchData.value = [];
                      wrongTitle.text = widget.animeTitle.value;
                      wrongTitleSearch(wrongTitle.text, context);
                      wrongTitleSheet(context);
                    },
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "Wrong Title?",
                          style: TextStyle(
                            fontFamily: "Poppins-Bold",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SearchBox(
              onChanged: (value) {
                handleEpisodes(value);
              },
              ontap: () {},
              name: "Search Episodes",
            ),
            const SizedBox(height: 24),
            Obx(
              () => widget.hasError.value
                  ? Container(
                      height: 300,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.03),
                            Colors.white.withOpacity(0.06),
                          ],
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/sticker.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : widget.episodelist.isEmpty
                  ? Container(
                      height: Get.height * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.03),
                            Colors.white.withOpacity(0.06),
                          ],
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : widget.episodelist.first.desc.isNotEmpty
                  ? AnifyEpisodesWidget(
                      title: widget.animeTitle.value,
                      id: widget.id,
                      image: widget.image,
                      data: widget.mediaData,
                      anifyEpisodes: widget.episodelist,
                    )
                  : EpisodesList(
                      episodeList: widget.episodelist,
                      image: widget.image,
                      title: widget.animeTitle.value,
                      id: widget.id,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  void wrongTitleSheet(context) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          height: Get.height * 0.75,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
                Theme.of(context).colorScheme.surface.withOpacity(0.98),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: -10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: AzyXText(
                          text: sourceController.activeSource.value?.name ?? '',
                          fontVariant: FontVariant.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          onSubmitted: (value) async {
                            searchError.value = false;
                            wrongTitleSearchData.value = [];
                            wrongTitleSearch(value, context);
                          },
                          controller: wrongTitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: "Search",
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.8),
                            ),
                            prefixIcon: Icon(
                              Broken.search_normal,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.8),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => searchError.value
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                child: Image.asset(
                                  'assets/images/sticker.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : wrongTitleSearchData.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.52,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                  ),
                              children: wrongTitleSearchData.map((item) {
                                return GestureDetector(
                                  onTap: () async {
                                    widget.episodelist.value = [];
                                    Navigator.pop(context);
                                    widget.onChanged(item.link!);
                                    widget.onTitleChanged(item.title!);
                                  },
                                  child: AzyXCard(item: item),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
