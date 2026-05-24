import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/episode_class.dart';
import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_normal_card.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/anime/anify_episodes_list.dart';
import 'package:azyx/Widgets/anime/episodes_list.dart';
import 'package:azyx/Widgets/anime/mapped_title.dart';
import 'package:azyx/Widgets/common/search_widget.dart';
import 'package:azyx/Widgets/custom_drop_down.dart';
import 'package:anymex_extension_runtime_bridge/ExtensionManager.dart';
import 'package:anymex_extension_runtime_bridge/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class WatchSection extends StatefulWidget {
  final String image;
  final String id;
  final AnilistMediaData mediaData;
  final RxList<Source> installedExtensions;
  final Rx<String> animeTitle;
  final Rx<String> totalEpisodes;
  final RxList<Episode> episodelist;
  final Rx<bool> hasError;
  final Function(String link) onChanged;
  final Function(String) onTitleChanged;
  final Function(String) onSourceChanged;

  const WatchSection({
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
  final Rx<bool> searchError = false.obs;
  
  final RxString selectedSeason = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString episodeSearchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _initFilters();
    _applyFilters();
    ever(widget.episodelist, (_) {
      _initFilters();
      _applyFilters();
    });
  }

  void _initFilters() {
    final availableSeasons = getAvailableSeasons();
    if (availableSeasons.isNotEmpty && !availableSeasons.contains(selectedSeason.value)) {
      selectedSeason.value = availableSeasons.first;
    }

    final availableTypes = getAvailableTypes();
    if (availableTypes.isNotEmpty && !availableTypes.contains(selectedType.value)) {
      if (availableTypes.any((t) => t.toLowerCase() == 'subbed')) {
        selectedType.value = availableTypes.firstWhere((t) => t.toLowerCase() == 'subbed');
      } else {
        selectedType.value = availableTypes.first;
      }
    }
  }

  List<String> getAvailableSeasons() {
    final seasons = widget.episodelist
        .map((e) => e.season)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    seasons.sort((a, b) {
      final intA = int.tryParse(a) ?? 0;
      final intB = int.tryParse(b) ?? 0;
      return intA.compareTo(intB);
    });
    return seasons;
  }

  List<String> getAvailableTypes() {
    final types = widget.episodelist
        .map((e) => e.type)
        .where((t) => t != null && t.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    types.sort();
    return types;
  }

  void _applyFilters() {
    final query = episodeSearchQuery.value.toLowerCase();
    
    var temp = widget.episodelist.where((episode) {
      if (query.isNotEmpty) {
        final titleMatch = episode.title?.toLowerCase().contains(query) ?? false;
        final numMatch = episode.number.toLowerCase().contains(query);
        if (!titleMatch && !numMatch) return false;
      }
      
      if (selectedSeason.value.isNotEmpty) {
        final epSeason = episode.season ?? '1';
        if (epSeason != selectedSeason.value) return false;
      }
      
      if (selectedType.value.isNotEmpty) {
        final epType = episode.type ?? 'Subbed';
        if (epType.toLowerCase() != selectedType.value.toLowerCase()) return false;
      }
      
      return true;
    }).toList();
    
    temp.sort((a, b) {
      final numA = double.tryParse(a.number);
      final numB = double.tryParse(b.number);
      if (numA != null && numB != null) {
        return numA.compareTo(numB);
      }
      if (numA != null) return -1;
      if (numB != null) return 1;
      return (a.title ?? '').compareTo(b.title ?? '');
    });

    filteredList.value = temp;
  }

  Future<void> wrongTitleSearch(String query, BuildContext context) async {
    try {
      final response = await sourceController.activeSource.value!.methods
          .search(query, 1, []);
      if (response.list.isNotEmpty) {
        for (var item in response.list) {
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
    }
  }

  void handleEpisodes(String value) {
    episodeSearchQuery.value = value;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Obx(
          () => CustomSourceDropdown(
            items: sourceController.installedExtensions,
            sourceController: sourceController,
            selectedSource:
                sourceController.activeSource.value ??
                sourceController.installedExtensions.first,
            labelText: 'Source',
            onChanged: (value) {
              if (value != null) {
                final matched = sourceController.installedExtensions.firstWhere(
                  (i) => "${i.name}_${i.extensionType}" == value,
                );
                widget.onSourceChanged(value);
                sourceController.setActiveSource(matched);
              }
            },
          ),
        ),
        const SizedBox(height: 18),
        MappedTitle(
          name: "Episode Count",
          animeTitle: widget.animeTitle,
          totalEpisodes: widget.totalEpisodes,
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                "Episodes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                searchError.value = false;
                wrongTitleSearchData.value = [];
                wrongTitle.text = widget.animeTitle.value;
                wrongTitleSearch(wrongTitle.text, context);
                _showWrongTitleSheet(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.12),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Wrong title?",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SearchBox(
          onChanged: handleEpisodes,
          ontap: () {},
          name: "Filter episodes...",
        ),
        const SizedBox(height: 16),
        Obx(() => _buildFilterChips(colorScheme)),
        const SizedBox(height: 4),
        Obx(
          () => widget.hasError.value
              ? _buildErrorState(colorScheme)
              : widget.episodelist.isEmpty
              ? _buildLoadingState(colorScheme)
              : filteredList.isEmpty
              ? _buildEmptyState(colorScheme)
              : filteredList.first.desc.isNotEmpty
              ? AnifyEpisodesWidget(
                  title: widget.animeTitle.value,
                  id: widget.id,
                  image: widget.image,
                  data: widget.mediaData,
                  anifyEpisodes: filteredList,
                )
              : EpisodesList(
                  episodeList: filteredList,
                  image: widget.image,
                  title: widget.animeTitle.value,
                  id: widget.id,
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    final seasons = getAvailableSeasons();
    final types = getAvailableTypes();

    if (seasons.isEmpty && types.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (seasons.isNotEmpty) ...[
          Text(
            "Seasons",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: seasons.map((season) {
                final isSelected = selectedSeason.value == season;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text("Season $season"),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        selectedSeason.value = season;
                        _applyFilters();
                      }
                    },
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (types.isNotEmpty) ...[
          Text(
            "Type",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: types.map((type) {
                final isSelected = selectedType.value == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        selectedType.value = type;
                        _applyFilters();
                      }
                    },
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 10),
            Text(
              "No episodes match your filters",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.error.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              "Failed to load episodes",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Try changing the source or title",
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onErrorContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: LoadingIndicatorM3E(color: colorScheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              "Fetching episodes...",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWrongTitleSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Search Title",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(
                      0.45,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: wrongTitle,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        EvaIcons.search,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        size: 20,
                      ),
                      hintText: "Search title...",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (val) {
                      searchError.value = false;
                      wrongTitleSearchData.value = [];
                      wrongTitleSearch(val, context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => wrongTitleSearchData.isEmpty
                      ? Center(
                          child: searchError.value
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 40,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "No results found",
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: LoadingIndicatorM3E(color: colorScheme.primary),
                                ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.52,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: wrongTitleSearchData.length,
                          itemBuilder: (ctx, index) {
                            final item = wrongTitleSearchData[index];
                            return GestureDetector(
                              onTap: () {
                                widget.episodelist.value = [];
                                Navigator.pop(context);
                                widget.onChanged(item.link!);
                                widget.onTitleChanged(item.title!);
                              },
                              child: AzyXCard(item: item),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
