import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class GistProgressEntry {
  final String mediaId;
  final String? malId;
  final String mediaType;
  final String? serviceType;
  final String? title;
  final String? image;
  final String? link;
  final String? sourceName;
  final String? sourceId;
  final Map<String, dynamic>? mediaData;
  final String? episodeNumber;
  final int? timestampMs;
  final int? durationMs;
  final double? chapterNumber;
  final int? pageNumber;
  final int? totalPages;
  final int updatedAt;

  const GistProgressEntry({
    required this.mediaId,
    this.malId,
    required this.mediaType,
    this.serviceType,
    this.title,
    this.image,
    this.link,
    this.sourceName,
    this.sourceId,
    this.mediaData,
    this.episodeNumber,
    this.timestampMs,
    this.durationMs,
    this.chapterNumber,
    this.pageNumber,
    this.totalPages,
    required this.updatedAt,
  });

  factory GistProgressEntry.fromJson(Map<String, dynamic> j) {
    final rawMediaId = (j['mediaId'] ?? j['id'] ?? j['animeId'] ?? j['mangaId'])?.toString() ?? '';
    final mediaIdClean = rawMediaId.contains('_') ? rawMediaId.split('_').last : rawMediaId;
    final malIdVal = (j['malId'] ?? j['myanimelistId'])?.toString();
    final mediaTypeVal = (j['mediaType'] ?? j['type'] ?? 'ANIME').toString().toUpperCase();
    final serviceTypeVal = (j['serviceType'] ?? j['service'])?.toString();
    final titleVal = (j['title'] ?? j['name'] ?? j['animeTitle'] ?? j['mangaTitle'])?.toString();
    final imageVal = (j['image'] ?? j['coverImage'] ?? j['poster'] ?? j['thumbnail'] ?? j['bannerImage'])?.toString();
    final linkVal = (j['link'] ?? j['url'])?.toString();
    final sourceNameVal = j['sourceName']?.toString();
    final sourceIdVal = j['sourceId']?.toString();
    final mediaDataVal = j['mediaData'] is Map ? Map<String, dynamic>.from(j['mediaData']) : null;
    final epNumVal = (j['episodeNumber'] ?? j['episode'] ?? j['currentEpisode'] ?? j['progress'])?.toString();

    int? timeVal;
    if (j['timestampMs'] != null || j['timestamp'] != null) {
      timeVal = ((j['timestampMs'] ?? j['timestamp']) as num).toInt();
    } else if (j['currentTimeSeconds'] != null) {
      timeVal = ((j['currentTimeSeconds']) as num).toInt() * 1000;
    }

    int? durVal;
    if (j['durationMs'] != null || j['duration'] != null) {
      durVal = ((j['durationMs'] ?? j['duration']) as num).toInt();
    } else if (j['totalDurationSeconds'] != null) {
      durVal = ((j['totalDurationSeconds']) as num).toInt() * 1000;
    }

    double? chVal;
    if (j['chapterNumber'] != null || j['chapter'] != null || j['currentChapter'] != null) {
      chVal = ((j['chapterNumber'] ?? j['chapter'] ?? j['currentChapter']) as num).toDouble();
    }

    int? pageVal;
    if (j['pageNumber'] != null || j['page'] != null || j['currentPage'] != null) {
      pageVal = ((j['pageNumber'] ?? j['page'] ?? j['currentPage']) as num).toInt();
    }

    int? totalPgVal;
    if (j['totalPages'] != null || j['total_pages'] != null) {
      totalPgVal = ((j['totalPages'] ?? j['total_pages']) as num).toInt();
    }

    int updatedVal = DateTime.now().millisecondsSinceEpoch;
    if (j['updatedAt'] != null || j['lastUpdated'] != null || j['timestamp'] != null) {
      updatedVal = ((j['updatedAt'] ?? j['lastUpdated'] ?? j['timestamp']) as num).toInt();
    }

    return GistProgressEntry(
      mediaId: mediaIdClean,
      malId: malIdVal,
      mediaType: mediaTypeVal,
      serviceType: serviceTypeVal,
      title: titleVal,
      image: imageVal,
      link: linkVal,
      sourceName: sourceNameVal,
      sourceId: sourceIdVal,
      mediaData: mediaDataVal,
      episodeNumber: epNumVal,
      timestampMs: timeVal,
      durationMs: durVal,
      chapterNumber: chVal,
      pageNumber: pageVal,
      totalPages: totalPgVal,
      updatedAt: updatedVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'mediaId': mediaId,
        'id': mediaId,
        if (malId != null) 'malId': malId,
        'mediaType': mediaType,
        if (serviceType != null) 'serviceType': serviceType,
        if (title != null) 'title': title,
        if (image != null) 'image': image,
        if (link != null) 'link': link,
        if (sourceName != null) 'sourceName': sourceName,
        if (sourceId != null) 'sourceId': sourceId,
        if (mediaData != null) 'mediaData': mediaData,
        if (episodeNumber != null) 'episodeNumber': episodeNumber,
        if (episodeNumber != null) 'progress': episodeNumber,
        if (timestampMs != null) 'timestampMs': timestampMs,
        if (durationMs != null) 'durationMs': durationMs,
        if (chapterNumber != null) 'chapterNumber': chapterNumber,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (totalPages != null) 'totalPages': totalPages,
        'updatedAt': updatedAt,
        'lastUpdated': updatedAt,
      };
}

class GistSyncService {
  static const List<String> _possibleFileNames = [
    'azyx_progress.json',
    'anymex_progress.json',
    'anymex_sync.json',
    'anymex_watch_history.json',
  ];
  static const String _defaultFileName = 'azyx_progress.json';
  static const String _apiBase = 'https://api.github.com';

  static final GistSyncService _instance = GistSyncService._();
  factory GistSyncService() => _instance;
  GistSyncService._();

  String? _token;
  String? _gistId;
  String _activeFileName = _defaultFileName;

  bool get isReady => _token != null && _token!.isNotEmpty;

  void setToken(String token) {
    _token = token.trim();
    _gistId = null;
    _activeFileName = _defaultFileName;
    log('[GistSyncService] Token configured');
  }

  void clear() {
    _token = null;
    _gistId = null;
    _activeFileName = _defaultFileName;
    log('[GistSyncService] Cleared session');
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json',
      };

  Future<String?> fetchGithubUsername() async {
    if (!isReady) return null;
    try {
      final resp = await http.get(Uri.parse('$_apiBase/user'), headers: _headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['login'] as String?;
      }
    } catch (e) {
      log('[GistSyncService] fetchGithubUsername error: $e');
    }
    return null;
  }

  Future<String?> _findExistingGistId() async {
    if (_gistId != null) return _gistId;
    try {
      final resp = await http.get(Uri.parse('$_apiBase/gists?per_page=100'), headers: _headers);
      if (resp.statusCode != 200) {
        log('[GistSyncService] _findExistingGistId HTTP error ${resp.statusCode}: ${resp.body}');
        return null;
      }

      final list = jsonDecode(resp.body) as List<dynamic>;
      log('[GistSyncService] Fetched ${list.length} total Gists for GitHub user');
      for (final g in list) {
        final files = g['files'] as Map<String, dynamic>? ?? {};
        for (final fn in [
          'azyx_categories.json',
          'azyx_progress.json',
          'anymex_progress.json',
          'anymex_sync.json',
          'anymex_watch_history.json',
        ]) {
          if (files.containsKey(fn)) {
            _gistId = g['id'] as String;
            _activeFileName = files.containsKey(_defaultFileName) ? _defaultFileName : fn;
            log('[GistSyncService] Selected Gist ID: $_gistId matching "$fn" with files: ${files.keys.toList()}');
            return _gistId;
          }
        }
      }
      log('[GistSyncService] No existing AzyX Gist found in ${list.length} Gists');
    } catch (e) {
      log('[GistSyncService] _findExistingGistId exception: $e');
    }
    return null;
  }

  Future<String?> _ensureGistId() async {
    final existing = await _findExistingGistId();
    if (existing != null) return existing;
    try {
      log('[GistSyncService] Creating new Gist for user...');
      final resp = await http.post(
        Uri.parse('$_apiBase/gists'),
        headers: _headers,
        body: jsonEncode({
          'description': 'AzyX progress cloud sync',
          'public': false,
          'files': {
            _defaultFileName: {'content': '{}'},
          },
        }),
      );
      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        _gistId = data['id'] as String;
        _activeFileName = _defaultFileName;
        log('[GistSyncService] Created new Gist ID: $_gistId');
        return _gistId;
      } else {
        log('[GistSyncService] Create Gist HTTP error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      log('[GistSyncService] _ensureGistId exception: $e');
    }
    return null;
  }

  Future<Map<String, GistProgressEntry>> downloadCloudData() async {
    if (!isReady) {
      log('[GistSyncService] downloadCloudData abort: token not ready');
      return {};
    }
    try {
      final gistId = await _ensureGistId();
      if (gistId == null) {
        log('[GistSyncService] downloadCloudData abort: gistId is null');
        return {};
      }

      final resp = await http.get(Uri.parse('$_apiBase/gists/$gistId'), headers: _headers);
      if (resp.statusCode == 404) {
        log('[GistSyncService] Gist ID $gistId returned 404. Resetting cached Gist ID.');
        _gistId = null;
        final retryId = await _ensureGistId();
        if (retryId == null) return {};
        final retryResp = await http.get(Uri.parse('$_apiBase/gists/$retryId'), headers: _headers);
        if (retryResp.statusCode != 200) return {};
        final data = jsonDecode(retryResp.body) as Map<String, dynamic>;
        return _parseProgressFromFiles(data['files'] as Map<String, dynamic>?);
      }
      if (resp.statusCode != 200) {
        log('[GistSyncService] downloadCloudData HTTP error ${resp.statusCode}: ${resp.body}');
        return {};
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return _parseProgressFromFiles(data['files'] as Map<String, dynamic>?);
    } catch (e) {
      log('[GistSyncService] downloadCloudData error: $e');
      return {};
    }
  }

  Future<Map<String, GistProgressEntry>> _parseProgressFromFiles(Map<String, dynamic>? filesMap) async {
    if (filesMap == null) return {};

    String? content;
    Map<String, dynamic>? targetFileData;
    if (filesMap.containsKey(_activeFileName)) {
      targetFileData = filesMap[_activeFileName] as Map<String, dynamic>?;
    } else {
      for (final fn in _possibleFileNames) {
        if (filesMap.containsKey(fn)) {
          _activeFileName = fn;
          targetFileData = filesMap[fn] as Map<String, dynamic>?;
          break;
        }
      }
    }

    if (targetFileData != null) {
      content = targetFileData['content'] as String?;
      if ((content == null || content.isEmpty || targetFileData['truncated'] == true) && targetFileData['raw_url'] != null) {
        try {
          log('[GistSyncService] Downloading raw_url for progress file $_activeFileName');
          final rawResp = await http.get(Uri.parse(targetFileData['raw_url'] as String));
          if (rawResp.statusCode == 200) {
            content = rawResp.body;
          }
        } catch (e) {
          log('[GistSyncService] Error fetching raw_url for progress: $e');
        }
      }
    }

    if (content == null || content.trim().isEmpty) return {};

    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final Map<String, GistProgressEntry> result = {};
    parsed.forEach((key, val) {
      if (val is Map) {
        result[key] = GistProgressEntry.fromJson(Map<String, dynamic>.from(val));
      }
    });
    return result;
  }

  Future<bool> uploadCloudData(Map<String, GistProgressEntry> entries) async {
    if (!isReady) return false;
    try {
      final gistId = await _ensureGistId();
      if (gistId == null) return false;

      final Map<String, dynamic> rawMap = {};
      entries.forEach((k, v) => rawMap[k] = v.toJson());

      final resp = await http.patch(
        Uri.parse('$_apiBase/gists/$gistId'),
        headers: _headers,
        body: jsonEncode({
          'files': {
            _activeFileName: {'content': jsonEncode(rawMap)},
          },
        }),
      );
      return resp.statusCode == 200;
    } catch (e) {
      log('[GistSyncService] uploadCloudData error: $e');
      return false;
    }
  }

  Future<Map<String, String>> downloadAllCloudFiles() async {
    if (!isReady) {
      log('[GistSyncService] downloadAllCloudFiles abort: token is missing or not ready');
      return {};
    }
    try {
      var gistId = await _ensureGistId();
      if (gistId == null) {
        log('[GistSyncService] downloadAllCloudFiles abort: gistId is null');
        return {};
      }

      var resp = await http.get(Uri.parse('$_apiBase/gists/$gistId'), headers: _headers);
      if (resp.statusCode == 404) {
        log('[GistSyncService] Gist ID $gistId returned 404 Not Found. Resetting cached Gist ID and re-discovering Gist...');
        _gistId = null;
        gistId = await _ensureGistId();
        if (gistId == null) return {};
        resp = await http.get(Uri.parse('$_apiBase/gists/$gistId'), headers: _headers);
      }

      if (resp.statusCode != 200) {
        log('[GistSyncService] downloadAllCloudFiles HTTP error ${resp.statusCode}: ${resp.body}');
        return {};
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final filesMap = data['files'] as Map<String, dynamic>?;
      if (filesMap == null) {
        log('[GistSyncService] downloadAllCloudFiles: "files" object is null in response');
        return {};
      }

      final Map<String, String> results = {};
      for (final entry in filesMap.entries) {
        final fileName = entry.key;
        final fileData = entry.value;
        if (fileData is Map) {
          String? content = fileData['content'] as String?;
          if ((content == null || content.isEmpty || fileData['truncated'] == true) && fileData['raw_url'] != null) {
            try {
              log('[GistSyncService] Downloading raw_url for $fileName because content was truncated or null');
              final rawResp = await http.get(Uri.parse(fileData['raw_url'] as String));
              if (rawResp.statusCode == 200) {
                content = rawResp.body;
              }
            } catch (e) {
              log('[GistSyncService] Error downloading raw_url for $fileName: $e');
            }
          }
          if (content != null) {
            results[fileName] = content;
          }
        }
      }
      log('[GistSyncService] Downloaded ${results.length} cloud files from Gist $gistId: ${results.keys.toList()}');
      return results;
    } catch (e) {
      log('[GistSyncService] downloadAllCloudFiles error: $e');
      return {};
    }
  }

  Future<bool> uploadCloudFiles(Map<String, String> filesPayload) async {
    if (!isReady || filesPayload.isEmpty) return false;
    try {
      final gistId = await _ensureGistId();
      if (gistId == null) return false;

      final Map<String, dynamic> filesObj = {};
      filesPayload.forEach((fileName, contentStr) {
        filesObj[fileName] = {'content': contentStr};
      });

      final resp = await http.patch(
        Uri.parse('$_apiBase/gists/$gistId'),
        headers: _headers,
        body: jsonEncode({'files': filesObj}),
      );
      return resp.statusCode == 200;
    } catch (e) {
      log('[GistSyncService] uploadCloudFiles error: $e');
      return false;
    }
  }

  String? getGistWebUrl() {
    if (_gistId == null) return null;
    return 'https://gist.github.com/$_gistId';
  }
}
