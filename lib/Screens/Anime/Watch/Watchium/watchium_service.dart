import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Screens/Anime/Watch/Watchium/watchium_model.dart';
import 'package:azyx/Screens/Anime/Watch/controller/watch_controller.dart';
import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WatchiumService extends GetxController {
  static String get _defaultServerUrl =>
      dotenv.env['WATCHIUM_SERVER_URL'] ?? 'http://anymex.duckdns.org:3001';

  IO.Socket? _socket;
  String? _token;
  String? _userId;
  String? _currentRoomCode;
  bool _isHost = false;
  Timer? _heartbeatTimer;
  String? _lastClientId;

  final Rx<WatchiumRoomState?> roomState = Rx(null);
  final RxList<WatchiumChatMessage> chatMessages = RxList();
  final RxList<WatchiumReaction> reactions = RxList();
  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString error = ''.obs;
  final RxBool isHost = false.obs;
  final RxString roomCode = ''.obs;

  String get serverUrl {
    final envUrl = dotenv.env['WATCHIUM_SERVER_URL'] ?? _defaultServerUrl;
    final saved = WatchiumKeys.serverUrl.get<String>(envUrl);
    if (saved.startsWith('https://anymex.duckdns.org:3001')) {
      return saved.replaceFirst('https://', 'http://');
    }
    return saved;
  }

  bool get inRoom => _currentRoomCode != null && _socket?.connected == true;

  static String? cleanUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    String clean = url.trim();
    while (clean.startsWith('https:https:////') ||
        clean.startsWith('http:http:////') ||
        clean.startsWith('https://https://') ||
        clean.startsWith('http://http://')) {
      clean = clean.replaceFirst(RegExp(r'^(https?:)+/*'), 'https://');
    }
    if (clean.contains('https://') && clean.indexOf('https://') > 0) {
      clean = clean.substring(clean.lastIndexOf('https://'));
    } else if (clean.contains('http://') && clean.indexOf('http://') > 0) {
      clean = clean.substring(clean.lastIndexOf('http://'));
    }
    return clean;
  }

  static String extractRoomCode(String input) {
    final trimmed = input.trim().toUpperCase();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('/JOIN/')) {
      final part = trimmed.split('/JOIN/').last;
      final codePart = part.split('?').first.split('/').first;
      return codePart.trim();
    }
    return trimmed;
  }

  static String getStreamType(String? url) {
    if (url == null || url.isEmpty) return 'other';
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8') || lower.contains('m3u8')) return 'hls';
    if (lower.contains('.mp4')) return 'mp4';
    if (lower.contains('.mpd')) return 'dash';
    return 'other';
  }

  String getInviteUrl(String code) => '$serverUrl/join/$code?Azyx';

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<bool> login() async {
    try {
      final serviceHandler = Get.find<ServiceHandler>();
      if (!serviceHandler.isLoggedIn.value) {
        await serviceHandler.autoLogin();
      }
      var user = serviceHandler.userData.value;
      if (user.id == null && user.name == null) {
        try {
          await serviceHandler.anilistService.fetchUserProfile();
          user = serviceHandler.userData.value;
        } catch (_) {}
      }

      if (user.name == null && user.id == null) {
        error.value =
            'You must be logged in to AniList/MAL to use Watch Together';
        return false;
      }

      String provider = 'anilist';
      if (serviceHandler.serviceType.value == ServicesType.mal) {
        provider = 'mal';
      } else if (serviceHandler.serviceType.value == ServicesType.simkl) {
        provider = 'simkl';
      }

      final String providerUserId =
          user.id?.toString() ??
          user.name ??
          'user_${DateTime.now().millisecondsSinceEpoch}';
      final String username = user.name ?? 'User';
      final String? avatarUrl = user.avatar;

      final apiToken = dotenv.env['WATCHIUM_API_TOKEN'];
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-API-Token': apiToken ?? '',
      };

      final response = await http.post(
        Uri.parse('$serverUrl/api/auth/login'),
        headers: headers,
        body: jsonEncode({
          'provider': provider,
          'providerUserId': providerUserId,
          'username': username,
          'avatarUrl': avatarUrl,
        }),
      );

      if (response.statusCode != 200) {
        error.value =
            'Login failed: ${response.statusCode} ${response.reasonPhrase} ${response.body}';
        log(
          'Login failed: ${response.statusCode} ${response.reasonPhrase} ${response.body} $serverUrl',
        );
        return false;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _token = data['token'] as String;
      _userId = (data['user'] as Map<String, dynamic>)['id']?.toString();
      error.value = '';
      return true;
    } catch (e) {
      error.value = 'Login failed: $e';
      return false;
    }
  }

  void _connectSocket() {
    if (_socket?.connected == true) return;

    isConnecting.value = true;
    final apiToken = dotenv.env['WATCHIUM_API_TOKEN'] ?? '';

    _socket = IO.io(
      '$serverUrl/watch',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'apiToken': apiToken, 'token': _token})
          .build(),
    );

    _socket!.on('connect', (_) {
      isConnected.value = true;
      isConnecting.value = false;
      error.value = '';
    });

    _socket!.on('disconnect', (_) {
      isConnected.value = false;
      _stopHeartbeat();
    });

    _socket!.on('connect_error', (err) {
      isConnected.value = false;
      isConnecting.value = false;
      error.value = 'Connection failed: $err';
      log('Watchium socket connect_error: $err');
    });

    _socket!.on('party:state', (data) {
      log('[Watchium] party:state raw data: $data');
      final map = _toMap(data);
      if (map.isEmpty) return;
      final state = WatchiumRoomState.fromJson(map);
      roomState.value = state;
      _isHost = state.hostUserId == _userId;
      isHost.value = _isHost;
      log('[Watchium] party:state parsed -> isHost: $_isHost, content: ${state.content?.toJson()}, playback: pos=${state.playback?.positionSec}');
      if (!_isHost && state.content != null) {
        _launchWatchScreenForJoiner(state.content!, state.playback);
      }
    });

    _socket!.on('party:sync', (data) {
      log('[Watchium] party:sync raw data: $data');
      final map = _toMap(data);
      final pbMap = _toMap(map['playback']);
      final current = roomState.value;
      if (current == null || pbMap.isEmpty) return;
      roomState.value = WatchiumRoomState(
        code: current.code,
        hostUserId: current.hostUserId,
        members: current.members,
        content: current.content,
        playback: WatchiumPlayback.fromJson(pbMap),
        onlyHostControls: current.onlyHostControls,
        maxMembers: current.maxMembers,
      );
    });

    _socket!.on('party:content', (data) {
      log('[Watchium] party:content raw data: $data');
      final map = _toMap(data);
      final contentMap = _toMap(map['content']);
      final pbMap = _toMap(map['playback']);
      final current = roomState.value;
      if (current == null) return;
      final newContent = contentMap.isNotEmpty
          ? WatchiumAnimeContent.fromJson(contentMap)
          : current.content;
      final newPlayback = pbMap.isNotEmpty
          ? WatchiumPlayback.fromJson(pbMap)
          : current.playback;
      roomState.value = WatchiumRoomState(
        code: current.code,
        hostUserId: current.hostUserId,
        members: current.members,
        content: newContent,
        playback: newPlayback,
        onlyHostControls: current.onlyHostControls,
        maxMembers: current.maxMembers,
      );
      log('[Watchium] party:content parsed -> videoUrl: ${newContent?.videoUrl}, title: ${newContent?.animeTitle}');
      if (!_isHost && newContent != null) {
        _launchWatchScreenForJoiner(newContent, newPlayback);
      }
    });

    _socket!.on('party:member', (data) {
      final map = _toMap(data);
      final current = roomState.value;
      if (current == null) return;
      final membersList =
          (map['members'] as List?)
              ?.map((e) => WatchiumMember.fromJson(_toMap(e)))
              .toList() ??
          [];
      roomState.value = WatchiumRoomState(
        code: current.code,
        hostUserId: map['hostUserId']?.toString() ?? current.hostUserId,
        members: membersList,
        content: current.content,
        playback: current.playback,
        onlyHostControls: current.onlyHostControls,
        maxMembers: current.maxMembers,
      );
    });

    _socket!.on('party:chat', (data) {
      final map = _toMap(data);
      if (map.isEmpty) return;
      final msg = WatchiumChatMessage.fromJson(map);
      if (msg.clientId != _lastClientId) {
        chatMessages.add(msg);
        if (chatMessages.length > 100) chatMessages.removeAt(0);
      }
    });

    _socket!.on('party:reaction', (data) {
      final map = _toMap(data);
      if (map.isEmpty) return;
      final r = WatchiumReaction.fromJson(map);
      reactions.add(r);
      if (reactions.length > 50) reactions.removeAt(0);
      Future.delayed(const Duration(seconds: 3), () {
        reactions.remove(r);
      });
    });

    _socket!.on('party:error', (data) {
      final map = _toMap(data);
      error.value = map['message']?.toString() ?? 'Unknown error';
    });

    _socket!.on('party:closed', (data) {
      final map = _toMap(data);
      final reason = map['reason']?.toString() ?? 'closed';
      _leaveRoomInternal();
      error.value = 'Room $reason';
    });

    _socket!.connect();
  }

  Future<String?> createRoom({
    required String animeTitle,
    required int episodeNumber,
    String? animeId,
    int? anilistId,
    int? malId,
    int? simklId,
    String? animeCoverImage,
    int? seasonNumber,
    int? totalEpisodes,
    double? initialPositionSec,
    List<WatchiumAnimeServer>? availableServers,
    String? videoUrl,
    String? sourceName,
  }) async {
    try {
      _isHost = true;
      isHost.value = true;
      final ok = await login();
      if (!ok) return null;

      final String effectiveAnimeId =
          animeId ??
          anilistId?.toString() ??
          malId?.toString() ??
          simklId?.toString() ??
          '1';

      final response = await http.post(
        Uri.parse('$serverUrl/api/watch-party'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'X-API-Token': dotenv.env['WATCHIUM_API_TOKEN'] ?? '',
        },
        body: jsonEncode({
          'content': {
            'animeId': effectiveAnimeId,
            'animeTitle': animeTitle,
            'episodeNumber': episodeNumber,
            'anilistId': anilistId,
            'malId': malId,
            'simklId': simklId,
            'animeCoverImage': animeCoverImage,
            'seasonNumber': seasonNumber,
            'totalEpisodes': totalEpisodes,
            'availableServers':
                (availableServers != null && availableServers.isNotEmpty)
                    ? availableServers.map((e) => e.toJson()).toList()
                    : (videoUrl != null && videoUrl.isNotEmpty
                        ? [
                            WatchiumAnimeServer(
                              serverId: videoUrl,
                              serverName: sourceName ?? 'Default',
                              type: getStreamType(videoUrl),
                            ).toJson()
                          ]
                        : []),
            'videoUrl': videoUrl,
            'sourceName': sourceName,
          },
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        if (response.statusCode == 409) {
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final existingCode = data['code'] as String?;
            if (existingCode != null && existingCode.isNotEmpty) {
              log(
                'Conflict 409: Already in room $existingCode. Re-using active room...',
              );
              roomCode.value = existingCode;
              _connectSocket();

              await Future.delayed(const Duration(seconds: 1));
              _socket?.emitWithAck('party:join', {'code': existingCode});
              _currentRoomCode = existingCode;

              if (initialPositionSec != null && initialPositionSec > 0) {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (_currentRoomCode == existingCode) {
                    sendSeek(initialPositionSec);
                  }
                });
              }
              return existingCode;
            }
          } catch (e) {
            log('Failed to auto-resolve 409 conflict: $e');
          }
        }
        error.value = 'Failed to create room';
        log(
          'Failed to create room: ${response.statusCode} ${response.reasonPhrase} ${response.body}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['code'] as String;
      roomCode.value = code;
      _connectSocket();

      await Future.delayed(const Duration(seconds: 1));
      _socket?.emitWithAck('party:join', {'code': code});
      _currentRoomCode = code;

      if (initialPositionSec != null && initialPositionSec > 0) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_currentRoomCode == code) {
            sendSeek(initialPositionSec);
          }
        });
      }
      return code;
    } catch (e) {
      error.value = 'Failed to create room: $e';
      return null;
    }
  }

  Future<bool> closeRoom(String code) async {
    try {
      final response = await http.delete(
        Uri.parse('$serverUrl/api/watch-party/$code'),
        headers: {
          'Authorization': 'Bearer $_token',
          'X-API-Token': dotenv.env['WATCHIUM_API_TOKEN'] ?? '',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<bool> joinRoom(String codeOrUrl) async {
    final code = extractRoomCode(codeOrUrl);
    if (code.isEmpty) {
      error.value = 'Invalid room code or URL';
      return false;
    }

    try {
      if (_currentRoomCode != null && _currentRoomCode != code) {
        leaveRoom();
      }

      final ok = await login();
      if (!ok) return false;

      roomCode.value = code;
      _connectSocket();

      await Future.delayed(const Duration(seconds: 1));
      _socket?.emitWithAck('party:join', {'code': code});
      _currentRoomCode = code;
      return true;
    } catch (e) {
      error.value = 'Failed to join room: $e';
      return false;
    }
  }

  void leaveRoom() {
    if (_currentRoomCode == null) return;
    _socket?.emit('party:leave', {'code': _currentRoomCode});
    _leaveRoomInternal();
  }

  void _leaveRoomInternal() {
    _stopHeartbeat();
    _currentRoomCode = null;
    _isHost = false;
    isHost.value = false;
    roomState.value = null;
    chatMessages.clear();
    reactions.clear();
  }

  void disconnect() {
    leaveRoom();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    _token = null;
    _userId = null;
  }

  void sendControl(String action, {double? positionSec, double? rate}) {
    if (_currentRoomCode == null || !_isHost) return;
    _socket?.emit('party:control', {
      'code': _currentRoomCode,
      'action': action,
      if (positionSec != null) 'positionSec': positionSec,
      if (rate != null) 'rate': rate,
    });
  }

  void sendPlay({double? positionSec}) =>
      sendControl('play', positionSec: positionSec);
  void sendPause({double? positionSec}) =>
      sendControl('pause', positionSec: positionSec);
  void sendSeek(double positionSec) =>
      sendControl('seek', positionSec: positionSec);
  void sendRate(double rate) => sendControl('rate', rate: rate);

  void sendHeartbeat(double positionSec, bool isPlaying) {
    if (_currentRoomCode == null || !_isHost) return;
    _socket?.emit('party:heartbeat', {
      'code': _currentRoomCode,
      'positionSec': positionSec,
      'isPlaying': isPlaying,
    });
  }

  void startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_currentRoomCode == null || !_isHost) return;
      _socket?.emit('party:heartbeat', {'code': _currentRoomCode});
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void setContent(WatchiumAnimeContent content) {
    if (_currentRoomCode == null || !_isHost) return;
    _socket?.emit('party:content', {
      'code': _currentRoomCode,
      'content': content.toJson(),
    });
  }

  void selectServer(String serverId) {
    if (_currentRoomCode == null) return;
    _socket?.emit('party:server-select', {
      'code': _currentRoomCode,
      'serverId': serverId,
    });
  }

  void sendChat(String text) {
    if (_currentRoomCode == null) return;
    _lastClientId = DateTime.now().millisecondsSinceEpoch.toString();
    _socket?.emit('party:chat', {
      'code': _currentRoomCode,
      'text': text,
      'clientId': _lastClientId,
    });
  }

  void sendReaction(String emoji) {
    if (_currentRoomCode == null) return;
    _lastClientId = DateTime.now().millisecondsSinceEpoch.toString();
    _socket?.emit('party:reaction', {
      'code': _currentRoomCode,
      'emoji': emoji,
      'clientId': _lastClientId,
    });
  }

  void _launchWatchScreenForJoiner(
    WatchiumAnimeContent content,
    WatchiumPlayback? playback,
  ) {
    if (_isHost || Get.isRegistered<WatchController>()) return;

    final List<Video> episodeUrls = content.availableServers.isNotEmpty
        ? content.availableServers.map((s) => s.toVideo()).toList()
        : (content.videoUrl != null && content.videoUrl!.isNotEmpty
            ? [
                Video(
                  'Host Stream',
                  cleanUrl(content.videoUrl!) ?? content.videoUrl!,
                  cleanUrl(content.videoUrl!) ?? content.videoUrl!,
                ),
              ]
            : const []);

    final Video? bestTrack = episodeUrls.isNotEmpty
        ? (episodeUrls.firstWhereOrNull((v) {
              final u = v.url.toLowerCase();
              return (u.contains('.m3u8') || u.contains('.mp4')) &&
                  !u.contains('.mpd');
            }) ??
            episodeUrls.first)
        : null;

    final String? activeUrl = bestTrack?.url ?? content.videoUrl;

    log('[Watchium] _launchWatchScreenForJoiner -> activeUrl: $activeUrl, episodeUrls len: ${episodeUrls.length}, headers: ${bestTrack?.headers}');

    final playerData = AnimeAllData(
      id: content.animeId,
      title: content.animeTitle,
      number: content.episodeNumber.toString(),
      episodeTitle: 'Episode ${content.episodeNumber}',
      image: content.animeCoverImage,
      url: activeUrl,
      episodeUrls: episodeUrls,
      episodeList: const [],
      source: content.sourceName ?? '',
      startFromSeconds: playback?.positionSec.toInt(),
    );

    Get.to(() => WatchScreen(playerData: playerData));
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
