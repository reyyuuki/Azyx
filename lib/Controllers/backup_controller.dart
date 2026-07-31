import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/main.dart';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class BackupController extends GetxController {
  final isBackingUp = false.obs;
  final isRestoring = false.obs;

  static const List<String> authKeyNames = [
    'anilistToken',
    'malAuthToken',
    'malRefreshToken',
    'simklAuthToken',
    'serviceType',
  ];

  void loadBackUp() async {
    await exportBackup();
  }

  Future<File?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'azyx'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<Map<String, dynamic>> buildBackupData({
    bool backupHistory = true,
    bool backupCategories = true,
    bool backupOffline = true,
    bool backupSettings = true,
    bool backupAuthTokens = true,
  }) async {
    final Map<String, dynamic> data = {
      'app': 'AzyX',
      'version': '2.7.0',
      'date': DateFormat('dd MM yyyy hh:mm a').format(DateTime.now()),
    };

    if (backupHistory) {
      final historyItems = isar.localHistoryItems.where().findAllSync();
      data['historyItems'] = historyItems.map((e) => e.toJson()).toList();
      data['historyCount'] = historyItems.length;
    }

    if (backupCategories) {
      final categoryList = isar.categorys.where().findAllSync();
      data['categories'] = categoryList.map((e) => e.toJson()).toList();
      data['categoryCount'] = categoryList.length;
    }

    if (backupOffline) {
      final offlineList = isar.offlineItems.where().findAllSync();
      data['offlineItems'] = offlineList.map((e) => e.toJson()).toList();
      data['offlineCount'] = offlineList.length;
    }

    if (backupSettings || backupAuthTokens) {
      final allKeyValues = isar.keyValues.where().findAllSync();
      final filteredList = allKeyValues
          .where((kv) {
            final isAuth =
                authKeyNames.contains(kv.key) || kv.key.startsWith('AuthKeys_');
            if (isAuth) return backupAuthTokens;
            return backupSettings;
          })
          .map((kv) => {'key': kv.key, 'value': kv.value})
          .toList();
      data['keyValues'] = filteredList;
    }

    return data;
  }

  Future<String?> exportBackup({
    bool backupHistory = true,
    bool backupCategories = true,
    bool backupOffline = true,
    bool backupSettings = true,
    bool backupAuthTokens = true,
  }) async {
    try {
      isBackingUp.value = true;
      final backupData = await buildBackupData(
        backupHistory: backupHistory,
        backupCategories: backupCategories,
        backupOffline: backupOffline,
        backupSettings: backupSettings,
        backupAuthTokens: backupAuthTokens,
      );

      final jsonString = jsonEncode(backupData);
      final fileName =
          'azyx_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      String? outputPath;
      try {
        outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup File',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json', 'azyx'],
        );
      } catch (_) {}

      if (outputPath == null) {
        final dir =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
        outputPath = '${dir.path}/$fileName';
      }

      final file = File(outputPath);
      await file.writeAsString(jsonString);
      Get.snackbar('Backup', 'Backup exported successfully!');
      return outputPath;
    } catch (e) {
      Get.snackbar('Backup Failed', e.toString());
      return null;
    } finally {
      isBackingUp.value = false;
    }
  }

  Future<bool> restoreBackup({
    required File file,
    bool merge = true,
    bool restoreHistory = true,
    bool restoreCategories = true,
    bool restoreOffline = true,
    bool restoreSettings = true,
    bool restoreAuthTokens = true,
  }) async {
    try {
      isRestoring.value = true;
      log('Starting backup restore from file: ${file.path}');
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      int historyRestored = 0;
      int categoriesRestored = 0;
      int offlineRestored = 0;
      int settingsRestored = 0;

      isar.writeTxnSync(() {
        if (restoreHistory && data.containsKey('historyItems')) {
          final historyList = (data['historyItems'] as List)
              .map(
                (e) => LocalHistoryItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
          if (!merge) {
            isar.localHistoryItems.clearSync();
            isar.localHistoryItems.putAllSync(historyList);
            historyRestored = historyList.length;
          } else {
            for (var item in historyList) {
              final existing = isar.localHistoryItems
                  .filter()
                  .mediaIdEqualTo(item.mediaId)
                  .findFirstSync();
              if (existing == null) {
                isar.localHistoryItems.putSync(item);
                historyRestored++;
              }
            }
          }
        }

        if (restoreCategories && data.containsKey('categories')) {
          final categoryList = (data['categories'] as List)
              .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (!merge) {
            isar.categorys.clearSync();
            isar.categorys.putAllSync(categoryList);
            categoriesRestored = categoryList.length;
          } else {
            for (var cat in categoryList) {
              final existing = isar.categorys
                  .filter()
                  .nameEqualTo(cat.name)
                  .findFirstSync();
              if (existing == null) {
                isar.categorys.putSync(cat);
                categoriesRestored++;
              }
            }
          }
        }

        if (restoreOffline && data.containsKey('offlineItems')) {
          final offlineList = (data['offlineItems'] as List)
              .map((e) => OfflineItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (!merge) {
            isar.offlineItems.clearSync();
            isar.offlineItems.putAllSync(offlineList);
            offlineRestored = offlineList.length;
          } else {
            for (var off in offlineList) {
              final existing = isar.offlineItems
                  .filter()
                  .numberEqualTo(off.number)
                  .findFirstSync();
              if (existing == null) {
                isar.offlineItems.putSync(off);
                offlineRestored++;
              }
            }
          }
        }

        if ((restoreSettings || restoreAuthTokens) &&
            data.containsKey('keyValues')) {
          final kvList = List<dynamic>.from(data['keyValues']);
          for (var item in kvList) {
            if (item is Map) {
              final k = item['key'] as String?;
              final v = item['value'] as String?;
              if (k == null || v == null) continue;

              final isAuth =
                  authKeyNames.contains(k) || k.startsWith('AuthKeys_');
              if (isAuth && !restoreAuthTokens) continue;
              if (!isAuth && !restoreSettings) continue;

              final existing = isar.keyValues
                  .filter()
                  .keyEqualTo(k)
                  .findFirstSync();
              final kv = KeyValue()
                ..id = existing?.id ?? Isar.autoIncrement
                ..key = k
                ..value = v;
              isar.keyValues.putSync(kv);
              settingsRestored++;
            }
          }
        }
      });

      log(
        'Backup restored successfully — history: $historyRestored, categories: $categoriesRestored, offline: $offlineRestored, settings: $settingsRestored',
      );

      if (Get.isRegistered<LocalHistoryController>()) {
        Get.find<LocalHistoryController>().refreshHistory();
      }
      if (Get.isRegistered<UiSettingController>()) {
        Get.find<UiSettingController>().reloadSettings();
      }
      if (Get.context != null) {
        try {
          Provider.of<ThemeProvider>(Get.context!, listen: false).reloadSettings();
        } catch (_) {}
      }

      if (restoreSettings || restoreAuthTokens) {
        try {
          if (Get.isRegistered<ServiceHandler>()) {
            final handler = Get.find<ServiceHandler>();
            final typeIndex = AuthKeys.serviceType.get<int>(0);
            handler.serviceType.value =
                ServicesType.values[typeIndex.clamp(0, ServicesType.values.length - 1)];
            await handler.fetchHomePage();
            await handler.autoLogin();
          } else if (Get.isRegistered<AnilistService>()) {
            final service = Get.find<AnilistService>();
            await service.fetchhomeData();
            await service.autoLogin();
          }
        } catch (_) {}
      }

      Get.snackbar(
        'Restore Complete',
        'Restored: $historyRestored history, $categoriesRestored categories, $offlineRestored downloads, $settingsRestored settings',
      );
      return true;
    } catch (e, stackTrace) {
      log('Restore failed error: $e\n$stackTrace');
      Get.snackbar('Restore Failed', e.toString());
      return false;
    } finally {
      isRestoring.value = false;
    }
  }
}
