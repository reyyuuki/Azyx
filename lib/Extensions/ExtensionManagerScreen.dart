import 'dart:io';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar, SourceExecution;
import 'package:azyx/Controllers/settings_controller.dart';
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/Animation/drop_animation.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExtensionManagerScreen extends StatefulWidget {
  const ExtensionManagerScreen({super.key});

  @override
  State<ExtensionManagerScreen> createState() => _ExtensionManagerScreenState();
}

class _ExtensionManagerScreenState extends State<ExtensionManagerScreen> {
  bool _isRefreshing = false;
  final RxBool _isRuntimeLoaded = true.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRuntime());
  }

  Future<void> _checkRuntime() async {
    final loaded = await AnymeXRuntimeBridge.isLoaded();
    _isRuntimeLoaded.value = loaded;
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await sourceController.fetchRepos();
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: Obx(() {
        final managers = sourceController.extensionManager.managers.toList();

        return Container(
          decoration: BoxDecoration(
            gradient: settingsController.isGradient.value
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.surface,
                      theme.surface.withOpacity(0.8),
                      theme.surfaceContainerLowest,
                    ],
                  )
                : null,
            color: settingsController.isGradient.value ? null : theme.surface,
          ),
          child: BouncePageAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: Platform.isAndroid || Platform.isIOS ? 0 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Broken.arrow_left_2,
                                color: theme.onSurface,
                              ),
                            ),
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AzyXText(
                                    text: "Extension",
                                    fontVariant: FontVariant.bold,
                                    fontSize: 28,
                                  ),
                                  AzyXText(
                                    text: "Manager",
                                    fontVariant: FontVariant.bold,
                                    fontSize: 28,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _isRefreshing ? null : _refresh,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: theme.primary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primary.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.primary,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.primary.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 12,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: _isRefreshing
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.black,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.refresh_rounded,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                      ),
                                      8.height,
                                      AzyXText(
                                        text: "Refresh",
                                        fontVariant: FontVariant.bold,
                                        fontSize: 12,
                                        color: theme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (!_isRuntimeLoaded.value && Platform.isAndroid)
                        Column(
                          children: [_buildRuntimeWarning(theme), 20.height],
                        ),
                      if (managers.isEmpty)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              40.height,
                              Icon(
                                Icons.extension_off_rounded,
                                size: 56,
                                color: theme.onSurface.withOpacity(0.3),
                              ),
                              12.height,
                              AzyXText(
                                text: 'No extension managers loaded',
                                fontSize: 15,
                                color: theme.onSurface.withOpacity(0.6),
                              ),
                            ],
                          ),
                        )
                      else
                        ...managers.map((m) => _ManagerSection(manager: m)),
                    ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.warning_amber_rounded, color: theme.error),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  text: 'Runtime Missing',
                  fontVariant: FontVariant.bold,
                  fontSize: 16,
                  color: theme.error,
                ),
                4.height,
                AzyXText(
                  text: 'AnymeX runtime is not loaded',
                  fontSize: 12,
                  color: theme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              sourceController.checkRuntimeHost();
              if (!mounted) return;
              _isRuntimeLoaded.value =
                  AnymeXRuntimeBridge.controller.isReady.value;
              if (_isRuntimeLoaded.value) {
                await _refresh();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: theme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const AzyXText(
              text: 'Load Runtime',
              fontVariant: FontVariant.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerSection extends StatefulWidget {
  final Extension manager;
  const _ManagerSection({required this.manager});

  @override
  State<_ManagerSection> createState() => _ManagerSectionState();
}

class _ManagerSectionState extends State<_ManagerSection> {
  bool _expanded = false;

  String get _managerName => switch (widget.manager.id) {
    'mangayomi' => 'MangaYomi',
    'aniyomi' => 'Aniyomi',
    'sora' => 'Sora',
    'cloudstream' => 'CloudStream',
    _ => widget.manager.id,
  };

  String get _managerIcon => switch (widget.manager.id) {
    'mangayomi' =>
      'https://raw.githubusercontent.com/kodjodevf/mangayomi/main/assets/app_icons/icon-red.png',
    'aniyomi' => 'https://aniyomi.org/img/logo-128px.png',
    'aniyomi-desktop' => 'https://aniyomi.org/img/logo-128px.png',
    'sora' => 'https://static.everythingmoe.com/icons/sora.png',
    'cloudstream' => 'https://static.everythingmoe.com/icons/cloudstream.png',
    _ => '',
  };

  @override
  void initState() {
    super.initState();
    if (widget.manager.id == 'mangayomi') {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final manager = widget.manager;

    final supportedTypes = <ItemType>[];
    if (manager.supportsAnime) supportedTypes.add(ItemType.anime);
    if (manager.supportsManga) supportedTypes.add(ItemType.manga);
    if (manager.supportsNovel) supportedTypes.add(ItemType.novel);

    if (!Platform.isAndroid &&
        (manager.id == 'aniyomi' || manager.id == 'cloudstream')) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _expanded
            ? theme.primary.withOpacity(0.05)
            : theme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _expanded
              ? theme.primary.withOpacity(0.3)
              : theme.outline.withOpacity(0.1),
          width: _expanded ? 2 : 1,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: theme.primary.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _expanded
                            ? theme.primary
                            : theme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _managerIcon.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _managerIcon,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.extension_rounded,
                                  color: _expanded
                                      ? Colors.black
                                      : theme.onSurface.withOpacity(0.7),
                                  size: 24,
                                ),
                              )
                            : Icon(
                                Icons.extension_rounded,
                                color: _expanded
                                    ? Colors.black
                                    : theme.onSurface.withOpacity(0.7),
                                size: 24,
                              ),
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AzyXText(
                            text: _managerName,
                            fontVariant: FontVariant.bold,
                            fontSize: 16,
                            color: _expanded ? theme.primary : theme.onSurface,
                          ),
                          4.height,
                          Text(
                            supportedTypes.map((t) => t.toString()).join(' · '),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.onSurface.withOpacity(0.6),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _expanded ? theme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _expanded
                              ? Colors.black
                              : theme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  Divider(height: 1, color: theme.outline.withOpacity(0.1)),
                  for (final type in supportedTypes)
                    _RepoSection(manager: manager, itemType: type),
                  10.height,
                ],
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon, size: 16, color: theme.primary),
              8.width,
              AzyXText(
                text: widget.itemType.toString() + ' Repositories',
                fontVariant: FontVariant.bold,
                fontSize: 13,
                color: theme.primary,
              ),
            ],
          ),
          12.height,
          Obx(() {
            final repos = widget.manager.getReposRx(widget.itemType).value;
            if (repos.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AzyXText(
                  text: 'No repos added yet',
                  fontSize: 12,
                  color: theme.onSurface.withOpacity(0.4),
                ),
              );
            }
            return Column(
              children: repos
                  .map(
                    (repo) => _RepoTile(repo: repo, itemType: widget.itemType),
                  )
                  .toList(),
            );
          }),
          12.height,
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.surfaceContainerHighest.withOpacity(0.3),
                    border: Border.all(
                      color: theme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    onSubmitted: (_) => _addRepo(),
                    decoration: InputDecoration(
                      hintText: 'Paste repo URL...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: theme.onSurface.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              8.width,
              GestureDetector(
                onTap: _adding ? null : _addRepo,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: _adding
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.add_rounded, color: Colors.black),
                ),
              ),
            ],
          ),
          16.height,
        ],
      ),
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
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.errorContainer.withOpacity(0.7),
        ),
        child: Icon(Broken.trash, color: theme.onErrorContainer),
      ),
      onDismissed: (_) => _remove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.surfaceContainerHighest.withOpacity(0.3),
          border: Border.all(color: theme.outline.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  widget.repo.iconUrl != null && widget.repo.iconUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.repo.iconUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Broken.folder_open,
                          size: 18,
                          color: theme.primary,
                        ),
                      ),
                    )
                  : Icon(Broken.folder_open, size: 18, color: theme.primary),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name != null && name.isNotEmpty) ...[
                    AzyXText(
                      text: name,
                      fontVariant: FontVariant.bold,
                      fontSize: 13,
                    ),
                    2.height,
                  ],
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.onSurface.withOpacity(0.5),
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            8.width,
            _removing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.error,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Broken.minus_cirlce,
                      color: theme.error,
                      size: 20,
                    ),
                    onPressed: _remove,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.errorContainer.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
