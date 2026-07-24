import 'package:azyx/Controllers/services/comments_backend_service.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Models/comment.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
class CommentsSection extends StatefulWidget {
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final bool isManga;
  const CommentsSection({
    super.key,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.isManga,
  });
  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}
class _CommentsSectionState extends State<CommentsSection> {
  final CommentsBackendService _commentsService = Get.find<CommentsBackendService>();
  final ServiceHandler serviceHandler = Get.find<ServiceHandler>();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final RxList<Comment> _comments = <Comment>[].obs;
  final RxBool _isLoading = false.obs;
  Comment? _replyingTo;
  @override
  void initState() {
    super.initState();
    _loadComments();
  }
  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }
  Future<void> _loadComments() async {
    _isLoading.value = true;
    try {
      final list = await _commentsService.fetchComments(widget.mediaId);
      _comments.assignAll(list);
    } catch (_) {}
    _isLoading.value = false;
  }
  Future<void> _handleSubmit() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    if (_replyingTo != null) {
      final parentComment = _replyingTo!;
      final parentCommentId = int.tryParse(parentComment.id) ?? 0;
      if (parentCommentId == 0) return;
      final mediaType = widget.isManga ? 'manga' : 'anime';
      final newComment = await _commentsService.createComment(
        mediaId: widget.mediaId,
        title: widget.mediaTitle,
        poster: widget.mediaPoster,
        mediaType: mediaType,
        content: text,
        parentId: parentCommentId,
      );
      if (newComment != null) {
        parentComment.replies.add(newComment);
        _commentController.clear();
        _replyingTo = null;
        if (mounted) FocusScope.of(context).unfocus();
        _comments.refresh();
      }
    } else {
      final mediaType = widget.isManga ? 'manga' : 'anime';
      final newComment = await _commentsService.createComment(
        mediaId: widget.mediaId,
        title: widget.mediaTitle,
        poster: widget.mediaPoster,
        mediaType: mediaType,
        content: text,
      );
      if (newComment != null) {
        _comments.insert(0, newComment);
        _commentController.clear();
        if (mounted) FocusScope.of(context).unfocus();
      }
    }
  }
  Future<void> _toggleLike(Comment comment) async {
    final commentId = int.tryParse(comment.id) ?? 0;
    if (commentId == 0) return;
    final isAlreadyLiked = comment.userVote == 1;
    final voteType = isAlreadyLiked ? 'remove' : 'upvote';
    final result = await _commentsService.voteComment(
      commentId: commentId,
      voteType: voteType,
    );
    if (result != null) {
      comment.likes = result['upvotes'] ?? comment.likes;
      comment.dislikes = result['downvotes'] ?? comment.dislikes;
      final userVoteStr = result['userVote'];
      if (userVoteStr == 'upvote') {
        comment.userVote = 1;
      } else if (userVoteStr == 'downvote') {
        comment.userVote = -1;
      } else {
        comment.userVote = 0;
      }
      _comments.refresh();
    }
  }
  Widget _buildCommentCard(Comment comment, {bool isReply = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasAvatar = comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: isReply ? 8 : 12),
      decoration: BoxDecoration(
        color: isReply ? colors.surfaceContainerLowest.withOpacity(0.5) : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(isReply ? 0.04 : 0.08),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: hasAvatar ? CachedNetworkImageProvider(comment.avatarUrl!) : null,
                backgroundColor: colors.primary.withOpacity(0.1),
                child: !hasAvatar
                    ? Text(
                        comment.username.isNotEmpty ? comment.username[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AzyXText(
                  text: comment.username,
                  fontSize: 12,
                  fontVariant: FontVariant.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(comment.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: AzyXText(
              text: comment.commentText,
              fontSize: 12.5,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  comment.userVote == 1 ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                  size: 14,
                  color: comment.userVote == 1 ? colors.primary : colors.onSurfaceVariant.withOpacity(0.6),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _toggleLike(comment),
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.likes}',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _replyingTo = comment;
                  });
                  _commentFocusNode.requestFocus();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      size: 14,
                      color: colors.onSurfaceVariant.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Reply",
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: comment.replies
                    .map((reply) => _buildCommentCard(reply, isReply: true))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {}
    return 'Just now';
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentUser = serviceHandler.userData.value;
    final hasUserAvatar = currentUser.avatar != null && currentUser.avatar!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AzyXText(
                text: "Discussion",
                fontSize: 18,
                fontVariant: FontVariant.bold,
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AzyXText(
                      text: "${_comments.length} Comments",
                      fontSize: 11,
                      fontVariant: FontVariant.bold,
                      color: colors.primary,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          if (_replyingTo != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to @${_replyingTo!.username}',
                      style: TextStyle(
                        color: colors.onSecondaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingTo = null;
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.primary.withOpacity(0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: hasUserAvatar ? CachedNetworkImageProvider(currentUser.avatar!) : null,
                  backgroundColor: colors.primary.withOpacity(0.1),
                  child: !hasUserAvatar
                      ? Text(
                          currentUser.name != null && currentUser.name!.isNotEmpty
                              ? currentUser.name![0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        maxLines: 3,
                        minLines: 1,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: "Join the discussion...",
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withOpacity(0.5),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: colors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Comment",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.send_rounded, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (_isLoading.value) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: const LoadingIndicatorM3E(),
              );
            }
            if (_comments.isEmpty) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: AzyXText(
                  text: "No comments yet. Start the conversation!",
                  fontSize: 13,
                  color: colors.onSurfaceVariant.withOpacity(0.6),
                ),
              );
            }
            return Column(
              children: _comments.map((comment) => _buildCommentCard(comment)).toList(),
            );
          }),
        ],
      ),
    );
  }
}
