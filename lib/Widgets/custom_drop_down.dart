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

  void _showSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _SourceBottomSheetContent(
              items: items.toList(),
              currentSource: _resolveActiveSource(),
              labelText: labelText,
              onChanged: onChanged,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showSourceBottomSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final current = _resolveActiveSource();
          return Row(
            children: [
              if (current != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: current.iconUrl ?? '',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.3,
                        ),
                        child: Icon(
                          Icons.extension_rounded,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.3,
                        ),
                        child: Icon(
                          Icons.extension_rounded,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labelText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: theme.textTheme.labelSmall?.fontFamily,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AzyXText(
                      text: current?.name ?? 'Select source...',
                      fontSize: 15,
                      fontVariant: current != null
                          ? FontVariant.bold
                          : FontVariant.regular,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                    width: 0.5,
                  ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          AzyXText(
            text: widget.labelText,
            fontSize: 18,
            fontVariant: FontVariant.bold,
            color: colorScheme.onSurface,
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search sources...",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
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
                    child: Text(
                      "No sources found",
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final itemValue = item.id.toString();
                      final isSelected = widget.currentSource?.id == item.id;
                      return GestureDetector(
                        onTap: () {
                          widget.onChanged(itemValue);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withOpacity(0.15)
                                : colorScheme.surfaceContainerHighest
                                      .withOpacity(0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary.withOpacity(0.4)
                                  : colorScheme.outline.withOpacity(0.1),
                              width: isSelected ? 1.2 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.4),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: item.iconUrl ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Icon(
                                      Icons.extension_rounded,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                      size: 20,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.extension_rounded,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AzyXText(
                                      text: item.name ?? '',
                                      fontSize: 15,
                                      fontVariant: FontVariant.bold,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                    ),
                                    if (item.lang != null &&
                                        item.lang!.isNotEmpty)
                                      Text(
                                        item.lang!.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
