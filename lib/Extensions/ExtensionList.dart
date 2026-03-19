import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Extensions/extension_item.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/language.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/sliver_grouped_list.dart';

class Extension extends StatefulWidget {
  final bool installed;
  final String query;
  final ItemType itemType;

  const Extension({
    required this.installed,
    required this.query,
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

  List<Source> get _allAvailableExtensions {
    final extensions = sourceController.getAvailableExtensions(widget.itemType);
    if (_currentSearchQuery.isEmpty) return extensions;
    return extensions
        .where(
          (e) =>
              e.name!.toLowerCase().contains(_currentSearchQuery.toLowerCase()),
        )
        .toList();
  }

  List<Source> get _installedExtensions {
    final extensions = sourceController.getInstalledExtensions(widget.itemType);
    if (_currentSearchQuery.isEmpty) return extensions;
    return extensions
        .where(
          (e) =>
              e.name!.toLowerCase().contains(_currentSearchQuery.toLowerCase()),
        )
        .toList();
  }

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
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      // if (widget.installed)
                      //   _buildUpdatePendingList(updateEntries),
                      if (widget.installed)
                        _buildInstalledList(_installedExtensions),
                      if (!widget.installed)
                        _buildNotInstalledList(_allAvailableExtensions),
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
        border: Border.all(color: theme.outline.withOpacity(0.3), width: 1),
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
            child: Icon(Icons.search_rounded, color: theme.primary, size: 22),
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
        border: Border.all(color: theme.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getSectionIcon(title), color: theme.primary, size: 18),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
        onPressed: _isUpdatingAll
            ? null
            : () => _updateAllSources(updateEntries),
        icon: _isUpdatingAll
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.onPrimaryContainer,
                  ),
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
            side: BorderSide(color: theme.primary.withOpacity(0.3), width: 1),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  SliverGroupedListView<Source, String> _buildUpdatePendingList(
    List<Source> updateEntries,
  ) {
    return SliverGroupedListView<Source, String>(
      elements: updateEntries,
      groupBy: (element) => "Update",
      groupSeparatorBuilder: (groupValue) => _buildSectionHeader(
        title: groupValue,
        count: updateEntries.length,
        action: _buildUpdateAllButton(updateEntries),
      ),
      itemBuilder: (context, Source element) =>
          ExtensionListTileWidget(source: element, mediaType: widget.itemType),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  SliverGroupedListView<Source, String> _buildInstalledList(
    List<Source> installedEntries,
  ) {
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
          ExtensionListTileWidget(source: element, mediaType: widget.itemType),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  SliverGroupedListView<Source, String> _buildNotInstalledList(
    List<Source> notInstalledEntries,
  ) {
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
            .where(
              (e) =>
                  completeLanguageName(e.lang!.toLowerCase()) == groupByValue,
            )
            .length;

        return _buildSectionHeader(
          title: groupByValue,
          count: countForLanguage,
        );
      },
      itemBuilder: (context, Source element) =>
          ExtensionListTileWidget(source: element, mediaType: widget.itemType),
      groupComparator: (group1, group2) => group1.compareTo(group2),
      itemComparator: (item1, item2) => item1.name!.compareTo(item2.name!),
      order: GroupedListOrder.ASC,
    );
  }

  Future<void> _updateAllSources(List<Source> sources) async {
    for (var source in sources) {
      await source.update();
    }
    setState(() {});
  }
}
