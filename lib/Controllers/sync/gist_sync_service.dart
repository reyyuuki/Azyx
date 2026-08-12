import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class GistProgressEntry {
  final String mediaId;
  final String? malId;
  final String mediaType;
  final String? serviceType;
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
      if (resp.statusCode != 200) return null;

      final list = jsonDecode(resp.body) as List<dynamic>;
      for (final g in list) {
        final files = g['files'] as Map<String, dynamic>? ?? {};
        for (final fn in _possibleFileNames) {
          if (files.containsKey(fn)) {
            _gistId = g['id'] as String;
            _activeFileName = fn;
            return _gistId;
          }
        }
      }
    } catch (e) {
      log('[GistSyncService] _findExistingGistId error: $e');
    }
    return null;
  }

  Future<String?> _ensureGistId() async {
    final existing = await _findExistingGistId();
    if (existing != null) return existing;
    try {
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
        return _gistId;
      }
    } catch (e) {
      log('[GistSyncService] _ensureGistId error: $e');
    }
    return null;
  }

  Future<Map<String, GistProgressEntry>> downloadCloudData() async {
    if (!isReady) return {};
    try {
      final gistId = await _ensureGistId();
      if (gistId == null) return {};

      final resp = await http.get(Uri.parse('$_apiBase/gists/$gistId'), headers: _headers);
      if (resp.statusCode != 200) return {};

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final filesMap = data['files'] as Map<String, dynamic>?;
      if (filesMap == null) return {};

      String? content;
      if (filesMap.containsKey(_activeFileName)) {
        content = (filesMap[_activeFileName] as Map<String, dynamic>?)?['content'] as String?;
      } else {
        for (final fn in _possibleFileNames) {
          if (filesMap.containsKey(fn)) {
            _activeFileName = fn;
            content = (filesMap[fn] as Map<String, dynamic>?)?['content'] as String?;
            break;
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
    } catch (e) {
      log('[GistSyncService] downloadCloudData error: $e');
      return {};
    }
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

  String? getGistWebUrl() {
    if (_gistId == null) return null;
    return 'https://gist.github.com/$_gistId';
  }
}
