import 'dart:io';
import 'package:archive/archive.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PlayerShaders {
  static const String shadersZipUrl =
      'https://github.com/RyanYuuki/AnymeX/raw/refs/heads/main/assets/shaders/shaders_new.zip';

  static const Map<String, Map<String, List<String>>> shaderProfiles = {
    'MID-END': {
      'Anime4K: Mode A (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode A+A (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B+B (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C+A (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
    },
    'HIGH-END': {
      'Anime4K: Mode A (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode A+A (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B+B (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C+A (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
    },
  };

  static bool get isEnabled => PlayerKeys.shadersEnabled.get<bool>(false);
  static set isEnabled(bool value) => PlayerKeys.shadersEnabled.set(value);

  static String get selectedTier => PlayerKeys.shaderTier.get<String>('mid');
  static set selectedTier(String tier) => PlayerKeys.shaderTier.set(tier);

  static String get selectedShader =>
      PlayerKeys.selectedShader.get<String>('Default');
  static set selectedShader(String shader) =>
      PlayerKeys.selectedShader.set(shader);

  static String get profileKey =>
      selectedTier == 'high' ? 'HIGH-END' : 'MID-END';

  static List<String> getShaderByName(String configName) {
    final profile = configName.contains('(HQ)')
        ? 'HIGH-END'
        : (configName.contains('(Fast)') ? 'MID-END' : profileKey);
    return shaderProfiles[profile]?[configName] ?? <String>[];
  }

  static Future<Directory> _getAppDirectory() async {
    if (Platform.isAndroid) {
      final primary = Directory('/storage/emulated/0/Azyx');
      try {
        if (!await primary.exists()) {
          await primary.create(recursive: true);
        }
        return primary;
      } catch (_) {}
    }
    final documentsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${documentsDir.path}${Platform.pathSeparator}Azyx');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String> getShaderBasePath() async {
    final dir = await _getAppDirectory();
    final sep = Platform.pathSeparator;
    final shadersDir = Directory('${dir.path}${sep}Shaders');
    if (!await shadersDir.exists()) {
      await shadersDir.create(recursive: true);
    }
    return '${shadersDir.path}$sep';
  }

  static Future<bool> areShadersDownloaded() async {
    try {
      final basePath = await getShaderBasePath();
      final dir = Directory(basePath);
      if (!await dir.exists()) return false;
      final items = await dir.list().toList();
      return items.any((e) => e.path.endsWith('.glsl'));
    } catch (e) {
      Utils.log('areShadersDownloaded error: $e');
      return false;
    }
  }

  static Future<bool> downloadShaders({
    required void Function(double progress, String status) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      onProgress(10.0, 'Downloading shaders…');
      final shadersPath = await getShaderBasePath();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/anime4k_shaders.zip');

      final dio = Dio();
      await dio.download(
        shadersZipUrl,
        tempFile.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(10.0 + (received / total) * 65.0, 'Downloading shaders…');
          }
        },
      );

      onProgress(78.0, 'Extracting files…');
      final bytes = await tempFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.isFile) {
          final fileName = file.name.split('/').last.split('\\').last;
          if (fileName.isEmpty || fileName.startsWith('._')) continue;
          final outFile = File('$shadersPath$fileName');
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>, flush: true);
        }
      }

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      onProgress(100.0, 'Shaders ready');
      return true;
    } catch (e) {
      Utils.log('downloadShaders error: $e');
      return false;
    }
  }

  static Future<void> setShaders(dynamic player, String shaderName) async {
    selectedShader = shaderName;
    if (player?.platform == null) return;

    try {
      if (shaderName.isEmpty || shaderName == 'Default' || !isEnabled) {
        await (player.platform as dynamic).setProperty('glsl-shaders', '');
        Utils.log('Cleared glsl-shaders');
        return;
      }

      final shaderFiles = getShaderByName(shaderName);
      if (shaderFiles.isEmpty) {
        await (player.platform as dynamic).setProperty('glsl-shaders', '');
        return;
      }

      final basePath = await getShaderBasePath();
      final separator = Platform.isWindows ? ';' : ':';
      final validPaths = shaderFiles
          .map((f) => '$basePath$f')
          .where((p) => File(p).existsSync())
          .toList();
      if (validPaths.isEmpty) {
        await (player.platform as dynamic).setProperty('glsl-shaders', '');
        Utils.log('No shader files found on disk for $shaderName');
        return;
      }
      final paths = validPaths.join(separator);
      await (player.platform as dynamic).setProperty('glsl-shaders', paths);
      Utils.log('Applied shaders ($shaderName): $paths');
    } catch (e) {
      Utils.log('setShaders error: $e');
    }
  }

  static Future<void> applySavedShader(dynamic player) async {
    if (!isEnabled) return;
    final saved = selectedShader;
    if (saved.isEmpty || saved == 'Default') return;
    if (!await areShadersDownloaded()) return;
    await setShaders(player, saved);
  }
}
