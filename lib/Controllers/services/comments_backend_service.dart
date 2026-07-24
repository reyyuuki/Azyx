import 'dart:convert';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/keys/data_keys.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:azyx/Models/comment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class CommentsBackendService extends GetxController {
  String get _baseUrl {
    final envBase = (dotenv.env['COMMENTS_BASE_URL'] ?? '').trim();
    if (envBase.isEmpty) {
      return 'https://anymex.duckdns.org/functions/v1';
    }
    return envBase.endsWith('/')
        ? envBase.substring(0, envBase.length - 1)
        : envBase;
  }
  String? get currentUserId => serviceHandler.userData.value.id?.toString();
  String? get currentUsername => serviceHandler.userData.value.name;
  String? get currentUserAvatar => serviceHandler.userData.value.avatar;
  String get _clientType => serviceHandler.serviceType.value.name;
  Future<String?> get _authToken async {
    final type = serviceHandler.serviceType.value;
    switch (type) {
      case ServicesType.anilist:
        return AuthKeys.anilistToken.get<String>('');
      case ServicesType.mal:
        return AuthKeys.malAuthToken.get<String>('');
      case ServicesType.simkl:
        return AuthKeys.simklAuthToken.get<String>('');
    }
  }
  Future<List<Comment>> fetchComments(String mediaId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/media?media_id=$mediaId&client_type=$_clientType&page=1&limit=100&sort=newest',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['comments'] as List<dynamic>? ?? [];
        final comments = list
            .map(
              (c) =>
                  Comment.fromMap(Map<String, dynamic>.from(c), currentUserId),
            )
            .toList();
        return _organizeComments(comments);
      }
    } catch (_) {}
    return [];
  }
  List<Comment> _organizeComments(List<Comment> comments) {
    final Map<int, Comment> commentMap = {};
    final List<Comment> parentComments = [];
    for (final comment in comments) {
      final commentId = int.tryParse(comment.id) ?? 0;
      commentMap[commentId] = comment;
    }
    for (final comment in comments) {
      final parentId = comment.parentId;
      if (parentId == null || parentId == 0) {
        parentComments.add(comment);
      } else {
        final parent = commentMap[parentId];
        if (parent != null) {
          parent.replies.add(comment);
        } else {
          parentComments.add(comment);
        }
      }
    }
    parentComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final parent in parentComments) {
      parent.replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return parentComments;
  }
  Future<Comment?> createComment({
    required String mediaId,
    required String title,
    required String poster,
    required String mediaType,
    required String content,
    int? parentId,
  }) async {
    if (currentUserId == null) return null;
    try {
      final body = {
        'action': 'create',
        'client_type': _clientType,
        'content': content,
        'user_info': {
          'user_id': currentUserId,
          'username': currentUsername ?? 'AzyX User',
          if (currentUserAvatar != null) 'avatar': currentUserAvatar,
        },
        'media_info': {
          'media_id': mediaId,
          'type': mediaType,
          'title': title,
          'year': 2025,
          'poster': poster,
        },
        'tag': 'General',
        if (parentId != null) 'parent_id': parentId,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Comment.fromMap(
          Map<String, dynamic>.from(data['comment']),
          currentUserId,
        );
      }
    } catch (_) {}
    return null;
  }
  Future<Map<String, dynamic>?> voteComment({
    required int commentId,
    required String voteType,
  }) async {
    if (currentUserId == null) return null;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/votes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'comment_id': commentId,
          'user_info': {'user_id': currentUserId},
          'vote_type': voteType,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'upvotes': data['upvotes'],
          'downvotes': data['downvotes'],
          'voteScore': data['voteScore'],
          'userVote': data['userVote'],
        };
      }
    } catch (_) {}
    return null;
  }
}
