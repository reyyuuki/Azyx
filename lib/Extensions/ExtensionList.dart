// ignore_for_file: file_names

import 'package:azyx/Preferences/PrefManager.dart';
import 'package:azyx/Widgets/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/sliver_grouped_list.dart';

import '../../Preferences/Preferences.dart';
import '../../api/Mangayomi/Extensions/GetSourceList.dart';
import '../../api/Mangayomi/Extensions/extensions_provider.dart';
import '../../api/Mangayomi/Extensions/fetch_anime_sources.dart';
import '../../api/Mangayomi/Extensions/fetch_manga_sources.dart';
import '../../api/Mangayomi/Model/Source.dart';
import 'ExtensionItem.dart';

class Extension extends ConsumerStatefulWidget {
  final bool installed;
  final bool isManga;
  final String query;

  const Extension({
    required this.installed,
    required this.query,
    required this.isManga,
    super.key,
  });

  @override
  ConsumerState<Extension> createState() => _ExtensionScreenState();
}

class _ExtensionScreenState extends ConsumerState<Extension> {
  late final ScrollController _scrollController;
  bool _isUpdatingAll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (widget.isManga) {
      await ref
          .read(fetchMangaSourcesListProvider(id: null, reFresh: false).future);
    } else {
      await ref
          .read(fetchAnimeSourcesListProvider(id: null, reFresh: false).future);
    }
  }

  Future<void> _refreshData() async {
    if (widget.isManga) {
      return await ref.refresh(
          fetchMangaSourcesListProvider(id: null, reFresh: true).future);
    } else {
      return await ref.refresh(
          fetchAnimeSourcesListProvider(id: null, reFresh: true).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final streamExtensions =
        ref.watch(getExtensionsStreamProvider(widget.isManga));

    return RefreshIndicator.adaptive(
      onRefresh: _refreshData,
      backgroundColor: theme.primaryContainer,
      color: theme.onPrimaryContainer,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: streamExtensions.when(
          data: (data) {
            data = _filterData(data);
            final installedEntries = _getInstalledEntries(data);
            final updateEntries = _getUpdateEntries(data);
            final notInstalledEntries = _getNotInstalledEntries(data);

            return Scrollbar(
              interactive: true,
              controller: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (widget.installed && updateEntries.isNotEmpty)
                    _buildUpdatePendingList(updateEntries),
                  if (widget.installed) _buildInstalledList(installedEntries),
                  if (!widget.installed)
                    _buildNotInstalledList(notInstalledEntries),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          },
          error: (error, _) => _buildErrorState(theme),
          loading: () => _buildLoadingState(theme),
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.error.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load extensions',
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                color: theme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryContainer,
                foregroundColor: theme.onPrimaryContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading extensions...',
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Source> _filterData(List<Source> data) {
    return data
        .where((element) =>
            widget.query.isEmpty ||
            element.name!.toLowerCase().contains(widget.query.toLowerCase()))
        .where((element) =>
            PrefManager.getVal(PrefName.NSFWExtensions) ||
            element.isNsfw == false)
        .toList();
  }

  List<Source> _getInstalledEntries(List<Source> data) {
    return data
        .where((element) => element.version == element.versionLast!)
        .where((element) => element.isAdded!)
        .toList();
  }

  List<Source> _getUpdateEntries(List<Source> data) {
    return data
        .where((element) =>
            compareVersions(element.version!, element.versionLast!) < 0)
        .where((element) => element.isAdded!)
        .toList();
  }

  List<Source> _getNotInstalledEntries(List<Source> data) {
    return data
        .where((element) => element.version == element.versionLast!)
        .where((element) => !element.isAdded!)
        .toList();
  }

  Widget _buildSectionHeader({
    required String title,
    Widget? action,
    int? count,
  }) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.primaryContainer.withOpacity(0.4),
            theme.primaryContainer.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSectionIcon(title),
              color: theme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.onSurface,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: theme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title.toLowerCase()) {
      case 'update pending':
        return Icons.update_rounded;
      case 'installed':
        return Icons.check_circle_rounded;
      default:
        return Icons.language_rounded;
    }
  }

  Widget _buildUpdateAllButton(List<Source> updateEntries) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed:
            _isUpdatingAll ? null : () => _updateAllSources(updateEntries),
        icon: _isUpdatingAll
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.onPrimaryContainer),
                ),
              )
            : const Icon(Icons.system_update_rounded, size: 16),
        label: Text(
          'Update All',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryContainer,
          foregroundColor: theme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  SliverGroupedListView<Source, String> _buildUpdatePendingList(
      List<Source> updateEntries) {
    return SliverGroupedListView<Source, String>(
      elements: updateEntries,
      groupBy: (element) => "Update Pending",
      groupSeparatorBuilder: (groupValue) => _buildSectionHeader(
        title: groupValue,
        count: updateEntries.length,
        action: _buildUpdateAllButton(updateEntries),
      ),
      itemBuilder: (context, Source element) =>
          ExtensionListTileWidget(source: element),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  SliverGroupedListView<Source, String> _buildInstalledList(
      List<Source> installedEntries) {
    if (installedEntries.isEmpty) {
      return SliverGroupedListView<Source, String>(
        elements: [],
        groupBy: (element) => "",
        groupSeparatorBuilder: (_) => const SizedBox.shrink(),
        itemBuilder: (context, element) => const SizedBox.shrink(),
      );
    }

    return SliverGroupedListView<Source, String>(
      elements: installedEntries,
      groupBy: (element) => "Installed",
      groupSeparatorBuilder: (groupValue) => _buildSectionHeader(
        title: groupValue,
        count: installedEntries.length,
      ),
      itemBuilder: (context, Source element) =>
          ExtensionListTileWidget(source: element),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  SliverGroupedListView<Source, String> _buildNotInstalledList(
      List<Source> notInstalledEntries) {
    if (notInstalledEntries.isEmpty) {
      return SliverGroupedListView<Source, String>(
        elements: [],
        groupBy: (element) => "",
        groupSeparatorBuilder: (_) => const SizedBox.shrink(),
        itemBuilder: (context, element) => const SizedBox.shrink(),
      );
    }

    return SliverGroupedListView<Source, String>(
      elements: notInstalledEntries,
      groupBy: (element) => completeLanguageName(element.lang!.toLowerCase()),
      groupSeparatorBuilder: (String groupByValue) {
        final countForLanguage = notInstalledEntries
            .where((e) =>
                completeLanguageName(e.lang!.toLowerCase()) == groupByValue)
            .length;

        return _buildSectionHeader(
          title: groupByValue,
          count: countForLanguage,
        );
      },
      itemBuilder: (context, Source element) =>
          ExtensionListTileWidget(source: element),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  Future<void> _updateAllSources(List<Source> sources) async {
    setState(() => _isUpdatingAll = true);

    try {
      for (var source in sources) {
        if (source.isManga!) {
          await ref.watch(
              fetchMangaSourcesListProvider(id: source.id, reFresh: true)
                  .future);
        } else {
          await ref.watch(
              fetchAnimeSourcesListProvider(id: source.id, reFresh: true)
                  .future);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAll = false);
      }
    }
  }
}
