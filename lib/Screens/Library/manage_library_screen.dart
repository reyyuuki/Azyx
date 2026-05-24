import 'dart:ui';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ManageLibraryScreen extends StatefulWidget {
  final bool isManga;
  const ManageLibraryScreen({super.key, required this.isManga});

  @override
  State<ManageLibraryScreen> createState() => _ManageLibraryScreenState();
}

class _ManageLibraryScreenState extends State<ManageLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Category? _selectedCategoryForItems;
  late final Stream<List<Category>> _categoriesStream1;
  late final Stream<List<Category>> _categoriesStream2;
  late final Stream<List<OfflineItem>> _itemsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categoriesStream1 = widget.isManga
        ? offlineController.getMangaCategoriesStream()
        : offlineController.getAnimeCategories();
    _categoriesStream2 = widget.isManga
        ? offlineController.getMangaCategoriesStream()
        : offlineController.getAnimeCategories();
    _itemsStream = widget.isManga
        ? offlineController.getOfflineMangaStream()
        : offlineController.getOfflineAnimeStream();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, ColorScheme cs) {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: cs.surfaceContainerHigh.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          title: Text(
            'New Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          content: TextField(
            controller: textCtrl,
            autofocus: true,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Category Name',
              hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = textCtrl.text.trim();
                if (name.isNotEmpty) {
                  if (widget.isManga) {
                    offlineController.createMangaCategory(name);
                  } else {
                    offlineController.createCategory(name);
                  }
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameCategoryDialog(
    BuildContext context,
    ColorScheme cs,
    Category cat,
  ) {
    final textCtrl = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: cs.surfaceContainerHigh.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          title: Text(
            'Rename Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          content: TextField(
            controller: textCtrl,
            autofocus: true,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Category Name',
              hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = textCtrl.text.trim();
                if (name.isNotEmpty) {
                  offlineController.renameCategory(cat, name);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    ColorScheme cs,
    Category cat,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: cs.surfaceContainerHigh.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          title: Text(
            'Delete Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.error,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${cat.name}"? Items in this category will not be deleted, they will remain in your library.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                offlineController.deleteCategory(cat);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    ColorScheme cs,
    OfflineItem item,
    Category cat,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: cs.surfaceContainerHigh.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          title: Text(
            'Remove Item',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.error,
            ),
          ),
          content: Text(
            'Remove "${item.mediaData?.title ?? ''}" from the category "${cat.name}"?',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                offlineController.removeFromCategory(
                  cat,
                  item.mediaData!.id!.toString(),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Remove',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Library',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: cs.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [Tab(text: 'Categories'), Tab(text: 'Items')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _KeepAliveTab(child: _buildCategoriesTab(cs)),
          _KeepAliveTab(child: _buildItemsTab(cs)),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final isFirstTab = _tabController.index == 0;
          return isFirstTab
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddCategoryDialog(context, cs),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Add Category',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoriesTab(ColorScheme cs) {
    return StreamBuilder<List<Category>>(
      stream: _categoriesStream1,
      builder: (context, snapshot) {
        final rawList = snapshot.data ?? [];
        final order = offlineController.getCategoryOrder(widget.isManga);
        final list = List<Category>.from(rawList);

        if (order.isNotEmpty) {
          list.sort((a, b) {
            final idxA = order.indexOf(a.id);
            final idxB = order.indexOf(b.id);
            if (idxA == -1 && idxB == -1) return 0;
            if (idxA == -1) return 1;
            if (idxB == -1) return -1;
            return idxA.compareTo(idxB);
          });
        }

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: cs.onSurfaceVariant.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: list.length,
            onReorder: (oldIdx, newIdx) {
              if (oldIdx < newIdx) {
                newIdx -= 1;
              }
              final cat = list.removeAt(oldIdx);
              list.insert(newIdx, cat);
              final orderedIds = list.map((c) => c.id).toList();
              offlineController.saveCategoryOrder(orderedIds, widget.isManga);
              setState(() {});
            },
            itemBuilder: (context, index) {
              final cat = list[index];
              return Container(
                key: ValueKey(cat.id),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                  title: Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${cat.anilistIds?.length ?? 0} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: cs.primary, size: 20),
                        onPressed: () => _showRenameCategoryDialog(context, cs, cat),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_rounded, color: cs.error, size: 20),
                        onPressed: () => _showDeleteCategoryDialog(context, cs, cat),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemsTab(ColorScheme cs) {
    return StreamBuilder<List<Category>>(
      stream: _categoriesStream2,
      builder: (context, catSnapshot) {
        final rawCats = catSnapshot.data ?? [];
        final order = offlineController.getCategoryOrder(widget.isManga);
        final categories = List<Category>.from(rawCats);

        if (order.isNotEmpty) {
          categories.sort((a, b) {
            final idxA = order.indexOf(a.id);
            final idxB = order.indexOf(b.id);
            if (idxA == -1 && idxB == -1) return 0;
            if (idxA == -1) return 1;
            if (idxB == -1) return -1;
            return idxA.compareTo(idxB);
          });
        }

        if (categories.isEmpty) {
          return Center(
            child: Text(
              'No categories found',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        }

        if (_selectedCategoryForItems == null ||
            !categories.any((c) => c.id == _selectedCategoryForItems!.id)) {
          _selectedCategoryForItems = categories.first;
        } else {
          _selectedCategoryForItems = categories.firstWhere(
            (c) => c.id == _selectedCategoryForItems!.id,
          );
        }

        final currentCat = _selectedCategoryForItems!;

        return StreamBuilder<List<OfflineItem>>(
          stream: _itemsStream,
          builder: (context, itemSnapshot) {
            final allItems = itemSnapshot.data ?? [];
            final ids = currentCat.anilistIds ?? [];
            final itemsMap = {
              for (var i in allItems) i.mediaData?.id?.toString(): i
            };
            final list = ids
                .map((id) => itemsMap[id])
                .whereType<OfflineItem>()
                .toList();

            return Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat.id == currentCat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryForItems = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primary : cs.surfaceContainerHigh.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat.name ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_rounded, size: 64, color: cs.onSurfaceVariant.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No Items inside this Category',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                          ),
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                            itemCount: list.length,
                            onReorder: (oldIdx, newIdx) {
                              offlineController.reorderItemsInCategory(
                                currentCat,
                                oldIdx,
                                newIdx,
                              );
                            },
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final media = item.mediaData;
                              return Container(
                                key: ValueKey(media?.id ?? index.toString()),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.outlineVariant.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(
                                          Icons.drag_indicator_rounded,
                                          color: cs.onSurfaceVariant.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 40,
                                          height: 56,
                                          child: CachedNetworkImage(
                                            imageUrl: media?.image ?? '',
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(color: cs.surfaceContainerHighest),
                                            errorWidget: (_, __, ___) => Container(
                                              color: cs.surfaceContainerHighest,
                                              child: const Icon(Icons.broken_image, size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    media?.title ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    (media?.genres != null && media!.genres!.isNotEmpty)
                                        ? media.genres!.first
                                        : 'Unknown',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error, size: 22),
                                    onPressed: () => _showRemoveItemDialog(
                                      context,
                                      cs,
                                      item,
                                      currentCat,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({super.key, required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
