import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

class FilterBottomSheet extends StatefulWidget {
  final bool isManga;
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic>? initialFilters;

  const FilterBottomSheet({
    super.key,
    required this.isManga,
    required this.onApplyFilters,
    this.initialFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with TickerProviderStateMixin {
  String? selectedFormat;
  String? selectedStatus;
  String? selectedSeason;
  int? selectedSeasonYear;
  List<String> selectedGenres = [];
  List<String> selectedTags = [];
  String selectedSort = 'POPULARITY_DESC';

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // AniList compatible formats
  final List<String> animeFormats = [
    'TV',
    'TV_SHORT',
    'MOVIE',
    'SPECIAL',
    'OVA',
    'ONA',
    'MUSIC'
  ];

  final List<String> mangaFormats = ['MANGA', 'LIGHT_NOVEL', 'ONE_SHOT'];

  final List<String> statusOptions = [
    'FINISHED',
    'RELEASING',
    'NOT_YET_RELEASED',
    'CANCELLED',
    'HIATUS'
  ];

  final List<String> seasonOptions = ['WINTER', 'SPRING', 'SUMMER', 'FALL'];

  final Map<String, String> sortOptions = {
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

  final List<String> commonGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Ecchi',
    'Fantasy',
    'Horror',
    'Mahou Shoujo',
    'Mecha',
    'Music',
    'Mystery',
    'Psychological',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Thriller'
  ];

  final List<String> commonTags = [
    'School',
    'Demons',
    'Magic',
    'Military',
    'Police',
    'Vampires',
    'Aliens',
    'Animals',
    'Cooking',
    'Dancing',
    'Delinquents',
    'Dragons',
    'Friendship',
    'Ghosts',
    'Gods',
    'Guns',
    'Harem',
    'Historical',
    'Idols',
    'Kaiju',
    'Martial Arts',
    'Ninja',
    'Pirates',
    'Robots',
    'Samurai',
    'Space',
    'Time Travel',
    'Tragedy',
    'War',
    'Zombies'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _setupAnimations();
  }

  void _initializeFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;
      selectedFormat = filters['format'];
      selectedStatus = filters['status'];
      selectedSeason = filters['season'];
      selectedSeasonYear = filters['seasonYear'];
      selectedGenres = List<String>.from(filters['genres'] ?? []);
      selectedTags = List<String>.from(filters['tags'] ?? []);
      selectedSort = filters['sort']?.first ?? 'POPULARITY_DESC';
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, screenHeight * _slideAnimation.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: screenHeight * 0.9,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAnimatedSection(_buildSortSection(context), 0),
                          _buildAnimatedSection(
                              _buildFormatSection(context), 1),
                          _buildAnimatedSection(
                              _buildStatusSection(context), 2),
                          if (!widget.isManga)
                            _buildAnimatedSection(
                                _buildSeasonSection(context), 3),
                          _buildAnimatedSection(
                              _buildGenresSection(context), 4),
                          _buildAnimatedSection(_buildTagsSection(context), 5),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSection(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: child,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.secondary.withOpacity(0.04),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Ionicons.options,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.isManga ? 'Manga' : 'Anime'} Filters',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Refine your search results',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Ionicons.close,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sort By', Ionicons.funnel),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedSort,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            items: sortOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSort = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSection(BuildContext context) {
    final formats = widget.isManga ? mangaFormats : animeFormats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Format', Ionicons.film),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: formats.map((format) {
            final isSelected = selectedFormat == format;
            return _buildSelectableChip(
              format.replaceAll('_', ' '),
              isSelected,
              () {
                setState(() {
                  selectedFormat = isSelected ? null : format;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status', Ionicons.radio_button_on),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: statusOptions.map((status) {
            final isSelected = selectedStatus == status;
            return _buildSelectableChip(
              status.replaceAll('_', ' '),
              isSelected,
              () {
                setState(() {
                  selectedStatus = isSelected ? null : status;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeasonSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Season & Year', Ionicons.calendar),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedSeason,
                  hint: Text(
                    'Season',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  items: seasonOptions.map((season) {
                    return DropdownMenuItem(
                      value: season,
                      child: Text(season),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSeason = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Year',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    selectedSeasonYear = int.tryParse(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenresSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Genres', Ionicons.library),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonGenres.map((genre) {
            final isSelected = selectedGenres.contains(genre);
            return _buildSelectableChip(
              genre,
              isSelected,
              () {
                setState(() {
                  if (isSelected) {
                    selectedGenres.remove(genre);
                  } else {
                    selectedGenres.add(genre);
                  }
                });
              },
              isSmall: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tags', Ionicons.pricetag),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return _buildSelectableChip(
              tag,
              isSelected,
              () {
                setState(() {
                  if (isSelected) {
                    selectedTags.remove(tag);
                  } else {
                    selectedTags.add(tag);
                  }
                });
              },
              isSmall: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectableChip(String label, bool isSelected, VoidCallback onTap,
      {bool isSmall = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: isSmall ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Ionicons.refresh_outline,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Clear All',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ionicons.checkmark_circle,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      selectedFormat = null;
      selectedStatus = null;
      selectedSeason = null;
      selectedSeasonYear = null;
      selectedGenres.clear();
      selectedTags.clear();
      selectedSort = 'POPULARITY_DESC';
    });
  }

  void _applyFilters() {
    HapticFeedback.lightImpact();

    final filters = <String, dynamic>{
      'sort': [selectedSort],
      if (selectedFormat != null) 'format': selectedFormat,
      if (selectedStatus != null) 'status': selectedStatus,
      if (selectedSeason != null) 'season': selectedSeason,
      if (selectedSeasonYear != null) 'seasonYear': selectedSeasonYear,
      if (selectedGenres.isNotEmpty) 'genres': selectedGenres,
      if (selectedTags.isNotEmpty) 'tags': selectedTags,
    };

    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}

void showFilterBottomSheet(
  BuildContext context,
  bool isManga,
  Function(Map<String, dynamic>) onApplyFilters, {
  Map<String, dynamic>? initialFilters,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FilterBottomSheet(
        isManga: isManga,
        onApplyFilters: onApplyFilters,
        initialFilters: initialFilters,
      );
    },
  );
}
