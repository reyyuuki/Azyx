import 'package:anymex_extension_runtime_bridge/Models/Source.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSourceDropdown extends StatelessWidget {
  final RxList<Source> items;
  final Function(String?) onChanged;
  final String labelText;
  final dynamic sourceController;
  final Source? selectedSource;
  final Rx<Source>? customSelectedSource;
  const CustomSourceDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.sourceController,
    this.selectedSource,
    this.customSelectedSource,
    this.labelText = 'Choose Source',
  });

  Source? _resolveActiveSource() {
    try {
      items.length;
      if (customSelectedSource != null) {
        return customSelectedSource!.value;
      }
      if (selectedSource != null) {
        return selectedSource;
      }
      if (sourceController != null && sourceController.activeSource != null) {
        final active = sourceController.activeSource;
        if (active is Rx) {
          return active.value as Source?;
        }
        return active as Source?;
      }
    } catch (_) {}
    return items.isNotEmpty ? items.first : null;
  }

  static void showSourceSheet({
    required BuildContext context,
    required List<Source> items,
    required Source? currentSource,
    required String labelText,
    required Function(String?) onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.35,
            maxChildSize: 0.88,
            expand: false,
            builder: (context, scrollController) {
              return _SourceBottomSheetContent(
                items: items,
                currentSource: currentSource,
                labelText: labelText,
                onChanged: onChanged,
                scrollController: scrollController,
              );
            },
          ),
        );
      },
    );
  }

  void _showSourceBottomSheet(BuildContext context) {
    showSourceSheet(
      context: context,
      items: items.toList(),
      currentSource: _resolveActiveSource(),
      labelText: labelText,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showSourceBottomSheet(context),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Obx(() {
            final current = _resolveActiveSource();
            return Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: (current?.iconUrl != null &&
                            current!.iconUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: current.iconUrl!,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              Icons.extension_rounded,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                              size: 20,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.extension_rounded,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                              size: 20,
                            ),
                          )
                        : Icon(
                            Icons.extension_rounded,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labelText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: theme.textTheme.labelSmall?.fontFamily,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AzyXText(
                        text: current?.name ?? 'Select source...',
                        fontSize: 14.5,
                        fontVariant: current != null
                            ? FontVariant.bold
                            : FontVariant.regular,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SourceBottomSheetContent extends StatefulWidget {
  final List<Source> items;
  final Source? currentSource;
  final String labelText;
  final Function(String?) onChanged;
  final ScrollController scrollController;

  const _SourceBottomSheetContent({
    required this.items,
    required this.currentSource,
    required this.labelText,
    required this.onChanged,
    required this.scrollController,
  });

  @override
  State<_SourceBottomSheetContent> createState() =>
      _SourceBottomSheetContentState();
}

class _SourceBottomSheetContentState extends State<_SourceBottomSheetContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredList = widget.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      final nameMatch =
          item.name?.toLowerCase().contains(_searchQuery) ?? false;
      final langMatch =
          item.lang?.toLowerCase().contains(_searchQuery) ?? false;
      return nameMatch || langMatch;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.18),
            width: 0.8,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.extension_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select ${widget.labelText}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${widget.items.length} installed sources',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(28),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search sources...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No sources found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final itemValue = item.id.toString();
                      final isSelected = widget.currentSource?.id == item.id;
                      return Material(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.14)
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            widget.onChanged(itemValue);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? colorScheme.surface
                                            .withValues(alpha: 0.65)
                                        : colorScheme.surfaceContainerHigh,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: (item.iconUrl != null &&
                                            item.iconUrl!.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: item.iconUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Icon(
                                              Icons.extension_rounded,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                              size: 20,
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.extension_rounded,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                              size: 20,
                                            ),
                                          )
                                        : Icon(
                                            Icons.extension_rounded,
                                            color: colorScheme.onSurfaceVariant,
                                            size: 20,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? colorScheme.onSecondaryContainer
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                      if (item.lang != null &&
                                          item.lang!.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          item.lang!.toUpperCase(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: isSelected
                                                ? colorScheme
                                                    .onSecondaryContainer
                                                    .withValues(alpha: 0.78)
                                                : colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
