import 'dart:developer';
import 'dart:io';

import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/storage_provider.dart';
import 'package:anymex_extension_bridge/ExtensionManager.dart';
import 'package:anymex_extension_bridge/Models/Source.dart';
import 'package:anymex_extension_bridge/extension_bridge.dart';
import 'package:get/get.dart';

import '../../main.dart' as m;

final sourceController = Get.put(SourceController());

class SourceController extends GetxController {
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

  final RxString _activeAnimeRepo = ''.obs;
  final RxString _activeMangaRepo = ''.obs;
  final RxString _activeAniyomiAnimeRepo = ''.obs;
  final RxString _activeAniyomiMangaRepo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() async {
    await initExtensions();
  }

  Future<void> initExtensions({bool refresh = true}) async {
    try {
      await sortExtensions();
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

      _activeAnimeRepo.value = SourceKeys.activeAnimeRepo.get<String>('');
      _activeMangaRepo.value = SourceKeys.activeMangaRepo.get<String>('');
      _activeAniyomiAnimeRepo.value = SourceKeys.activeAniyomiAnimeRepo
          .get<String>('');
      _activeAniyomiMangaRepo.value = SourceKeys.activeAniyomiMangaRepo
          .get<String>('');

      if (_activeAnimeRepo.value.isNotEmpty ||
          _activeAniyomiAnimeRepo.value.isNotEmpty ||
          _activeMangaRepo.value.isNotEmpty ||
          _activeAniyomiMangaRepo.value.isNotEmpty) {
        shouldShowExtensions.value = true;
      }

      log('Extensions initialized.');
    } catch (e) {
      log('Error initializing extensions: $e');
    }
  }

  Future<void> fetchRepos() async {
    final extenionTypes = ExtensionType.values.where((e) {
      if (!Platform.isAndroid) {
        if (e == ExtensionType.aniyomi) {
          return false;
        }
      }
      return true;
    }).toList();
    log(extenionTypes.length.toString());

    for (var type in extenionTypes) {
      await type.getManager().fetchAvailableAnimeExtensions([
        getAnimeRepo(type),
      ]);
      await type.getManager().fetchAvailableMangaExtensions([
        getMangaRepo(type),
      ]);
    }
    await initExtensions();
  }

  Future<void> sortExtensions() async {
    log('ext: ${_activeAnimeRepo.value}');
    final extenionTypes = ExtensionType.values.where((e) {
      if (!Platform.isAndroid && e == ExtensionType.aniyomi) return false;
      return true;
    }).toList();

    final newInstalledExtensions = <Source>[];
    final newInstalledMangaExtensions = <Source>[];
    final newInstalledNovelExtensions = <Source>[];
    final newAvailableExtensions = <Source>[];
    final newAvailableMangaExtensions = <Source>[];
    final newAvailableNovelExtensions = <Source>[];

    for (final type in extenionTypes) {
      final manager = type.getManager();
      newInstalledExtensions.addAll(
        await manager.getInstalledAnimeExtensions(),
      );
      newInstalledMangaExtensions.addAll(
        await manager.getInstalledMangaExtensions(),
      );
      newInstalledNovelExtensions.addAll(
        await manager.getInstalledNovelExtensions(),
      );
      newAvailableExtensions.addAll(manager.availableAnimeExtensions.value);
      newAvailableMangaExtensions.addAll(
        manager.availableMangaExtensions.value,
      );
      newAvailableNovelExtensions.addAll(
        manager.availableNovelExtensions.value,
      );
    }

    log('ext: ${newAvailableExtensions.length}');

    installedExtensions.value = newInstalledExtensions;
    installedMangaExtensions.value = newInstalledMangaExtensions;
    installedNovelExtensions.value = newInstalledNovelExtensions;
    availableExtensions.value = newAvailableExtensions;
    availableMangaExtensions.value = newAvailableMangaExtensions;
    availableNovelExtensions.value = newAvailableNovelExtensions;

    installedDownloaderExtensions.value = newInstalledExtensions
        .where((e) => e.name?.contains('Downloader') ?? false)
        .toList();
  }

  void setActiveSource(Source source) {
    if (source.itemType == ItemType.manga) {
      activeMangaSource.value = source;
      SourceKeys.activeMangaSourceId.set(source.id.toString());
      lastUpdatedSource.value = 'MANGA';
    } else if (source.itemType == ItemType.anime) {
      activeSource.value = source;
      SourceKeys.activeSourceId.set(source.id.toString());
      lastUpdatedSource.value = 'ANIME';
    } else {
      activeSource.value = source;
      SourceKeys.activeNovelSourceId.set(source.id.toString());
      lastUpdatedSource.value = 'NOVEL';
    }
  }

  String getAnimeRepo(ExtensionType type) {
    if (type == ExtensionType.aniyomi) {
      log('Getting Aniyomi repo');
      return activeAniyomiAnimeRepo;
    } else {
      log('Getting Mangayomi repo');
      return activeAnimeRepo;
    }
  }

  String getMangaRepo(ExtensionType type) {
    if (type == ExtensionType.aniyomi) {
      return activeAniyomiMangaRepo;
    } else {
      return activeMangaRepo;
    }
  }

  void saveRepoSettings() {
    SourceKeys.activeAnimeRepo.set(_activeAnimeRepo.value);
    SourceKeys.activeMangaRepo.set(_activeMangaRepo.value);
    SourceKeys.activeAniyomiAnimeRepo.set(_activeAniyomiAnimeRepo.value);
    SourceKeys.activeAniyomiMangaRepo.set(_activeAniyomiMangaRepo.value);
    if (activeAnimeRepo.isNotEmpty ||
        activeAniyomiAnimeRepo.isNotEmpty ||
        activeMangaRepo.isNotEmpty ||
        activeAniyomiMangaRepo.isNotEmpty) {
      shouldShowExtensions.value = true;
    }
  }

  String get activeAniyomiAnimeRepo => _activeAniyomiAnimeRepo.value;
  set activeAniyomiAnimeRepo(String value) {
    _activeAniyomiAnimeRepo.value = value;
    saveRepoSettings();
  }

  String get activeAniyomiMangaRepo => _activeAniyomiMangaRepo.value;
  set activeAniyomiMangaRepo(String value) {
    _activeAniyomiMangaRepo.value = value;
    saveRepoSettings();
  }

  String get activeAnimeRepo => _activeAnimeRepo.value;
  set activeAnimeRepo(String value) {
    _activeAnimeRepo.value = value;
    saveRepoSettings();
  }

  String get activeMangaRepo => _activeMangaRepo.value;
  set activeMangaRepo(String value) {
    _activeMangaRepo.value = value;
    saveRepoSettings();
  }

  void setAnimeRepo(String val, ExtensionType type) {
    if (type == ExtensionType.aniyomi) {
      log('Settings Aniyomi repo: $val');
      activeAniyomiAnimeRepo = val;
    } else {
      log('Settings Mangayomi repo: $val');
      activeAnimeRepo = val;
    }
  }

  void setMangaRepo(String val, ExtensionType type) {
    if (type == ExtensionType.aniyomi) {
      activeAniyomiMangaRepo = val;
    } else {
      activeMangaRepo = val;
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
}
