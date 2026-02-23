import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:isar_community/isar.dart';

class KvHelper {
  static T get<T>(String key, T defaultValue) {
    final col = isar.collection<KeyValue>();
    final result = col.filter().keyEqualTo(key).findFirstSync();
    if (result?.value == null) {
      if (defaultValue != null) return defaultValue;
      log("Key not found: $key");
      return null as T;
    }

    final dynamic val = jsonDecode(result!.value!)['val'];

    if (val is num) {
      if (val is double) return val.toDouble() as T;
      if (val is int) return val.toInt() as T;
    }
    if (val is List && val.every((e) => e is String)) {
      return val.cast<String>() as T;
    }

    if (val is Map) {
      return Map<String, dynamic>.from(val) as T;
    }

    if (val is! T) {
      throw Exception('Key $key expected type $T but got ${val.runtimeType}');
    }
    return val;
  }

  static void set<T>(String key, T value) {
    final data = KeyValue()
      ..key = key
      ..value = jsonEncode({'val': value});
    isar.writeTxnSync(() => isar.collection<KeyValue>().put(data));
  }

  static void remove(String key) {
    final col = isar.collection<KeyValue>();
    final data = col.filter().keyEqualTo(key).findFirstSync();
    if (data != null) {
      isar.writeTxnSync(() => col.deleteSync(data.id));
    }
  }
}
