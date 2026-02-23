// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';

void showBottom(BuildContext context, Function(String) onAddRepository) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.3.glowMultiplier()),
              blurRadius: 20.blurMultiplier(),
              spreadRadius: 5.spreadMultiplier(),
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: RepositoryBottomSheet(onAddRepository: onAddRepository),
      );
    },
  );
}

class RepositoryBottomSheet extends StatefulWidget {
  final Function(String) onAddRepository;

  const RepositoryBottomSheet({super.key, required this.onAddRepository});

  @override
  State<RepositoryBottomSheet> createState() => _RepositoryBottomSheetState();
}

class _RepositoryBottomSheetState extends State<RepositoryBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _mangaYomiAnimeController = TextEditingController();
  final _mangaYomiMangaController = TextEditingController();
  final _aniyomiAnimeController = TextEditingController();
  final _aniyomiMangaController = TextEditingController();

  List<String> availableTabs = [];
  List<String> tabLabels = [];

  @override
  void initState() {
    super.initState();
    _setupTabs();
    _tabController = TabController(length: availableTabs.length, vsync: this);
    _loadCurrentRepositories();
  }

  void _setupTabs() {
    availableTabs.add('MangaYomi');
    tabLabels.add('MangaYomi');

    if (Platform.isAndroid) {
      availableTabs.add('Aniyomi');
      tabLabels.add('Aniyomi');
    }
  }

  void _loadCurrentRepositories() {
    _mangaYomiAnimeController.text = sourceController.activeAnimeRepo;
    _mangaYomiMangaController.text = sourceController.activeMangaRepo;
    _aniyomiAnimeController.text = sourceController.activeAniyomiAnimeRepo;
    _aniyomiMangaController.text = sourceController.activeAniyomiMangaRepo;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mangaYomiAnimeController.dispose();
    _mangaYomiMangaController.dispose();
    _aniyomiAnimeController.dispose();
    _aniyomiMangaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: theme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          AzyXText(
            text: "Repository Manager",
            fontSize: 24,
            fontVariant: FontVariant.bold,
          ),
          const SizedBox(height: 20),
          if (availableTabs.length > 1) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.surfaceContainerHighest.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadow.withOpacity(0.1.glowMultiplier()),
                    blurRadius: 8.blurMultiplier(),
                    spreadRadius: 1.spreadMultiplier(),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withOpacity(0.3.glowMultiplier()),
                      blurRadius: 8.blurMultiplier(),
                      spreadRadius: 1.spreadMultiplier(),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                labelColor: theme.onPrimary,
                unselectedLabelColor: theme.onSurface.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    child: AzyXText(
                      text: 'MangaYomi',
                      fontSize: 13,
                      fontVariant: FontVariant.bold,
                    ),
                  ),
                  Tab(
                    child: AzyXText(
                      text: 'Aniyomi',
                      fontSize: 13,
                      fontVariant: FontVariant.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: availableTabs
                    .map((platform) => _buildRepositoryForm(
                          context,
                          platform,
                          platform == 'MangaYomi'
                              ? _mangaYomiAnimeController
                              : _aniyomiAnimeController,
                          platform == 'MangaYomi'
                              ? _mangaYomiMangaController
                              : _aniyomiMangaController,
                        ))
                    .toList(),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Flexible(
              child: _buildRepositoryForm(
                context,
                availableTabs.first,
                _mangaYomiAnimeController,
                _mangaYomiMangaController,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepositoryForm(
    BuildContext context,
    String platform,
    TextEditingController animeController,
    TextEditingController mangaController,
  ) {
    final theme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          10.height,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.surface,
              border: Border.all(
                color: theme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.1.glowMultiplier()),
                  blurRadius: 6.blurMultiplier(),
                  spreadRadius: 1.spreadMultiplier(),
                ),
              ],
            ),
            child: TextField(
              controller: animeController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
                labelText: "Anime Repository URL",
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.primary,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.play_circle_outline,
                  color: theme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.surface,
              border: Border.all(
                color: theme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.1.glowMultiplier()),
                  blurRadius: 6.blurMultiplier(),
                  spreadRadius: 1.spreadMultiplier(),
                ),
              ],
            ),
            child: TextField(
              controller: mangaController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
                labelText: "Manga Repository URL",
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.primary,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.book_outlined,
                  color: theme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  theme.primary,
                  theme.primary.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.3.glowMultiplier()),
                  blurRadius: 12.blurMultiplier(),
                  spreadRadius: 2.spreadMultiplier(),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _handleAddRepository(
                    context, platform, animeController, mangaController),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save_rounded,
                      color: theme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    AzyXText(
                      text: "Save",
                      fontSize: 16,
                      fontVariant: FontVariant.bold,
                      color: theme.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: theme.surfaceContainer.withOpacity(0.7),
              border: Border.all(
                color: theme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadow.withOpacity(0.08.glowMultiplier()),
                  blurRadius: 10.blurMultiplier(),
                  spreadRadius: 2.spreadMultiplier(),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: theme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AzyXText(
                    text:
                        "This app does not promote piracy. Please add only legal and authorized repositories.",
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _handleAddRepository(
    BuildContext context,
    String platform,
    TextEditingController animeController,
    TextEditingController mangaController,
  ) async {
    final animeUrl = animeController.text.trim();
    final mangaUrl = mangaController.text.trim();

    if (animeUrl.isEmpty && mangaUrl.isEmpty) {
      _showErrorSnackBar(context, 'Please enter at least one repository URL');
      return;
    }

    try {
      if (platform == 'MangaYomi') {
        if (animeUrl.isNotEmpty) {
          sourceController.activeAnimeRepo = animeUrl;
        }
        if (mangaUrl.isNotEmpty) {
          sourceController.activeMangaRepo = mangaUrl;
        }
      } else if (platform == 'Aniyomi') {
        if (animeUrl.isNotEmpty) {
          sourceController.activeAniyomiAnimeRepo = animeUrl;
        }
        if (mangaUrl.isNotEmpty) {
          sourceController.activeAniyomiMangaRepo = mangaUrl;
        }
      }

      _showLoadingDialog(context);

      await sourceController.fetchRepos();

      Navigator.pop(context);
      Navigator.pop(context);

      widget.onAddRepository('success');

      _showSuccessSnackBar(
          context, '$platform repositories updated successfully!');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(
          context, 'Failed to update repositories: ${e.toString()}');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            AzyXText(
              text: 'Saving repositories...',
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AzyXText(
                text: message,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AzyXText(
                text: message,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
