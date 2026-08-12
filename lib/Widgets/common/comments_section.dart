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
  final CommentsBackendService _commentsService =
      Get.find<CommentsBackendService>();
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
    final hasAvatar =
        comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: isReply ? 8 : 12),
      decoration: BoxDecoration(
        color: isReply
            ? colors.surfaceContainerHighest.withOpacity(0.2)
            : colors.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withOpacity(isReply ? 0.06 : 0.1),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: hasAvatar
                      ? CachedNetworkImageProvider(comment.avatarUrl!)
                      : null,
                  backgroundColor: colors.primary.withOpacity(0.12),
                  child: !hasAvatar
                      ? Text(
                          comment.username.isNotEmpty
                              ? comment.username[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AzyXText(
                  text: comment.username,
                  fontSize: 13,
                  fontVariant: FontVariant.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(comment.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: AzyXText(
              text: comment.commentText,
              fontSize: 13,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: () => _toggleLike(comment),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: comment.userVote == 1
                        ? colors.primary.withOpacity(0.18)
                        : colors.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: comment.userVote == 1
                          ? colors.primary.withOpacity(0.3)
                          : colors.outline.withOpacity(0.08),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comment.userVote == 1
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_up_outlined,
                        size: 13,
                        color: comment.userVote == 1
                            ? colors.primary
                            : colors.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${comment.likes}',
                        style: TextStyle(
                          fontSize: 11,
                          color: comment.userVote == 1
                              ? colors.primary
                              : colors.onSurfaceVariant.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _replyingTo = comment;
                  });
                  _commentFocusNode.requestFocus();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline.withOpacity(0.08),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 13,
                        color: colors.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Reply",
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 14),
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
    final hasUserAvatar =
        currentUser.avatar != null && currentUser.avatar!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: AzyXText(
                    text: "${_comments.length} Comments",
                    fontSize: 11,
                    fontVariant: FontVariant.bold,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_replyingTo != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.secondary.withOpacity(0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 16,
                    color: colors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
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
                      size: 18,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.outline.withOpacity(0.12),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundImage: hasUserAvatar
                        ? CachedNetworkImageProvider(currentUser.avatar!)
                        : null,
                    backgroundColor: colors.primary.withOpacity(0.15),
                    child: !hasUserAvatar
                        ? Text(
                            currentUser.name != null &&
                                    currentUser.name!.isNotEmpty
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
                        style: TextStyle(color: colors.onSurface, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Join the discussion...",
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withOpacity(0.5),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: colors.surfaceContainerLowest.withOpacity(
                            0.6,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colors.outline.withOpacity(0.08),
                              width: 0.8,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colors.outline.withOpacity(0.08),
                              width: 0.8,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colors.primary.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
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
                            SizedBox(width: 6),
                            Icon(Icons.send_rounded, size: 13),
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
              children: _comments
                  .map((comment) => _buildCommentCard(comment))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
