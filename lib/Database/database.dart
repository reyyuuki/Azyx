import 'dart:io';

import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/main.dart';
import 'package:anymex_extension_bridge/Mangayomi/Eval/dart/model/source_preference.dart';
import 'package:anymex_extension_bridge/dartotsu_extension_bridge.dart'
    hide isar;
import 'package:isar_community/isar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Database {
  Future<void> init() async {
    Directory? dir;
    dir = await getDatabaseDirectory();
    isar = Isar.openSync(
      [
        MSourceSchema,
        SourcePreferenceSchema,
        SourcePreferenceStringValueSchema,
        BridgeSettingsSchema,
        KeyValueSchema,
        CategorySchema,
        OfflineItemSchema,
      ],
      directory: dir!.path,
      name: "AzyX",
      inspector: true,
    );
    await DartotsuExtensionBridge().init(isar, 'AzyX');
  }

  Future<bool> requestPermission() async {
    Permission permission = Permission.manageExternalStorage;
    if (Platform.isAndroid) {
      if (await permission.isGranted) {
        return true;
      } else {
        final result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
        return false;
      }
    }
    return true;
  }

  Future<Directory?> getDatabaseDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return dir;
    } else {
      String dbDir = join(dir.path, 'AzyX', 'databases');
      await Directory(dbDir).create(recursive: true);
      return Directory(dbDir);
    }
  }

  Future<Isar> initDB(String? path, {bool inspector = false}) async {
    return isar;
  }
}
