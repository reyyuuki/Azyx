import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';

class WatchiumUser {
  final String id;
  final String username;
  final String? avatarUrl;
  final String authProvider;

  WatchiumUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.authProvider,
  });

  factory WatchiumUser.fromJson(Map<String, dynamic> json) => WatchiumUser(
    id: json['id']?.toString() ?? '',
    username: json['username']?.toString() ?? 'User',
    avatarUrl: json['avatarUrl']?.toString(),
    authProvider: json['authProvider']?.toString() ?? 'anilist',
  );
}

class WatchiumAnimeServer {
  final String serverId;
  final String serverName;
  final String? quality;
  final String type;
  final String? url;
  final String? originalUrl;
  final Map<String, String>? headers;

  WatchiumAnimeServer({
    required this.serverId,
    required this.serverName,
    this.quality,
    required this.type,
    this.url,
    this.originalUrl,
    this.headers,
  });

  factory WatchiumAnimeServer.fromJson(Map<String, dynamic> json) =>
      WatchiumAnimeServer(
        serverId: json['serverId']?.toString() ?? '',
        serverName: json['serverName']?.toString() ?? 'Server',
        quality: json['quality']?.toString(),
        type: json['type']?.toString() ?? 'other',
        url: json['url']?.toString(),
        originalUrl: json['originalUrl']?.toString(),
        headers: (json['headers'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString())),
      );

  Map<String, dynamic> toJson() => {
    'serverId': serverId,
    'serverName': serverName,
    'quality': quality,
    'type': type,
    'url': url ?? serverId,
    'originalUrl': originalUrl ?? url ?? serverId,
    'headers': headers,
  };

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

  Video toVideo() {
    final String rawUrl = url ?? serverId;
    final String effectiveUrl = cleanUrl(rawUrl) ?? rawUrl;
    final String origUrl = cleanUrl(originalUrl) ?? effectiveUrl;
    return Video(
      quality ?? serverName,
      effectiveUrl,
      origUrl,
      headers: headers,
    );
  }
}

class WatchiumAnimeContent {
  final String animeId;
  final String animeTitle;
  final String? animeCoverImage;
  final int episodeNumber;
  final int? seasonNumber;
  final int? totalEpisodes;
  final int? anilistId;
  final int? malId;
  final int? simklId;
  final List<WatchiumAnimeServer> availableServers;
  final String? videoUrl;
  final String? sourceName;

  WatchiumAnimeContent({
    required this.animeId,
    required this.animeTitle,
    this.animeCoverImage,
    required this.episodeNumber,
    this.seasonNumber,
    this.totalEpisodes,
    this.anilistId,
    this.malId,
    this.simklId,
    required this.availableServers,
    this.videoUrl,
    this.sourceName,
  });

  factory WatchiumAnimeContent.fromJson(Map<String, dynamic> json) =>
      WatchiumAnimeContent(
        animeId: json['animeId']?.toString() ?? '',
        animeTitle: json['animeTitle']?.toString() ?? '',
        animeCoverImage: json['animeCoverImage']?.toString(),
        episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 1,
        seasonNumber: (json['seasonNumber'] as num?)?.toInt(),
        totalEpisodes: (json['totalEpisodes'] as num?)?.toInt(),
        anilistId: (json['anilistId'] as num?)?.toInt(),
        malId: (json['malId'] as num?)?.toInt(),
        simklId: (json['simklId'] as num?)?.toInt(),
        availableServers:
            (json['availableServers'] as List?)
                ?.map(
                  (e) => WatchiumAnimeServer.fromJson(
                    e is Map<String, dynamic>
                        ? e
                        : Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList() ??
            [],
        videoUrl: json['videoUrl']?.toString(),
        sourceName: json['sourceName']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'animeTitle': animeTitle,
    'animeCoverImage': animeCoverImage,
    'episodeNumber': episodeNumber,
    'seasonNumber': seasonNumber,
    'totalEpisodes': totalEpisodes,
    'anilistId': anilistId,
    'malId': malId,
    'simklId': simklId,
    'availableServers': availableServers.map((e) => e.toJson()).toList(),
    'videoUrl': videoUrl,
    'sourceName': sourceName,
  };
}

class WatchiumPlayback {
  double positionSec;
  bool isPlaying;
  double rate;
  int updatedAt;

  WatchiumPlayback({
    required this.positionSec,
    required this.isPlaying,
    required this.rate,
    required this.updatedAt,
  });

  factory WatchiumPlayback.fromJson(Map<String, dynamic> json) =>
      WatchiumPlayback(
        positionSec: (json['positionSec'] as num?)?.toDouble() ?? 0.0,
        isPlaying: json['isPlaying'] as bool? ?? false,
        rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
        updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
      );
}

class WatchiumMember {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String role;
  final bool online;
  final String? selectedServerId;

  WatchiumMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.role,
    required this.online,
    this.selectedServerId,
  });

  factory WatchiumMember.fromJson(Map<String, dynamic> json) => WatchiumMember(
    userId: json['userId']?.toString() ?? '',
    username: json['username']?.toString() ?? 'User',
    avatarUrl: json['avatarUrl']?.toString(),
    role: json['role']?.toString() ?? 'member',
    online: json['online'] as bool? ?? true,
    selectedServerId: json['selectedServerId']?.toString(),
  );
}

class WatchiumRoomState {
  final String code;
  final String hostUserId;
  final List<WatchiumMember> members;
  final WatchiumAnimeContent? content;
  final WatchiumPlayback? playback;
  final bool onlyHostControls;
  final int maxMembers;

  WatchiumRoomState({
    required this.code,
    required this.hostUserId,
    required this.members,
    this.content,
    this.playback,
    required this.onlyHostControls,
    required this.maxMembers,
  });

  factory WatchiumRoomState.fromJson(Map<String, dynamic> json) =>
      WatchiumRoomState(
        code: json['code']?.toString() ?? '',
        hostUserId: json['hostUserId']?.toString() ?? '',
        members:
            (json['members'] as List?)
                ?.map(
                  (e) => WatchiumMember.fromJson(
                    e is Map<String, dynamic>
                        ? e
                        : Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList() ??
            [],
        content: json['content'] != null
            ? WatchiumAnimeContent.fromJson(
                json['content'] is Map<String, dynamic>
                    ? json['content'] as Map<String, dynamic>
                    : Map<String, dynamic>.from(json['content'] as Map),
              )
            : null,
        playback: json['playback'] != null
            ? WatchiumPlayback.fromJson(
                json['playback'] is Map<String, dynamic>
                    ? json['playback'] as Map<String, dynamic>
                    : Map<String, dynamic>.from(json['playback'] as Map),
              )
            : null,
        onlyHostControls:
            json['settings']?['onlyHostControls'] as bool? ?? true,
        maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 10,
      );
}

class WatchiumChatMessage {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String text;
  final int ts;
  final String clientId;

  WatchiumChatMessage({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.text,
    required this.ts,
    required this.clientId,
  });

  factory WatchiumChatMessage.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;
    return WatchiumChatMessage(
      userId: userMap?['id']?.toString() ?? json['userId']?.toString() ?? '',
      username:
          userMap?['username']?.toString() ??
          json['username']?.toString() ??
          'User',
      avatarUrl:
          userMap?['avatarUrl']?.toString() ?? json['avatarUrl']?.toString(),
      text: json['text']?.toString() ?? '',
      ts:
          (json['ts'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      clientId: json['clientId']?.toString() ?? '',
    );
  }
}

class WatchiumReaction {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String emoji;
  final int ts;

  WatchiumReaction({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.emoji,
    required this.ts,
  });

  factory WatchiumReaction.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;
    return WatchiumReaction(
      userId: userMap?['id']?.toString() ?? json['userId']?.toString() ?? '',
      username:
          userMap?['username']?.toString() ??
          json['username']?.toString() ??
          'User',
      avatarUrl:
          userMap?['avatarUrl']?.toString() ?? json['avatarUrl']?.toString(),
      emoji: json['emoji']?.toString() ?? '',
      ts:
          (json['ts'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}
