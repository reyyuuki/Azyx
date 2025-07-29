// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:math' as math;

import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorProfileManager {
  static const Map<String, Map<String, int>> profiles = {
    "cinema": {
      "brightness": 5,
      "contrast": 15,
      "saturation": 10,
      "gamma": 8,
      "hue": 0,
    },
    "cinema_dark": {
      "brightness": -8,
      "contrast": 20,
      "saturation": 12,
      "gamma": 15,
      "hue": 0,
    },
    "cinema_hdr": {
      "brightness": 3,
      "contrast": 25,
      "saturation": 8,
      "gamma": 5,
      "hue": -2,
    },
    "anime": {
      "brightness": 8,
      "contrast": 25,
      "saturation": 35,
      "gamma": -5,
      "hue": 2,
    },
    "anime_vibrant": {
      "brightness": 12,
      "contrast": 30,
      "saturation": 45,
      "gamma": -8,
      "hue": 5,
    },
    "anime_soft": {
      "brightness": 6,
      "contrast": 18,
      "saturation": 28,
      "gamma": -2,
      "hue": 1,
    },
    "vivid": {
      "brightness": 12,
      "contrast": 30,
      "saturation": 40,
      "gamma": 5,
      "hue": 0,
    },
    "vivid_pop": {
      "brightness": 15,
      "contrast": 35,
      "saturation": 50,
      "gamma": 8,
      "hue": 3,
    },
    "vivid_warm": {
      "brightness": 10,
      "contrast": 28,
      "saturation": 38,
      "gamma": 3,
      "hue": 12,
    },
    "natural": {
      "brightness": 0,
      "contrast": 0,
      "saturation": 0,
      "gamma": 0,
      "hue": 0,
    },
    "dark": {
      "brightness": -15,
      "contrast": 10,
      "saturation": -5,
      "gamma": 12,
      "hue": 0,
    },
    "warm": {
      "brightness": 5,
      "contrast": 8,
      "saturation": 12,
      "gamma": 3,
      "hue": 8,
    },
    "cool": {
      "brightness": 2,
      "contrast": 5,
      "saturation": 8,
      "gamma": 0,
      "hue": -8,
    },
    "grayscale": {
      "brightness": 0,
      "contrast": 15,
      "saturation": -100,
      "gamma": 5,
      "hue": 0,
    },
  };

  static const Map<String, String> profileDescriptions = {
    "cinema": "Balanced colors for movie watching",
    "cinema_dark": "Optimized for dark room cinema viewing",
    "cinema_hdr": "Enhanced cinema with HDR-like contrast",
    "anime": "Enhanced colors perfect for animation",
    "anime_vibrant": "Maximum saturation for colorful anime",
    "anime_soft": "Gentle enhancement for pastel anime",
    "vivid": "Bright and punchy colors",
    "vivid_pop": "Maximum vibrancy for eye-catching content",
    "vivid_warm": "Vivid colors with warm temperature",
    "natural": "Default balanced settings",
    "dark": "Optimized for dark environments",
    "warm": "Warmer tones for comfort viewing",
    "cool": "Cooler tones for clarity",
    "grayscale": "Black and white viewing",
  };

  static const Map<String, IconData> profileIcons = {
    "cinema": Icons.movie,
    "cinema_dark": Icons.movie_outlined,
    "cinema_hdr": Icons.hd,
    "anime": Icons.animation,
    "anime_vibrant": Icons.color_lens,
    "anime_soft": Icons.blur_on,
    "vivid": Icons.palette,
    "vivid_pop": Icons.auto_awesome,
    "vivid_warm": Icons.wb_sunny,
    "natural": Icons.nature,
    "dark": Icons.dark_mode,
    "warm": Icons.wb_sunny,
    "cool": Icons.ac_unit,
    "grayscale": Icons.gradient,
  };

  Future<void> applyColorProfile(String profile, dynamic player) async {
    final settings = profiles[profile.toLowerCase()];
    if (settings != null && player.platform != null) {
      try {
        for (final entry in settings.entries) {
          await (player.platform as dynamic)
              .setProperty(entry.key, entry.value.toString());
          Utils.log('Applied ${entry.key}: ${entry.value}');
        }
      } catch (e) {
        Utils.log('Error applying color profile: $e');
      }
    }
  }

  Future<void> applyCustomSettings(
      Map<String, int> customSettings, dynamic player) async {
    if (player.platform != null) {
      try {
        for (final entry in customSettings.entries) {
          await (player.platform as dynamic)
              .setProperty(entry.key, entry.value.toString());
        }
      } catch (e) {
        Utils.log('Error applying custom settings: $e');
      }
    }
  }
}

class ColorProfileBottomSheet extends StatefulWidget {
  final String currentProfile;
  final Function(String) onProfileSelected;
  final Function(Map<String, int>) onCustomSettingsChanged;
  final dynamic player;

  const ColorProfileBottomSheet({
    super.key,
    required this.currentProfile,
    required this.onProfileSelected,
    required this.onCustomSettingsChanged,
    required this.player,
  });

  @override
  State<ColorProfileBottomSheet> createState() =>
      _ColorProfileBottomSheetState();
}

class _ColorProfileBottomSheetState extends State<ColorProfileBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _slideController;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;
  PageController _pageController = PageController();
  String _selectedProfile = '';
  Map<String, int> _customSettings = {
    "brightness": 0,
    "contrast": 0,
    "saturation": 0,
    "gamma": 0,
    "hue": 0,
  };

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _selectedProfile = widget.currentProfile;
    _customSettings = Map.from(ColorProfileManager.profiles['natural']!);

    _backgroundController.repeat();
    _slideController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showProfileAppliedFeedback(String profileName) {
    HapticFeedback.lightImpact();
    log('Applied ${profileName.toUpperCase()} profile');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: size.height * 0.95,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
              theme.colorScheme.surfaceVariant.withOpacity(0.8),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: Stack(
            children: [
              // Animated background
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.05),
                          theme.colorScheme.secondary.withOpacity(0.03),
                          theme.colorScheme.tertiary.withOpacity(0.02),
                        ],
                        stops: [
                          0.0,
                          0.5 +
                              0.3 *
                                  math.sin(
                                      _backgroundAnimation.value * 2 * math.pi),
                          1.0,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Main content
              Column(
                children: [
                  // Floating header
                  _buildFloatingHeader(theme),

                  // Page indicator dots
                  _buildPageIndicators(theme),

                  // Content pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildPresetsPage(theme),
                        _buildCustomPage(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundAnimation.value * 2 * math.pi,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 20),

          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Color Studio',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Craft your perfect viewing experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIndicatorDot(0, 'Presets', Icons.collections_rounded, theme),
          const SizedBox(width: 40),
          _buildIndicatorDot(1, 'Custom', Icons.tune_rounded, theme),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot(
      int index, String label, IconData icon, ThemeData theme) {
    final isActive = _currentPage == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                )
              : null,
          color: isActive
              ? null
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsPage(ThemeData theme) {
    Map<String, List<String>> groupedProfiles = {
      'Cinema': ['cinema', 'cinema_dark', 'cinema_hdr'],
      'Anime': ['anime', 'anime_vibrant', 'anime_soft'],
      'Vivid': ['vivid', 'vivid_pop', 'vivid_warm'],
      'Essential': ['natural', 'dark', 'warm', 'cool', 'grayscale'],
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ...groupedProfiles.entries.map((category) {
          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 15),
                  child: Text(
                    category.key,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                  ),
                ),

                // Horizontal scrollable profiles
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category.value.length,
                    itemBuilder: (context, index) {
                      final profileKey = category.value[index];
                      final isSelected = _selectedProfile == profileKey;

                      return _buildProfileCard(profileKey, isSelected, theme);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileCard(
      String profileKey, bool isSelected, ThemeData theme) {
    final profileColors = {
      'cinema': Colors.amber,
      'cinema_dark': Colors.deepPurple,
      'cinema_hdr': Colors.blue,
      'anime': Colors.pink,
      'anime_vibrant': Colors.red,
      'anime_soft': Colors.purple,
      'vivid': Colors.orange,
      'vivid_pop': Colors.cyan,
      'vivid_warm': Colors.deepOrange,
      'natural': Colors.green,
      'dark': Colors.grey,
      'warm': Colors.yellow,
      'cool': Colors.lightBlue,
      'grayscale': Colors.blueGrey,
    };

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () async {
          setState(() => _selectedProfile = profileKey);
          await ColorProfileManager()
              .applyColorProfile(profileKey, widget.player);
          widget.onProfileSelected(profileKey);
          _showProfileAppliedFeedback(profileKey);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      profileColors[profileKey]!,
                      profileColors[profileKey]!.withOpacity(0.7),
                    ],
                  )
                : null,
            color: isSelected ? null : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? profileColors[profileKey]!.withOpacity(0.3)
                    : theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              if (isSelected)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CustomPaint(
                      painter: PatternPainter(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        ColorProfileManager.profileIcons[profileKey],
                        size: 30,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Title
                    Text(
                      profileKey.replaceAll('_', ' ').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      ColorProfileManager.profileDescriptions[profileKey] ?? '',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: profileColors[profileKey],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Fine-tune Your Experience',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Adjust each parameter to create your perfect viewing setup',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 30),

          // Sliders
          ..._customSettings.keys.map((setting) {
            return _buildModernSlider(setting, theme);
          }),

          const SizedBox(height: 40),

          // Action buttons
          _buildActionButtons(theme),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildModernSlider(String setting, ThemeData theme) {
    final value = _customSettings[setting]!;
    final displayName = setting[0].toUpperCase() + setting.substring(1);

    final sliderColors = {
      'brightness': Colors.yellow,
      'contrast': Colors.blue,
      'saturation': Colors.purple,
      'gamma': Colors.green,
      'hue': Colors.orange,
    };

    final sliderIcons = {
      'brightness': Icons.brightness_6_rounded,
      'contrast': Icons.contrast_rounded,
      'saturation': Icons.colorize_rounded,
      'gamma': Icons.gamepad,
      'hue': Icons.color_lens_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      sliderColors[setting]!,
                      sliderColors[setting]!.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  sliderIcons[setting],
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              // Value display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: sliderColors[setting]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sliderColors[setting]!.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  value.toString(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: sliderColors[setting],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Custom slider
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: CustomSliderThumb(
                      color: sliderColors[setting]!,
                    ),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 30),
                    activeTrackColor: sliderColors[setting]!,
                    inactiveTrackColor: theme.colorScheme.surfaceVariant,
                    overlayColor: sliderColors[setting]!.withOpacity(0.1),
                  ),
                  child: Slider(
                    value: value.toDouble(),
                    min: -100,
                    max: 100,
                    divisions: 200,
                    onChanged: (newValue) {
                      setState(() {
                        _customSettings[setting] = newValue.round();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Range labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('-100', style: theme.textTheme.bodySmall),
                    Text('0', style: theme.textTheme.bodySmall),
                    Text('100', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _customSettings =
                    Map.from(ColorProfileManager.profiles['natural']!);
              });
              ColorProfileManager()
                  .applyCustomSettings(_customSettings, widget.player);
              widget.onCustomSettingsChanged(_customSettings);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reset',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ColorProfileManager()
                  .applyCustomSettings(_customSettings, widget.player);
              widget.onCustomSettingsChanged(_customSettings);
              _showProfileAppliedFeedback('Custom');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Apply',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSliderThumb extends SliderComponentShape {
  final Color color;

  CustomSliderThumb({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer ring
    final Paint outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 12, outerPaint);

    // Inner fill
    final Paint innerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, innerPaint);

    // Center dot
    final Paint centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }
}

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double spacing = 20;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
