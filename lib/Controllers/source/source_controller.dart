import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Extensions/plugin_manager.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:get/get.dart';

final sourceController = Get.put(SourceController());

class SourceController extends GetxController {
  Rx<List<Repo>> animeRepos = Rx<List<Repo>>([]);
  Rx<List<Repo>> mangaRepos = Rx<List<Repo>>([]);
  Rx<List<Repo>> novelRepos = Rx<List<Repo>>([]);
  var availableExtensions = <Source>[].obs;
  var availableMangaExtensions = <Source>[].obs;
  var availableNovelExtensions = <Source>[].obs;
  var installedExtensions = <Source>[].obs;
  var activeSource = Rxn<Source>();
  var installedDownloaderExtensions = <Source>[].obs;
  var installedMangaExtensions = <Source>[].obs;
  var activeMangaSource = Rxn<Source>();
  var installedNovelExtensions = <Source>[].obs;
  var activeNovelSource = Rxn<Source>();
  var lastUpdatedSource = "".obs;
  final RxBool shouldShowExtensions = false.obs;
  final RxBool isExtensionManagerInitialized = false.obs;
  final RxInt extensionUpdatesCount = 0.obs;
  bool _isBridgeLoaded = false;
  ExtensionManager? _extensionManager;
  ExtensionManager get extensionManager {
    if (_extensionManager == null) {
      if (Get.isRegistered<ExtensionManager>()) {
        _extensionManager = Get.find<ExtensionManager>();
      } else {
        _extensionManager = Get.put(ExtensionManager());
      }
    }
    return _extensionManager!;
  }

  final Map<String, String> _activeTokens = {};
  void cancelInProgress(String key) {
    if (_activeTokens.containsKey(key)) {
      final token = _activeTokens[key]!;
      final source = switch (key) {
        'search' || 'detail' => activeSource.value,
        'manga_search' || 'manga_detail' => activeMangaSource.value,
        _ => null,
      };
      source?.cancelRequest(token);
      _activeTokens.remove(key);
    }
  }

  void updateToken(String key, String token) {
    cancelInProgress(key);
    _activeTokens[key] = token;
  }

  @override
  void onInit() {
    super.onInit();
    checkRuntimeHost();
  }

  Future<void> checkRuntimeHost() async {
    _initManagerAndBind();
    await AnymeXRuntimeBridge.checkAndInitialize();
    final bool loaded = await AnymeXRuntimeBridge.isLoaded();
    if (!loaded) {
      await AnymeXRuntimeBridge.setupRuntime();
    } else {
      AnymeXRuntimeBridge.controller.setReady(true);
    }
    if (AnymeXRuntimeBridge.controller.isReady.value) {
      _loadBridgeExtensions();
    } else {
      ever(AnymeXRuntimeBridge.controller.isReady, (isReady) {
        if (isReady) {
          _loadBridgeExtensions();
        }
      });
    }
  }

  void _initManagerAndBind() {
    if (isExtensionManagerInitialized.value) return;
    _bindExtensionLists();
    _initialize();
    isExtensionManagerInitialized.value = true;
  }

  void _loadBridgeExtensions() async {
    if (_isBridgeLoaded) return;
    final manager = extensionManager;
    await manager.onRuntimeBridgeInitialization();
    _isBridgeLoaded = true;
    await fetchRepos();
    unawaited(checkBridgeUpdate());
  }

  void _bindExtensionLists() {
    installedExtensions.assignAll(extensionManager.installedAnimeExtensions);
    installedMangaExtensions.assignAll(
      extensionManager.installedMangaExtensions,
    );
    installedNovelExtensions.assignAll(
      extensionManager.installedNovelExtensions,
    );
    availableExtensions.assignAll(extensionManager.availableAnimeExtensions);
    availableMangaExtensions.assignAll(
      extensionManager.availableMangaExtensions,
    );
    availableNovelExtensions.assignAll(
      extensionManager.availableNovelExtensions,
    );
    ever(extensionManager.installedAnimeExtensions, (v) {
      installedExtensions.assignAll(v);
      initExtensions();
    });
    ever(extensionManager.installedMangaExtensions, (v) {
      installedMangaExtensions.assignAll(v);
      initExtensions();
    });
    ever(extensionManager.installedNovelExtensions, (v) {
      installedNovelExtensions.assignAll(v);
      initExtensions();
    });
    ever(
      extensionManager.availableAnimeExtensions,
      (v) => availableExtensions.assignAll(v),
    );
    ever(
      extensionManager.availableMangaExtensions,
      (v) => availableMangaExtensions.assignAll(v),
    );
    ever(
      extensionManager.availableNovelExtensions,
      (v) => availableNovelExtensions.assignAll(v),
    );
  }

  void _initialize() async {
    await fetchRepos();
  }

  Future<void> initExtensions() async {
    try {
      final savedActiveSourceId = SourceKeys.activeSourceId.get<String>('');
      final savedActiveMangaSourceId = SourceKeys.activeMangaSourceId
          .get<String>('');
      final savedActiveNovelSourceId = SourceKeys.activeNovelSourceId
          .get<String>('');
      activeSource.value = installedExtensions.firstWhereOrNull(
        (source) => source.id.toString() == savedActiveSourceId,
      );
      activeMangaSource.value = installedMangaExtensions.firstWhereOrNull(
        (source) => source.id.toString() == savedActiveMangaSourceId,
      );
      activeNovelSource.value = installedNovelExtensions.firstWhereOrNull(
        (source) => source.id.toString() == savedActiveNovelSourceId,
      );
      activeSource.value ??= installedExtensions.firstOrNull;
      activeMangaSource.value ??= installedMangaExtensions.firstOrNull;
      activeNovelSource.value ??= installedNovelExtensions.firstOrNull;
      log('ExtensionBridge: Initialized. Active sources set.');
    } catch (e) {
      log('ExtensionBridge: Error during initExtensions: $e');
    }
  }

  Future<void> fetchRepos() async {
    animeRepos.value = extensionManager.getAllRepos(ItemType.anime);
    mangaRepos.value = extensionManager.getAllRepos(ItemType.manga);
    novelRepos.value = extensionManager.getAllRepos(ItemType.novel);
    await extensionManager.refreshExtensions(refreshAvailableSource: true);
    await initExtensions();
    await checkForUpdates();
  }

  void setActiveSource(Source source) {
    if (source.itemType == ItemType.manga) {
      if (activeMangaSource.value?.id != source.id) {
        cancelInProgress('manga_search');
        cancelInProgress('manga_detail');
      }
      activeMangaSource.value = source;
      SourceKeys.activeMangaSourceId.set(source.id.toString());
      lastUpdatedSource.value = 'MANGA';
    } else if (source.itemType == ItemType.anime) {
      if (activeSource.value?.id != source.id) {
        cancelInProgress('search');
        cancelInProgress('detail');
      }
      activeSource.value = source;
      SourceKeys.activeSourceId.set(source.id.toString());
      log("activeSourceId: ${SourceKeys.activeSourceId.get<String>('')}");
      lastUpdatedSource.value = 'ANIME';
    } else {
      activeSource.value = source;
      SourceKeys.activeNovelSourceId.set(source.id.toString());
      lastUpdatedSource.value = 'NOVEL';
    }
  }

  Future<void> addRepo(String url, ItemType itemType, String managerId) async {
    try {
      await extensionManager.addRepo(url, itemType, managerId);
      await fetchRepos();
    } catch (e) {
      azyxSnackBar(e.toString());
    }
  }

  Future<void> removeRepo(Repo repo, ItemType itemType) async {
    try {
      await extensionManager.removeRepo(repo, itemType);
      await fetchRepos();
    } catch (e) {
      azyxSnackBar(e.toString());
    }
  }

  List<Source> getInstalledExtensions(ItemType type) {
    switch (type) {
      case ItemType.anime:
        return installedExtensions;
      case ItemType.manga:
        return installedMangaExtensions;
      case ItemType.novel:
        return installedNovelExtensions;
    }
  }

  List<Source> getAvailableExtensions(ItemType type) {
    switch (type) {
      case ItemType.anime:
        return availableExtensions;
      case ItemType.manga:
        return availableMangaExtensions;
      case ItemType.novel:
        return availableNovelExtensions;
    }
  }

  bool isExtensionNewerVersion(String? installed, String? latest) {
    if (installed == null || latest == null) return false;
    if (installed.isEmpty || latest.isEmpty) return false;

    String clean(String v) =>
        v.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');
    final installedClean = clean(installed);
    final latestClean = clean(latest);

    if (installedClean.isEmpty || latestClean.isEmpty) return false;

    final installedParts = installedClean
        .split('.')
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final latestParts = latestClean
        .split('.')
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    final maxLength = installedParts.length > latestParts.length
        ? installedParts.length
        : latestParts.length;

    for (var index = 0; index < maxLength; index++) {
      final installedPart = index < installedParts.length
          ? installedParts[index]
          : 0;
      final latestPart = index < latestParts.length ? latestParts[index] : 0;

      if (latestPart > installedPart) return true;
      if (latestPart < installedPart) return false;
    }
    return false;
  }

  bool extensionHasUpdate(Source source) {
    if (source.hasUpdate == true) return true;
    final type = source.itemType;
    if (type == null) return false;
    final availableList = getAvailableExtensions(type);
    final available = availableList.firstWhereOrNull((s) {
      if (s.runtimeType != source.runtimeType) return false;
      if (s.id?.toString() == source.id?.toString() &&
          s.id != null &&
          s.id!.isNotEmpty) {
        return true;
      }
      return s.name != null && s.name!.isNotEmpty && s.name == source.name;
    });
    if (available == null) return false;
    return isExtensionNewerVersion(source.version, available.version);
  }

  Future<void> checkBridgeUpdate() async {
    try {
      if (Platform.isAndroid &&
          await AnymeXRuntimeBridge.isLoadedFromStorage()) {
        return;
      }
      final manager = PluginManager();
      final latestRelease = await manager.fetchLatestRelease();
      if (latestRelease != null) {
        final installed = manager.installedVersion;
        if (installed.isNotEmpty &&
            manager.isNewerVersion(installed, latestRelease.tagName)) {
          azyxSnackBar(
            'Extension Bridge update available (${latestRelease.tagName}). Open Extension Manager to update.',
          );
        }
      }
    } catch (e) {
      log('Error checking for bridge updates: $e');
    }
  }

  Future<void> checkForUpdates() async {
    try {
      final updatesCount = [
        ...installedExtensions,
        ...installedMangaExtensions,
        ...installedNovelExtensions,
      ].where((s) => extensionHasUpdate(s)).length;
      extensionUpdatesCount.value = updatesCount;
    } catch (e) {
      log('Error checking for updates: $e');
    }
  }
}
