import 'package:azyx/Screens/search/controller/search_controller.dart' as show;
import 'package:azyx/Screens/search/widgets/filter_bottom_sheet.dart';
import 'package:azyx/Screens/search/widgets/gridview_list.dart';
import 'package:azyx/Screens/search/widgets/search_list.dart';
import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class SearchScreen extends StatefulWidget {
  final bool isManga;
  const SearchScreen({super.key, required this.isManga});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late final show.SearchController controller;
  late AnimationController _searchAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _searchBarScale;
  late Animation<double> _fadeAnimation;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  late String title;

  @override
  void initState() {
    super.initState();
    title = widget.isManga ? "Manga" : "Anime";
    controller = Get.put(show.SearchController(isManga: widget.isManga));

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _searchBarScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isSearchFocused = _searchFocusNode.hasFocus;
        });
        if (_searchFocusNode.hasFocus) {
          _searchAnimationController.forward();
        } else {
          _searchAnimationController.reverse();
        }
      }
    });

    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _fadeAnimationController.dispose();
    _searchFocusNode.dispose();
    Get.delete<show.SearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildModernAppBar(context),
              _buildSearchSection(context),
              _buildFilterChips(context), // Add filter chips here
              Expanded(child: _buildSearchResults(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Broken.search_normal,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover $title',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                4.height,
                Text(
                  'Find your next favorite series',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Broken.close_circle,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          AnimatedItemWrapper(
            duration: Duration(milliseconds: 1000),
            child: AnimatedBuilder(
              animation: _searchBarScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _searchBarScale.value,
                  child: _buildModernSearchBar(context),
                );
              },
            ),
          ),
          16.height,
          _buildSearchActions(context),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSearchFocused
              ? colorScheme.primary.withOpacity(0.6)
              : colorScheme.outline.withOpacity(0.2),
          width: _isSearchFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSearchFocused
                ? colorScheme.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isSearchFocused ? 20 : 10,
            offset: const Offset(0, 4),
            spreadRadius: _isSearchFocused ? 2 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSearchFocused ? Ionicons.search : Ionicons.search_outline,
                color: _isSearchFocused
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
                size: 22,
                key: ValueKey(_isSearchFocused),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.textController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search for ${title.toLowerCase()}...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              onSubmitted: (_) => controller.onQuery(),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: controller.textController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.textController.clear();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Ionicons.close,
                        size: 16,
                        color: colorScheme.error,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.onQuery();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Ionicons.arrow_forward,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            return GestureDetector(
              onTap: () {
                showFilterBottomSheet(context, widget.isManga, (v) {
                  controller.updateFilters(v);
                }, initialFilters: controller.activeFilters);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: controller.hasActiveFilters
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.surfaceContainerHigh.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.hasActiveFilters
                        ? colorScheme.primary.withOpacity(0.3)
                        : colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Ionicons.options_outline,
                      size: 18,
                      color: controller.hasActiveFilters
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                    8.width,
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: controller.hasActiveFilters
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (controller.hasActiveFilters) ...[
                      4.width,
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${controller.activeFilterCount.value}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
        16.width,
        Obx(() {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: controller.isGrid.value
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: controller.isGrid.value
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: controller.isGrid.value
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.onListStyleChanged();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      controller.isGrid.value ? Ionicons.grid : Ionicons.list,
                      color: controller.isGrid.value
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                      key: ValueKey(controller.isGrid.value),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (!controller.hasActiveFilters) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Active Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.clearFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Ionicons.close,
                          size: 12,
                          color: colorScheme.error,
                        ),
                        4.width,
                        Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            8.height,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildFilterChipsList(context),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildFilterChipsList(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    List<Widget> chips = [];

    // Format filter
    if (controller.activeFilters['format'] != null) {
      chips.add(
        _buildFilterChip(
          context,
          label: controller.activeFilters['format'].toString().replaceAll(
            '_',
            ' ',
          ),
          onRemove: () => controller.removeFilter('format'),
        ),
      );
    }

    // Status filter
    if (controller.activeFilters['status'] != null) {
      chips.add(
        _buildFilterChip(
          context,
          label: controller.activeFilters['status'].toString().replaceAll(
            '_',
            ' ',
          ),
          onRemove: () => controller.removeFilter('status'),
        ),
      );
    }

    // Season filter (only for anime)
    if (!widget.isManga && controller.activeFilters['season'] != null) {
      String seasonText = controller.activeFilters['season'].toString();
      if (controller.activeFilters['seasonYear'] != null) {
        seasonText += ' ${controller.activeFilters['seasonYear']}';
      }
      chips.add(
        _buildFilterChip(
          context,
          label: seasonText,
          onRemove: () {
            controller.removeFilter('season');
            controller.removeFilter('seasonYear');
          },
        ),
      );
    }

    // Genres filter
    if (controller.activeFilters['genres'] != null &&
        (controller.activeFilters['genres'] as List).isNotEmpty) {
      final genres = controller.activeFilters['genres'] as List;
      for (int i = 0; i < genres.length; i++) {
        chips.add(
          _buildFilterChip(
            context,
            label: genres[i].toString(),
            onRemove: () => controller.removeGenre(genres[i]),
            icon: Icons.category_outlined,
          ),
        );
      }
    }

    // Tags filter
    if (controller.activeFilters['tags'] != null &&
        (controller.activeFilters['tags'] as List).isNotEmpty) {
      final tags = controller.activeFilters['tags'] as List;
      for (int i = 0; i < tags.length; i++) {
        chips.add(
          _buildFilterChip(
            context,
            label: tags[i].toString(),
            onRemove: () => controller.removeTag(tags[i]),
            icon: Icons.tag,
          ),
        );
      }
    }

    return chips;
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required VoidCallback onRemove,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: colorScheme.primary),
                  4.width,
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                6.width,
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.close,
                    size: 10,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState(context);
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState(context);
          }

          if (controller.searchItemList.isEmpty) {
            return _buildEmptyState(context);
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: controller.isGrid.value
                ? GridviewList(
                    data: controller.searchItemList,
                    isManga: widget.isManga,
                    key: const ValueKey('grid'),
                  )
                : SearchList(
                    isManga: widget.isManga,
                    data: controller.searchItemList,
                    key: const ValueKey('list'),
                  ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          24.height,
          Text(
            'Searching ${title.toLowerCase()}...',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.warning_outline,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            24.height,
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            12.height,
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            24.height,
            ElevatedButton.icon(
              onPressed: () => controller.onQuery(),
              icon: const Icon(Ionicons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.search_outline,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            32.height,
            Text(
              'No ${title.toLowerCase()} found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            12.height,
            Text(
              'Try searching with different keywords or check your spelling',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
