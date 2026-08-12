import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/sync/gist_sync_service.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GithubOAuthBrowser extends InAppBrowser {
  final Function(String code) onCodeReceived;
  bool _handled = false;

  GithubOAuthBrowser({required this.onCodeReceived});

  @override
  void onLoadStart(WebUri? url) {
    super.onLoadStart(url);
    _checkUrl(url);
  }

  @override
  void onLoadStop(WebUri? url) {
    super.onLoadStop(url);
    _checkUrl(url);
  }

  @override
  FutureOr<NavigationActionPolicy?> shouldOverrideUrlLoading(
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url;
    if (url != null) {
      final code = url.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        if (!_handled) {
          _handled = true;
          close();
          onCodeReceived(code);
        }
        return NavigationActionPolicy.CANCEL;
      }
    }
    return super.shouldOverrideUrlLoading(navigationAction);
  }

  void _checkUrl(WebUri? url) {
    if (_handled || url == null) return;
    final code = url.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      _handled = true;
      close();
      onCodeReceived(code);
    }
  }
}

class GistSyncController extends GetxController {
  final isLoggedIn = false.obs;
  final isAuthenticating = false.obs;
  final isSyncing = false.obs;
  final githubUsername = RxnString();
  final githubDisplayName = RxnString();
  final githubAvatarUrl = RxnString();
  final lastSyncTime = Rxn<DateTime>();
  final lastSyncStatus = RxnString();

  final _service = GistSyncService();

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  String _envValue(String primary, [List<String> fallbacks = const []]) {
    for (final key in [primary, ...fallbacks]) {
      final value = (dotenv.env[key] ?? '').trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _restoreSession() async {
    try {
      final token = SyncKeys.gistGithubToken.get<String>('');
      final username = SyncKeys.gistGithubUsername.get<String>('');
      if (token.isNotEmpty) {
        _service.setToken(token);
        isLoggedIn.value = true;
        githubUsername.value = username.isEmpty ? null : username;
        log(
          '[GistSyncController] Restored session for ${username.isEmpty ? 'GitHub user' : username}',
        );
        _fetchGithubProfile(token);
      }
    } catch (e) {
      log('[GistSyncController] _restoreSession error: $e');
    }
  }

  Future<void> login(
    BuildContext context, {
    Function()? onFallbackDialog,
  }) async {
    final clientId = _envValue('GIT_CLIENT_ID', ['GITHUB_CLIENT_ID']);
    final clientSecret = _envValue('GIT_CLIENT_SECRET', [
      'GITHUB_CLIENT_SECRET',
    ]);

    if (clientId.isNotEmpty) {
      isAuthenticating.value = true;
      try {
        final authorizeParams = <String, String>{
          'client_id': clientId,
          'scope': 'gist',
          'redirect_uri': 'azyx://callback',
        };
        final url = Uri.https(
          'github.com',
          '/login/oauth/authorize',
          authorizeParams,
        );

        final browser = GithubOAuthBrowser(
          onCodeReceived: (code) async {
            await _exchangeCodeForToken(code, clientId, clientSecret);
          },
        );
        await browser.openUrlRequest(
          urlRequest: URLRequest(url: WebUri(url.toString())),
          settings: InAppBrowserClassSettings(
            browserSettings: InAppBrowserSettings(hideUrlBar: false),
          ),
        );
        return;
      } catch (e) {
        log('[GistSyncController] Error during GitHub OAuth: $e');
      } finally {
        isAuthenticating.value = false;
      }
    }

    if (onFallbackDialog != null) {
      onFallbackDialog();
    } else {
      launchUrlString(
        "https://github.com/settings/tokens/new?description=AzyX&scopes=gist",
        mode: LaunchMode.inAppBrowserView,
      );
    }
  }

  Future<void> _exchangeCodeForToken(
    String code,
    String clientId,
    String clientSecret,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;

        if (token != null && token.isNotEmpty) {
          _service.setToken(token);
          SyncKeys.gistGithubToken.set(token);
          isLoggedIn.value = true;
          await _fetchGithubProfile(token);
          await syncNow();
          Get.snackbar(
            'GitHub Connected',
            'Connected as ${githubUsername.value ?? 'GitHub User'}!',
          );
        }
      }
    } catch (e) {
      log('[GistSyncController] Token exchange error: $e');
    }
  }

  Future<bool> loginWithToken(String token) async {
    if (token.trim().isEmpty) return false;
    try {
      isSyncing.value = true;
      _service.setToken(token.trim());
      final username = await _fetchGithubProfile(token.trim());
      if (username != null) {
        SyncKeys.gistGithubToken.set(token.trim());
        SyncKeys.gistGithubUsername.set(username);
        isLoggedIn.value = true;
        githubUsername.value = username;
        Get.snackbar('GitHub Connected', 'Connected as $username!');
        await syncNow();
        return true;
      } else {
        _service.clear();
        Get.snackbar('Auth Failed', 'Invalid token or network error.');
        return false;
      }
    } catch (e) {
      _service.clear();
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<String?> _fetchGithubProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
        },
      );

      if (response.statusCode == 200) {
        final raw = json.decode(response.body) as Map<String, dynamic>;
        final username = raw['login']?.toString();
        final avatar = raw['avatar_url']?.toString();
        final name = raw['name']?.toString();

        if (username != null) {
          githubUsername.value = username;
          SyncKeys.gistGithubUsername.set(username);
        }
        githubDisplayName.value = name;
        githubAvatarUrl.value = avatar;
        return username;
      }
    } catch (e) {
      log('[GistSyncController] _fetchGithubProfile error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    _service.clear();
    SyncKeys.gistGithubToken.set('');
    SyncKeys.gistGithubUsername.set('');
    isLoggedIn.value = false;
    githubUsername.value = null;
    githubDisplayName.value = null;
    githubAvatarUrl.value = null;
    lastSyncTime.value = null;
    lastSyncStatus.value = null;
    Get.snackbar('Disconnected', 'GitHub Gist sync disconnected.');
  }

  Future<void> syncNow() async {
    if (!isLoggedIn.value || !_service.isReady) return;
    try {
      isSyncing.value = true;
      lastSyncStatus.value = 'Syncing...';

      final cloudEntries = await _service.downloadCloudData();
      final localItems = isar.localHistoryItems.where().findAllSync();

      final Map<String, GistProgressEntry> mergedEntries = Map.from(
        cloudEntries,
      );

      for (var local in localItems) {
        if (local.mediaId == null) continue;
        final isManga = local.mediaType == HistoryMediaType.manga;
        final typeStr = isManga ? 'MANGA' : 'ANIME';
        final key = '${typeStr.toLowerCase()}_${local.mediaId}';
        final altKey = local.mediaId.toString();
        final localUpdated = local.lastWatched?.millisecondsSinceEpoch ?? 0;

        final existingCloud = mergedEntries[key] ?? mergedEntries[altKey];
        if (existingCloud == null || localUpdated > existingCloud.updatedAt) {
          mergedEntries[key] = GistProgressEntry(
            mediaId: local.mediaId.toString(),
            mediaType: typeStr,
            serviceType: 'AzyX',
            episodeNumber: local.progress,
            timestampMs: local.currentTimeSeconds != null
                ? (local.currentTimeSeconds! * 1000)
                : null,
            durationMs: local.totalDurationSeconds != null
                ? (local.totalDurationSeconds! * 1000)
                : null,
            pageNumber: local.currentPage,
            updatedAt: localUpdated > 0
                ? localUpdated
                : DateTime.now().millisecondsSinceEpoch,
          );
        }
      }

      isar.writeTxnSync(() {
        mergedEntries.forEach((key, entry) {
          final cleanIdStr = entry.mediaId.contains('_')
              ? entry.mediaId.split('_').last
              : entry.mediaId;
          final mId = int.tryParse(cleanIdStr);
          if (mId == null) return;

          final existing = isar.localHistoryItems
              .filter()
              .mediaIdEqualTo(mId)
              .findFirstSync();
          final isManga = entry.mediaType.toUpperCase() == 'MANGA';
          final hType = isManga
              ? HistoryMediaType.manga
              : HistoryMediaType.anime;

          final updatedItem = (existing ?? LocalHistoryItem())
            ..mediaId = mId
            ..mediaType = hType
            ..progress = entry.episodeNumber ?? existing?.progress
            ..currentPage = entry.pageNumber ?? existing?.currentPage
            ..currentTimeSeconds = entry.timestampMs != null
                ? (entry.timestampMs! ~/ 1000)
                : existing?.currentTimeSeconds
            ..totalDurationSeconds = entry.durationMs != null
                ? (entry.durationMs! ~/ 1000)
                : existing?.totalDurationSeconds
            ..lastWatched = DateTime.fromMillisecondsSinceEpoch(
              entry.updatedAt,
            );

          if (existing == null) {
            updatedItem.title = "Media $mId";
          }

          isar.localHistoryItems.putSync(updatedItem);
        });
      });

      if (Get.isRegistered<LocalHistoryController>()) {
        Get.find<LocalHistoryController>().refreshHistory();
      }

      await _service.uploadCloudData(mergedEntries);

      lastSyncTime.value = DateTime.now();
      lastSyncStatus.value = 'Synced successfully';
      Get.snackbar(
        'Cloud Sync',
        'Watch & Read progress synced with GitHub Gist!',
      );
    } catch (e) {
      lastSyncStatus.value = 'Sync failed';
      log('[GistSyncController] syncNow error: $e');
    } finally {
      isSyncing.value = false;
    }
  }
}
