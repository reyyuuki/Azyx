import 'package:azyx/Controllers/anilist_data_controller.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final RxList<Anime> searchItemList = RxList();
  final TextEditingController textController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isGrid = true.obs;
  final bool isManga;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{}.obs;
  final RxInt activeFilterCount = 0.obs;

  SearchController({required this.isManga});

  @override
  void onClose() {
    textController.dispose();
    super.dispose();
  }

  void onListStyleChanged() {
    isGrid.value = !isGrid.value;
  }

  void updateFilters(Map<String, dynamic> filters) {
    activeFilters.value = filters;
    _updateFilterCount();
    onQuery();
  }

  void _updateFilterCount() {
    int count = 0;

    if (activeFilters['format'] != null) count++;
    if (activeFilters['status'] != null) count++;
    if (activeFilters['season'] != null) count++;
    if (activeFilters['seasonYear'] != null) count++;
    if (activeFilters['genres'] != null &&
        (activeFilters['genres'] as List).isNotEmpty) {
      count++;
    }
    if (activeFilters['tags'] != null &&
        (activeFilters['tags'] as List).isNotEmpty) {
      count++;
    }

    activeFilterCount.value = count;
  }

  void clearFilters() {
    activeFilters.clear();
    activeFilterCount.value = 0;
    if (textController.text.trim().isNotEmpty) {
      onQuery();
    }
  }

  void removeFilter(String filterKey) {
    activeFilters.remove(filterKey);
    _updateFilterCount();
    onQuery();
  }

  // Method to remove individual genre
  void removeGenre(String genre) {
    if (activeFilters['genres'] != null) {
      List<String> genres = List<String>.from(activeFilters['genres']);
      genres.remove(genre);

      if (genres.isEmpty) {
        activeFilters.remove('genres');
      } else {
        activeFilters['genres'] = genres;
      }

      _updateFilterCount();
      onQuery();
    }
  }

  // Method to remove individual tag
  void removeTag(String tag) {
    if (activeFilters['tags'] != null) {
      List<String> tags = List<String>.from(activeFilters['tags']);
      tags.remove(tag);

      if (tags.isEmpty) {
        activeFilters.remove('tags');
      } else {
        activeFilters['tags'] = tags;
      }

      _updateFilterCount();
      onQuery();
    }
  }

  Future<void> onQuery() async {
    final query = textController.text.trim();

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = isManga
          ? await anilistDataController.searchAnilistManga(
              query: query,
              format: activeFilters['format'],
              status: activeFilters['status'],
              genres: activeFilters['genres'] != null
                  ? List<String>.from(activeFilters['genres'])
                  : null,
              tags: activeFilters['tags'] != null
                  ? List<String>.from(activeFilters['tags'])
                  : null,
              sort: activeFilters['sort'] != null
                  ? List<String>.from(activeFilters['sort'])
                  : ['POPULARITY_DESC'],
            )
          : await anilistDataController.searchAnilistAnime(
              query: query,
              format: activeFilters['format'],
              status: activeFilters['status'],
              season: activeFilters['season'],
              seasonYear: activeFilters['seasonYear'],
              genres: activeFilters['genres'] != null
                  ? List<String>.from(activeFilters['genres'])
                  : null,
              tags: activeFilters['tags'] != null
                  ? List<String>.from(activeFilters['tags'])
                  : null,
              sort: activeFilters['sort'] != null
                  ? List<String>.from(activeFilters['sort'])
                  : ['POPULARITY_DESC'],
            );

      searchItemList.value = data;

      if (data.isNotEmpty) {
        Utils.log('Search completed: ${data.length} results found');
        Utils.log('First result: ${searchItemList.first.title!}');
      } else {
        Utils.log('No results found for query: $query');
      }
    } catch (e) {
      errorMessage.value =
          'Error searching ${isManga ? 'manga' : 'anime'}: ${e.toString()}';
      Utils.log('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    textController.clear();
    searchItemList.clear();
    errorMessage.value = '';
  }

  String getFilterDisplayText() {
    if (activeFilterCount.value == 0) return '';

    List<String> filterTexts = [];

    if (activeFilters['format'] != null) {
      filterTexts.add(activeFilters['format'].toString().replaceAll('_', ' '));
    }

    if (activeFilters['status'] != null) {
      filterTexts.add(activeFilters['status'].toString().replaceAll('_', ' '));
    }

    if (activeFilters['season'] != null) {
      String seasonText = activeFilters['season'].toString();
      if (activeFilters['seasonYear'] != null) {
        seasonText += ' ${activeFilters['seasonYear']}';
      }
      filterTexts.add(seasonText);
    }

    if (activeFilters['genres'] != null &&
        (activeFilters['genres'] as List).isNotEmpty) {
      final genres = activeFilters['genres'] as List;
      if (genres.length == 1) {
        filterTexts.add(genres.first);
      } else {
        filterTexts.add('${genres.length} Genres');
      }
    }

    if (activeFilters['tags'] != null &&
        (activeFilters['tags'] as List).isNotEmpty) {
      final tags = activeFilters['tags'] as List;
      if (tags.length == 1) {
        filterTexts.add(tags.first);
      } else {
        filterTexts.add('${tags.length} Tags');
      }
    }

    if (filterTexts.isEmpty) return '';
    if (filterTexts.length == 1) return filterTexts.first;
    if (filterTexts.length <= 3) return filterTexts.join(', ');

    return '${filterTexts.take(2).join(', ')} +${filterTexts.length - 2} more';
  }

  // Helper method to check if filters are active
  bool get hasActiveFilters => activeFilterCount.value > 0;

  // Helper method to get sort display name
  String get currentSortDisplayName {
    final sortOptions = {
      'POPULARITY_DESC': 'Most Popular',
      'SCORE_DESC': 'Highest Rated',
      'TRENDING_DESC': 'Trending',
      'START_DATE_DESC': 'Newest',
      'START_DATE': 'Oldest',
      'TITLE_ROMAJI': 'A-Z',
      'TITLE_ROMAJI_DESC': 'Z-A',
      'FAVOURITES_DESC': 'Most Favorited',
      'UPDATED_AT_DESC': 'Recently Updated',
    };

    final currentSort = activeFilters['sort'] != null
        ? (activeFilters['sort'] as List).first
        : 'POPULARITY_DESC';

    return sortOptions[currentSort] ?? 'Most Popular';
  }

  void reset() {
    clearSearch();
    clearFilters();
  }
}
