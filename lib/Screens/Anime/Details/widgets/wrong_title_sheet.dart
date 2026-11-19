import 'dart:async';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Models/wrong_title_search.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WrongTitleSheet extends StatefulWidget {
  final AnimeDetailsController controller;

  const WrongTitleSheet({
    super.key,
    required this.controller,
  });

  @override
  State<WrongTitleSheet> createState() => _WrongTitleSheetState();
}

class _WrongTitleSheetState extends State<WrongTitleSheet> {
  late final TextEditingController _searchCtrl;
  final RxList<WrongTitleSearch> _results = <WrongTitleSearch>[].obs;
  final RxBool _isSearching = false.obs;
  final RxString _searchError = ''.obs;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initialText = widget.controller.mediaData.value.title ??
        widget.controller.mediaData.value.titleRomaji ??
        '';
    _searchCtrl = TextEditingController(text: initialText);
    _performSearch(initialText);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _results.clear();
      _isSearching.value = false;
      return;
    }

    final activeSource = sourceController.activeSource.value;
    if (activeSource == null) {
      _searchError.value = 'No active extension selected.';
      return;
    }

    _isSearching.value = true;
    _searchError.value = '';

    try {
      final res = await activeSource.methods.search(trimmed, 1, []);
      final mapped = res.list
          .map(
            (item) => WrongTitleSearch(
              image: item.cover,
              title: item.title,
              link: item.url,
            ),
          )
          .toList();
      _results.assignAll(mapped);
    } catch (e) {
      _searchError.value = e.toString();
    } finally {
      _isSearching.value = false;
    }
  }

  void _selectResult(WrongTitleSearch item) {
    if (item.link != null && item.link!.isNotEmpty) {
      widget.controller.mappedExtensionTitle.value = item.title ?? '';
      widget.controller.fetchEpisodesForLink(item.link!);
      Navigator.of(context).pop();
      widget.controller.showToast('Mapped to ${item.title ?? "selected title"}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);
    final activeSourceName =
        sourceController.activeSource.value?.name ?? 'No Extension';
    final synonyms = widget.controller.mediaData.value.synonyms ?? [];
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
        maxWidth: 720,
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AzTokens.radiusBottomSheet),
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Map Extension Title',
                        style: TextStyle(
                          fontFamily: 'Poppins-Bold',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.extension_rounded,
                            size: 14,
                            color: tones.accent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            activeSourceName,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: tones.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      onSubmitted: _performSearch,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search anime on $activeSourceName...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      color: theme.colorScheme.onSurfaceVariant,
                      onPressed: () {
                        _searchCtrl.clear();
                        _performSearch('');
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          if (synonyms.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: synonyms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final syn = synonyms[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _searchCtrl.text = syn;
                      _performSearch(syn);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        syn,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Obx(() {
              if (_isSearching.value) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(tones.accent),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Searching $activeSourceName...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_searchError.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 38,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Search failed on $activeSourceName',
                          style: TextStyle(
                            fontFamily: 'Poppins-Bold',
                            fontSize: 14.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchError.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_results.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No titles found on $activeSourceName',
                          style: TextStyle(
                            fontFamily: 'Poppins-Bold',
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching with the Japanese romaji or English title.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _results[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _selectResult(item),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 50,
                              height: 68,
                              child: item.image != null &&
                                      item.image!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                        child: const Icon(
                                            Icons.broken_image_rounded,
                                            size: 20),
                                      ),
                                    )
                                  : Container(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      child: const Icon(
                                          Icons.movie_filter_rounded,
                                          size: 20),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title ?? 'Unknown',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins-Bold',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to map episodes to this title',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: tones.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
