import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

void registerProtocolHandler(
  String scheme, {
  String? executable,
  List<String>? arguments,
}) {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    WindowsProtocolHandler().register(
      scheme,
      executable: executable,
      arguments: arguments,
    );
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    LinuxProtocolHandler().register(
      scheme,
      executable: executable,
      arguments: arguments,
    );
  }
}

void unregisterProtocolHandler(String scheme) {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    WindowsProtocolHandler().unregister(scheme);
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    LinuxProtocolHandler().unregister(scheme);
  }
}

const _hive = HKEY_CURRENT_USER;

class WindowsProtocolHandler extends ProtocolHandler {
  @override
  void register(String scheme, {String? executable, List<String>? arguments}) {
    if (defaultTargetPlatform != TargetPlatform.windows) return;

    final prefix = _regPrefix(scheme);
    final capitalized = scheme[0].toUpperCase() + scheme.substring(1);
    final args = getArguments(arguments).map((a) => _sanitize(a));
    final cmd =
        '${executable ?? Platform.resolvedExecutable} ${args.join(' ')}';

    _regCreateStringKey(_hive, prefix, '', 'URL:$capitalized');
    _regCreateStringKey(_hive, prefix, 'URL Protocol', '');
    _regCreateStringKey(_hive, '$prefix\\shell\\open\\command', '', cmd);
  }

  @override
  void unregister(String scheme) {
    if (defaultTargetPlatform != TargetPlatform.windows) return;

    final txtKey = TEXT(_regPrefix(scheme));
    try {
      RegDeleteTree(HKEY_CURRENT_USER, txtKey);
    } finally {
      free(txtKey);
    }
  }

  String _regPrefix(String scheme) => 'SOFTWARE\\Classes\\$scheme';

  int _regCreateStringKey(int hKey, String key, String valueName, String data) {
    final txtKey = TEXT(key);
    final txtValue = TEXT(valueName);
    final txtData = TEXT(data);

    try {
      return RegSetKeyValue(
        hKey,
        txtKey,
        txtValue,
        REG_SZ,
        txtData,
        txtData.length * 2 + 2,
      );
    } finally {
      free(txtKey);
      free(txtValue);
      free(txtData);
    }
  }

  String _sanitize(String value) {
    value = value.replaceAll(r'%s', '%1').replaceAll(r'"', '\\"');
    return '"$value"';
  }
}

abstract class ProtocolHandler {
  void register(String scheme, {String? executable, List<String>? arguments});
  void unregister(String scheme);

  List<String> getArguments(List<String>? arguments) {
    if (arguments == null) return ['%s'];
    if (arguments.isEmpty && !arguments.any((e) => e.contains('%s'))) {
      throw ArgumentError('arguments must contain at least 1 instance of "%s"');
    }
    return arguments;
  }
}

class LinuxProtocolHandler extends ProtocolHandler {
  @override
  void register(String scheme, {String? executable, List<String>? arguments}) {
    if (defaultTargetPlatform != TargetPlatform.linux) return;
    try {
      final home = Platform.environment['HOME'];
      if (home == null) return;
      final file = File('$home/.local/share/applications/$scheme.desktop');
      file.createSync(recursive: true);

      final exec = executable ?? Platform.resolvedExecutable;
      final args = getArguments(arguments).join(' ');

      file.writeAsStringSync('''
[Desktop Entry]
Name=$scheme
Exec=$exec $args
Type=Application
Terminal=false
MimeType=x-scheme-handler/$scheme;
''');

      Process.runSync('update-desktop-database', [
        '$home/.local/share/applications',
      ]);
    } catch (e) {
      debugPrint('Failed to register protocol handler on Linux: $e');
    }
  }

  @override
  void unregister(String scheme) {
    if (defaultTargetPlatform != TargetPlatform.linux) return;
    try {
      final home = Platform.environment['HOME'];
      if (home == null) return;
      final file = File('$home/.local/share/applications/$scheme.desktop');
      if (file.existsSync()) {
        file.deleteSync();
        Process.runSync('update-desktop-database', [
          '$home/.local/share/applications',
        ]);
      }
    } catch (e) {
      debugPrint('Failed to unregister protocol handler on Linux: $e');
    }
  }
}
