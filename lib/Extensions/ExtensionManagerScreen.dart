import 'dart:io';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar, SourceExecution;
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class ExtensionManagerScreen extends StatefulWidget {
  const ExtensionManagerScreen({super.key});

  @override
  State<ExtensionManagerScreen> createState() => _ExtensionManagerScreenState();
}

class _ExtensionManagerScreenState extends State<ExtensionManagerScreen>
    with TickerProviderStateMixin {
  bool _isRefreshing = false;
  final RxBool _isRuntimeLoaded = true.obs;
  TabController? _tabController;
  List<Extension> _managers = [];

  @override
  void initState() {
    super.initState();
    _isRuntimeLoaded.value = AnymeXRuntimeBridge.controller.isReady.value;
    ever(AnymeXRuntimeBridge.controller.isReady, (val) {
      _isRuntimeLoaded.value = val;
    });
    ever(sourceController.isExtensionManagerInitialized, (val) {
      if (val) _rebuildTabController();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRuntime();
      if (sourceController.isExtensionManagerInitialized.value) {
        _rebuildTabController();
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _rebuildTabController() {
    final all = sourceController.extensionManager.managers.toList();
    final filtered = _filterManagers(all);
    if (_managers.length == filtered.length &&
        _managers.map((m) => m.id).join() ==
            filtered.map((m) => m.id).join()) return;
    setState(() {
      _managers = filtered;
      _tabController?.dispose();
      _tabController = TabController(length: filtered.length, vsync: this);
    });
  }

  Future<void> _checkRuntime() async {
    final loaded = await AnymeXRuntimeBridge.isLoaded();
    _isRuntimeLoaded.value =
        loaded || AnymeXRuntimeBridge.controller.isReady.value;
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await sourceController.fetchRepos();
    if (mounted) setState(() => _isRefreshing = false);
  }

  List<Extension> _filterManagers(List<Extension> all) {
    return all.where((m) {
      if (!Platform.isAndroid &&
          (m.id == 'aniyomi' || m.id == 'cloudstream')) return false;
      return true;
    }).toList();
  }

  String _managerLabel(String id) => switch (id) {
    'mangayomi' => 'MangaYomi',
    'aniyomi' => 'Aniyomi',
    'aniyomi-desktop' => 'Aniyomi',
    'sora' => 'Sora',
    'cloudstream' => 'CloudStream',
    _ => id,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Obx(() {
        if (!sourceController.isExtensionManagerInitialized.value) {
          return const Center(child: LoadingIndicatorM3E());
        }
        final tc = _tabController;
        if (tc == null || _managers.isEmpty) {
          return const Center(child: LoadingIndicatorM3E());
        }

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Broken.arrow_left_2, color: cs.onSurface, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Extension Manager',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              _isRefreshing
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingIndicatorM3E(),
                      ),
                    )
                  : IconButton(
                      onPressed: _refresh,
                      icon: Icon(Icons.refresh_rounded, color: cs.onSurface, size: 24),
                    ),
            ],
            bottom: TabBar(
              controller: tc,
              isScrollable: _managers.length > 2,
              tabAlignment:
                  _managers.length > 2 ? TabAlignment.start : TabAlignment.fill,
              dividerColor: Colors.transparent,
              indicatorColor: cs.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: _managers.map((m) {
                return Tab(text: _managerLabel(m.id));
              }).toList(),
            ),
          ),
          body: AzyXGradientContainer(
            child: Column(
              children: [
                if (!_isRuntimeLoaded.value && Platform.isAndroid)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _buildRuntimeWarning(cs),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: tc,
                    children: _managers
                        .map((m) => _ManagerPage(manager: m))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRuntimeWarning(ColorScheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.errorContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.error.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: AzyXText(
              text: 'AnymeX runtime is not loaded',
              fontSize: 12,
              color: theme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              sourceController.checkRuntimeHost();
              if (!mounted) return;
              _isRuntimeLoaded.value =
                  AnymeXRuntimeBridge.controller.isReady.value;
              if (_isRuntimeLoaded.value) await _refresh();
            },
            child: Text(
              'Load Runtime',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerPage extends StatelessWidget {
  final Extension manager;

  const _ManagerPage({required this.manager});

  List<ItemType> get _supportedTypes {
    final types = <ItemType>[];
    if (manager.supportsAnime) types.add(ItemType.anime);
    if (manager.supportsManga) types.add(ItemType.manga);
    if (manager.supportsNovel) types.add(ItemType.novel);
    return types;
  }

  @override
  Widget build(BuildContext context) {
    final types = _supportedTypes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: types
          .map((type) => _RepoSection(manager: manager, itemType: type))
          .toList(),
    );
  }
}

class _RepoSection extends StatefulWidget {
  final Extension manager;
  final ItemType itemType;

  const _RepoSection({required this.manager, required this.itemType});

  @override
  State<_RepoSection> createState() => _RepoSectionState();
}

class _RepoSectionState extends State<_RepoSection> {
  final _urlController = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addRepo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() => _adding = true);
    await sourceController.addRepo(url, widget.itemType, widget.manager.id);
    _urlController.clear();
    if (mounted) setState(() => _adding = false);
  }

  IconData get _typeIcon => switch (widget.itemType) {
    ItemType.anime => Icons.movie_creation_rounded,
    ItemType.manga => Broken.book,
    ItemType.novel => Broken.document,
  };

  String get _typeLabel => switch (widget.itemType) {
    ItemType.anime => 'Anime',
    ItemType.manga => 'Manga',
    ItemType.novel => 'Novel',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(_typeIcon, size: 15, color: theme.primary),
              const SizedBox(width: 8),
              Text(
                '$_typeLabel Repositories',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final repos = widget.manager.getReposRx(widget.itemType).value;
          if (repos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No repositories added yet. Paste a URL below to get started.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: theme.onSurface.withOpacity(0.4),
                ),
              ),
            );
          }
          return Column(
            children: repos
                .map((repo) => _RepoTile(repo: repo, itemType: widget.itemType))
                .toList(),
          );
        }),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: theme.onSurface,
                ),
                onSubmitted: (_) => _addRepo(),
                decoration: InputDecoration(
                  hintText: 'Paste repository URL...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: theme.onSurface.withOpacity(0.38),
                  ),
                  filled: true,
                  fillColor: theme.surfaceContainerHighest.withOpacity(0.4),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.outline.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.outline.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 46,
              height: 46,
              child: FilledButton(
                onPressed: _adding ? null : _addRepo,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _adding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: LoadingIndicatorM3E(color: Colors.white),
                      )
                    : const Icon(Icons.add_rounded, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _RepoTile extends StatefulWidget {
  final Repo repo;
  final ItemType itemType;

  const _RepoTile({required this.repo, required this.itemType});

  @override
  State<_RepoTile> createState() => _RepoTileState();
}

class _RepoTileState extends State<_RepoTile> {
  bool _removing = false;

  Future<void> _remove() async {
    setState(() => _removing = true);
    await sourceController.removeRepo(widget.repo, widget.itemType);
    if (mounted) setState(() => _removing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final url = widget.repo.url;
    final name = widget.repo.name;

    return Dismissible(
      key: ValueKey('${widget.repo.url}_${widget.itemType}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.errorContainer.withOpacity(0.6),
        ),
        child: Icon(Broken.trash, color: theme.onErrorContainer, size: 20),
      ),
      onDismissed: (_) => _remove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.surfaceContainerHighest.withOpacity(0.4),
          border: Border.all(
            color: theme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.repo.iconUrl != null &&
                      widget.repo.iconUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.repo.iconUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Broken.folder_open,
                          size: 16,
                          color: theme.primary,
                        ),
                      ),
                    )
                  : Icon(Broken.folder_open, size: 16, color: theme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name != null && name.isNotEmpty) ...[
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.onSurface.withOpacity(0.45),
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _removing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: LoadingIndicatorM3E(color: theme.error),
                  )
                : IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: theme.error.withOpacity(0.7),
                      size: 20,
                    ),
                    onPressed: _remove,
                  ),
          ],
        ),
      ),
    );
  }
}
