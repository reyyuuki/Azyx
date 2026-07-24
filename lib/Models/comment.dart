import 'dart:convert';
class Comment {
  final String id;
  final int contentId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String commentText;
  int likes;
  int dislikes;
  int userVote;
  final String tag;
  final String createdAt;
  final String updatedAt;
  final bool deleted;
  final int? parentId;
  final List<Comment> replies;
  Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.commentText,
    required this.likes,
    required this.dislikes,
    required this.userVote,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    this.parentId,
    List<Comment>? replies,
  }) : replies = replies ?? [];
  factory Comment.fromMap(Map<String, dynamic> m, String? currentUserId) {
    final userVotesData = m['user_votes'];
    Map<String, dynamic> userVotes = {};
    if (userVotesData is String) {
      try {
        userVotes = json.decode(userVotesData) as Map<String, dynamic>? ?? {};
      } catch (_) {}
    } else if (userVotesData is Map) {
      userVotes = Map<String, dynamic>.from(userVotesData);
    }
    final currentUserVote = userVotes[currentUserId] ?? 'none';
    int userVoteValue = 0;
    if (currentUserVote == 'upvote') {
      userVoteValue = 1;
    } else if (currentUserVote == 'downvote') {
      userVoteValue = -1;
    }
    return Comment(
      id: m['id'].toString(),
      contentId: int.tryParse(m['media_id'].toString()) ?? 0,
      userId: m['user_id'].toString(),
      username: m['username']?.toString() ?? 'Unknown',
      avatarUrl: m['user_avatar']?.toString() ?? m['avatar']?.toString(),
      commentText: m['content']?.toString() ?? '',
      likes: m['upvotes'] as int? ?? 0,
      dislikes: m['downvotes'] as int? ?? 0,
      userVote: userVoteValue,
      tag: m['tag']?.toString() ?? 'General',
      createdAt: m['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: m['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      deleted: m['deleted'] as bool? ?? false,
      parentId: m['parent_id'] as int?,
      replies: m['replies'] != null
          ? (m['replies'] as List)
              .map((reply) => Comment.fromMap(Map<String, dynamic>.from(reply), currentUserId))
              .toList()
          : [],
    );
  }
}
