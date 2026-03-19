import 'dart:io';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/main.dart';
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
        ...AnymeXExtensionBridge.isarSchema,
        KeyValueSchema,
        CategorySchema,
        OfflineItemSchema,
      ],
      directory: dir!.path,
      name: "AzyX",
      inspector: true,
    );
    await AnymeXExtensionBridge.init(
      isarInstance: isar,
      getDirectory:
          ({subPath, useCustomPath = false, useSystemPath = false}) async {
            final base = await getApplicationSupportDirectory();
            final dir = subPath != null
                ? Directory('${base.path}/$subPath')
                : base;
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            return dir;
          },
    );
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
