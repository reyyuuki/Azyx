import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Extensions/ExtensionItem.dart';
import 'package:azyx/Preferences/PrefManager.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/language.dart';
import 'package:dartotsu_extension_bridge/ExtensionManager.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/sliver_grouped_list.dart';

import '../../Preferences/Preferences.dart';
import '../utils/utils.dart';

class Extension extends StatefulWidget {
  final bool installed;
  final bool isManga;
  final String query;
  final ItemType itemType;

  const Extension({
    required this.installed,
    required this.query,
    required this.isManga,
    required this.itemType,
    super.key,
  });

  @override
  State<Extension> createState() => _ExtensionScreenState();
}

class _ExtensionScreenState extends State<Extension> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isUpdatingAll = false;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController(text: widget.query);
    _searchFocusNode = FocusNode();
    _currentSearchQuery = widget.query;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await sourceController.fetchRepos();
    setState(() {});
    Utils.log('get extensions: ${_installedExtensions.length}');
  }

  void _onSearchChanged(String value) {
    setState(() {
      _currentSearchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _currentSearchQuery = '';
    });
  }

  List<Source> get _allAvailableExtensions =>
      sourceController.getAvailableExtensions(widget.itemType);

  List<Source> get _installedExtensions =>
      sourceController.getInstalledExtensions(widget.itemType);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshData(),
      backgroundColor: theme.primaryContainer,
      color: theme.onPrimaryContainer,
      child: Column(
        children: [
          _buildSearchBar(theme),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Scrollbar(
                interactive: true,
                controller: _scrollController,
                child: Obx(() {
                  final installedEntries = _getInstalledEntries();
                  final updateEntries = _getUpdateEntries();
                  final notInstalledEntries = _getNotInstalledEntries();
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      if (widget.installed)
                        _buildUpdatePendingList(updateEntries),
                      if (widget.installed)
                        _buildInstalledList(installedEntries),
                      if (!widget.installed)
                        _buildNotInstalledList(notInstalledEntries),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.surfaceVariant.withOpacity(0.3),
            theme.surfaceVariant.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        style: TextStyle(
          color: theme.onSurface,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          hintText: 'Search extensions...',
          hintStyle: TextStyle(
            color: theme.onSurface.withOpacity(0.6),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: theme.primary,
              size: 22,
            ),
          ),
          suffixIcon: _currentSearchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.clear_rounded,
                      color: theme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
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
              onPressed: _refreshData,
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
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryContainer.withOpacity(0.3),
              theme.secondaryContainer.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primary.withOpacity(0.1),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Extensions',
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This may take 10-15 seconds to fetch\nall available extensions',
              style: TextStyle(
                color: theme.onSurface.withOpacity(0.7),
                fontSize: 15,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      color: theme.onSurface.withOpacity(0.8),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
            _currentSearchQuery.isEmpty ||
            element.name!
                .toLowerCase()
                .contains(_currentSearchQuery.toLowerCase()))
        .where((element) =>
            widget.query.isEmpty ||
            element.name!.toLowerCase().contains(widget.query.toLowerCase()))
        .toList();
  }

  List<Source> _getNotInstalledEntries() {
    final availableExtensions = _allAvailableExtensions;
    final installedExtensions = _installedExtensions;

    final notInstalled = availableExtensions.where((available) {
      return !installedExtensions.any((installed) =>
          installed.name == available.name && installed.lang == available.lang);
    }).toList();

    return _filterData(notInstalled);
  }

  List<Source> _getInstalledEntries() {
    final installedExtensions = _installedExtensions;
    return _filterData(installedExtensions);
  }

  List<Source> _getUpdateEntries() {
    final installedExtensions = _installedExtensions;

    final updateAvailable = <Source>[];

    for (final installed in installedExtensions) {
      if (installed.hasUpdate ?? false) {
        updateAvailable.add(installed);
      }
    }

    return _filterData(updateAvailable);
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
        label: const AzyXText(
          text: 'Update All',
          fontVariant: FontVariant.bold,
          fontSize: 13,
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
      groupBy: (element) => "Update",
      groupSeparatorBuilder: (groupValue) => _buildSectionHeader(
        title: groupValue,
        count: updateEntries.length,
        action: _buildUpdateAllButton(updateEntries),
      ),
      itemBuilder: (context, Source element) => ExtensionListTileWidget(
        source: element,
        mediaType: widget.itemType,
      ),
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
      itemBuilder: (context, Source element) => ExtensionListTileWidget(
        source: element,
        mediaType: widget.itemType,
      ),
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
      itemBuilder: (context, Source element) => ExtensionListTileWidget(
        source: element,
        mediaType: widget.itemType,
      ),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  Future<void> _updateAllSources(List<Source> sources) async {
    for (var source in sources) {
      await source.extensionType!.getManager().updateSource(source);
    }
    setState(() {});
  }
}
