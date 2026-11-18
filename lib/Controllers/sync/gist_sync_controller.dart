import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:azyx/Controllers/local_history_controller.dart';
import 'package:azyx/Controllers/sync/gist_sync_service.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Database/isar_models/category.dart';
import 'package:azyx/Database/isar_models/key_value.dart';
import 'package:azyx/Database/isar_models/local_history_item.dart';
import 'package:azyx/Database/isar_models/offline_item.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
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

  final syncHistory = true.obs;
  final syncCategories = true.obs;

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
      syncHistory.value = SyncKeys.gistSyncHistory.get<bool>(true);
      syncCategories.value = SyncKeys.gistSyncCategories.get<bool>(true);

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

  void setSyncHistory(bool val) {
    syncHistory.value = val;
    SyncKeys.gistSyncHistory.set(val);
  }

  void setSyncCategories(bool val) {
    syncCategories.value = val;
    SyncKeys.gistSyncCategories.set(val);
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

      final cloudFiles = await _service.downloadAllCloudFiles();
      log('[GistSyncController] Fetched ${cloudFiles.length} cloud files from Gist: ${cloudFiles.keys.toList()}');
      final Map<String, String> uploadPayload = {};

      if (syncHistory.value) {
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
          final localTitleValid =
              local.title != null &&
              local.title!.isNotEmpty &&
              !local.title!.startsWith('Media ');

          if (existingCloud == null ||
              localUpdated > existingCloud.updatedAt ||
              (localTitleValid &&
                  (existingCloud.title == null ||
                      existingCloud.title!.startsWith('Media ')))) {
            mergedEntries[key] = GistProgressEntry(
              mediaId: local.mediaId.toString(),
              mediaType: typeStr,
              serviceType: 'AzyX',
              title: localTitleValid ? local.title : existingCloud?.title,
              image: local.image ?? existingCloud?.image,
              link: local.link ?? existingCloud?.link,
              sourceName: local.sourceName ?? existingCloud?.sourceName,
              sourceId: local.sourceId ?? existingCloud?.sourceId,
              mediaData: local.mediaData?.toJson() ?? existingCloud?.mediaData,
              episodeNumber: local.progress ?? existingCloud?.episodeNumber,
              timestampMs: local.currentTimeSeconds != null
                  ? (local.currentTimeSeconds! * 1000)
                  : existingCloud?.timestampMs,
              durationMs: local.totalDurationSeconds != null
                  ? (local.totalDurationSeconds! * 1000)
                  : existingCloud?.durationMs,
              pageNumber: local.currentPage ?? existingCloud?.pageNumber,
              updatedAt: localUpdated > 0
                  ? localUpdated
                  : (existingCloud?.updatedAt ??
                        DateTime.now().millisecondsSinceEpoch),
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

            final updatedItem = existing ?? LocalHistoryItem();
            updatedItem.mediaId = mId;
            updatedItem.mediaType = hType;

            final entryTitleValid =
                entry.title != null &&
                entry.title!.isNotEmpty &&
                !entry.title!.startsWith('Media ');
            if (entryTitleValid) {
              updatedItem.title = entry.title;
            } else if (existing?.title != null &&
                !existing!.title!.startsWith('Media ')) {
              updatedItem.title = existing!.title;
            } else if (entry.title != null && entry.title!.isNotEmpty) {
              updatedItem.title = entry.title;
            } else {
              updatedItem.title = "Media $mId";
            }

            if (entry.image != null && entry.image!.isNotEmpty) {
              updatedItem.image = entry.image;
            } else {
              updatedItem.image = existing?.image;
            }

            if (entry.link != null && entry.link!.isNotEmpty) {
              updatedItem.link = entry.link;
            } else {
              updatedItem.link = existing?.link;
            }

            if (entry.sourceName != null && entry.sourceName!.isNotEmpty) {
              updatedItem.sourceName = entry.sourceName;
            } else {
              updatedItem.sourceName = existing?.sourceName;
            }

            if (entry.sourceId != null && entry.sourceId!.isNotEmpty) {
              updatedItem.sourceId = entry.sourceId;
            } else {
              updatedItem.sourceId = existing?.sourceId;
            }

            if (entry.episodeNumber != null) {
              updatedItem.progress = entry.episodeNumber;
            } else {
              updatedItem.progress = existing?.progress;
            }

            if (entry.pageNumber != null) {
              updatedItem.currentPage = entry.pageNumber;
            } else {
              updatedItem.currentPage = existing?.currentPage;
            }

            if (entry.timestampMs != null) {
              updatedItem.currentTimeSeconds = entry.timestampMs! ~/ 1000;
            } else {
              updatedItem.currentTimeSeconds = existing?.currentTimeSeconds;
            }

            if (entry.durationMs != null) {
              updatedItem.totalDurationSeconds = entry.durationMs! ~/ 1000;
            } else {
              updatedItem.totalDurationSeconds = existing?.totalDurationSeconds;
            }

            updatedItem.lastWatched = DateTime.fromMillisecondsSinceEpoch(
              entry.updatedAt,
            );

            if (entry.mediaData != null) {
              try {
                updatedItem.mediaData = AnilistMediaData.fromJson(
                  entry.mediaData!,
                );
              } catch (_) {}
            } else {
              updatedItem.mediaData = existing?.mediaData;
            }

            isar.localHistoryItems.putSync(updatedItem);
          });
        });

        final Map<String, dynamic> rawMap = {};
        mergedEntries.forEach((k, v) => rawMap[k] = v.toJson());
        uploadPayload['azyx_progress.json'] = jsonEncode(rawMap);
      }

      if (syncCategories.value) {
        log('[GistSync] Starting category & list sync...');
        final Map<String, Category> mergedCategories = {};

        final localCategories = isar.categorys.where().findAllSync();
        for (var cat in localCategories) {
          if (cat.name != null && cat.name!.isNotEmpty) {
            final key = '${cat.isManga ? "manga" : "anime"}_${cat.name!.toLowerCase()}';
            mergedCategories[key] = Category(
              name: cat.name,
              isManga: cat.isManga,
              anilistIds: List<String>.from(cat.anilistIds ?? []),
            );
          }
        }
        log('[GistSync] Loaded ${localCategories.length} local categories');

        for (final fn in [
          'azyx_categories.json',
          'anymex_categories.json',
          'categories.json',
          'azyx_lists.json',
          'anymex_lists.json',
          'custom_lists.json',
        ]) {
          if (cloudFiles.containsKey(fn)) {
            final catContent = cloudFiles[fn];
            if (catContent != null && catContent.trim().isNotEmpty) {
              log('[GistSync] Found cloud category file: $fn (${catContent.length} bytes)');
              try {
                final dynamic parsed = jsonDecode(catContent);
                _parseCategoriesFromRaw(parsed, mergedCategories);
              } catch (e, stack) {
                log('[GistSync] Error parsing category file $fn: $e\n$stack');
              }
            }
          }
        }

        log('[GistSync] Merged total ${mergedCategories.length} categories to write to Isar DB');

        isar.writeTxnSync(() {
          for (var cat in mergedCategories.values) {
            final existingLocal = isar.categorys
                .filter()
                .nameEqualTo(cat.name)
                .isMangaEqualTo(cat.isManga)
                .findFirstSync();
            final target = existingLocal ?? Category(name: cat.name, isManga: cat.isManga);
            target.anilistIds = cat.anilistIds;
            isar.categorys.putSync(target);
            log('[GistSync] Saved category "${cat.name}" (${cat.isManga ? "Manga" : "Anime"}) with ${cat.anilistIds?.length ?? 0} items');
          }
        });

        final updatedLocalCats = isar.categorys.where().findAllSync();
        uploadPayload['azyx_categories.json'] = jsonEncode(
          updatedLocalCats.map((c) => c.toJson()).toList(),
        );
      }

      if (uploadPayload.isNotEmpty) {
        await _service.uploadCloudFiles(uploadPayload);
      }

      if (Get.isRegistered<LocalHistoryController>()) {
        Get.find<LocalHistoryController>().refreshHistory();
      }

      lastSyncTime.value = DateTime.now();
      lastSyncStatus.value = 'Synced successfully';

      Get.snackbar(
        'Cloud Sync',
        'Watch & Read progress and categories synced with GitHub Gist!',
      );
    } catch (e) {
      lastSyncStatus.value = 'Sync failed';
      log('[GistSyncController] syncNow error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  void _parseCategoriesFromRaw(dynamic parsed, Map<String, Category> mergedCategories) {
    if (parsed is List) {
      for (var item in parsed) {
        _parseSingleCategoryItem(item, mergedCategories);
      }
    } else if (parsed is Map) {
      if (parsed.containsKey('categories') && parsed['categories'] is List) {
        _parseCategoriesFromRaw(parsed['categories'], mergedCategories);
      }
      if (parsed.containsKey('lists') && parsed['lists'] is List) {
        _parseCategoriesFromRaw(parsed['lists'], mergedCategories);
      }

      parsed.forEach((k, v) {
        if (k == 'categories' || k == 'lists') return;
        if (v is List) {
          final catName = k.toString().trim();
          if (catName.isNotEmpty) {
            final isManga = catName.toLowerCase().contains('manga');
            final key = '${isManga ? "manga" : "anime"}_${catName.toLowerCase()}';
            final ids = v.map((e) => e.toString()).toList();
            final existing = mergedCategories[key];
            if (existing != null) {
              final combined = {...(existing.anilistIds ?? []), ...ids}.toList();
              existing.anilistIds = combined;
            } else {
              mergedCategories[key] = Category(name: catName, isManga: isManga, anilistIds: ids);
            }
          }
        } else if (v is Map) {
          _parseSingleCategoryItem(v, mergedCategories, fallbackName: k.toString());
        }
      });
    }
  }

  void _parseSingleCategoryItem(dynamic item, Map<String, Category> mergedCategories, {String? fallbackName}) {
    if (item is! Map) return;
    final map = Map<String, dynamic>.from(item);
    final name = (map['name'] ?? map['title'] ?? map['categoryName'] ?? map['category'] ?? fallbackName)?.toString().trim();
    if (name == null || name.isEmpty) return;

    final rawIds = map['anilistIds'] ?? map['ids'] ?? map['mediaIds'] ?? map['items'] ?? map['list'] ?? [];
    final List<String> idsList = [];
    if (rawIds is List) {
      for (var e in rawIds) {
        if (e != null) idsList.add(e.toString());
      }
    }

    final bool isManga = map['isManga'] == true ||
        (map['type']?.toString().toUpperCase() == 'MANGA') ||
        (map['mediaType']?.toString().toUpperCase() == 'MANGA') ||
        name.toLowerCase().contains('manga');

    final key = '${isManga ? "manga" : "anime"}_${name.toLowerCase()}';
    final existing = mergedCategories[key];
    if (existing != null) {
      final combined = {...(existing.anilistIds ?? []), ...idsList}.toList();
      existing.anilistIds = combined;
    } else {
      mergedCategories[key] = Category(
        name: name,
        isManga: isManga,
        anilistIds: idsList,
      );
    }
  }
}
