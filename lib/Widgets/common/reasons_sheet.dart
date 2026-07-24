import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/services/community_service.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Screens/community/user_recommendations_page.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/common/recommend_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReasonsSheet extends StatefulWidget {
  final CommunityMedia item;
  final MediaType mediaItemType;
  final String? voteMediaType;
  final String? voteMediaId;
  const ReasonsSheet({
    super.key,
    required this.item,
    required this.mediaItemType,
    this.voteMediaType,
    this.voteMediaId,
  });
  static void show(
    BuildContext context, {
    required CommunityMedia item,
    required MediaType mediaItemType,
    String? voteMediaType,
    String? voteMediaId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReasonsSheet(
        item: item,
        mediaItemType: mediaItemType,
        voteMediaType: voteMediaType,
        voteMediaId: voteMediaId,
      ),
    );
  }

  @override
  State<ReasonsSheet> createState() => _ReasonsSheetState();
}

class _ReasonsSheetState extends State<ReasonsSheet> {
  bool _isAdmin = false;
  VoteResult? _votes;
  String? _userVote;
  bool _voteLoading = false;
  ServiceHandler get _sh => Get.find<ServiceHandler>();
  @override
  void initState() {
    super.initState();
    _runAdminCheck();
    if (CommunityService.votingEnabled &&
        widget.voteMediaType != null &&
        widget.voteMediaId != null) {
      _loadVotes();
    }
  }

  int? get _myId {
    final profile = _sh.userData.value;
    return profile.id;
  }

  ServicesType get _serviceType => _sh.serviceType.value;
  bool _isMyReason(ReasonEntry reason) {
    final myId = _myId;
    if (myId == null) return false;
    return reason.userIdFor(_serviceType) == myId;
  }

  bool get _hasMyReason {
    return widget.item.reasons.any(_isMyReason);
  }

  bool get _canAddRecommendation =>
      CommunityService.votingEnabled && _sh.isLoggedIn.value;
  Future<void> _runAdminCheck() async {
    final profile = _sh.userData.value;
    final isAdmin = await CommunityService.checkIsAdmin(
      serviceType: _serviceType,
      profile: profile,
    );
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadVotes() async {
    final profile = _sh.userData.value;
    int? anilistId;
    int? malId;
    int? simklId;
    if (_serviceType == ServicesType.anilist) {
      anilistId = profile.id;
    } else if (_serviceType == ServicesType.mal) {
      malId = profile.id;
    } else if (_serviceType == ServicesType.simkl) {
      simklId = profile.id;
    }
    final result = await CommunityService.fetchVotes(
      widget.voteMediaType!,
      widget.voteMediaId!,
      anilistUserId: anilistId,
      malUserId: malId,
      simklUserId: simklId,
    );
    if (mounted) {
      setState(() {
        _votes = result;
        if (result != null) _userVote = result.userVote;
      });
    }
  }

  Future<void> _castVote(String direction) async {
    if (_voteLoading) return;
    final profile = _sh.userData.value;
    int? anilistId;
    int? malId;
    int? simklId;
    String displayName = profile.name ?? 'User';
    if (_serviceType == ServicesType.anilist) {
      anilistId = profile.id;
    } else if (_serviceType == ServicesType.mal) {
      malId = profile.id;
    } else if (_serviceType == ServicesType.simkl) {
      simklId = profile.id;
    } else if (profile.id != null) {
      anilistId = profile.id;
    }
    if (anilistId == null && malId == null && simklId == null) {
      azyxSnackBar('Please log in to AniList or MAL to vote!');
      return;
    }
    setState(() => _voteLoading = true);
    final result = await CommunityService.castVote(
      mediaType: widget.voteMediaType!,
      mediaId: widget.voteMediaId!,
      direction: direction,
      anilistUserId: anilistId,
      malUserId: malId,
      simklUserId: simklId,
      displayName: displayName,
    );
    if (mounted) {
      setState(() {
        _voteLoading = false;
        if (result != null) {
          _votes = result;
          _userVote = result.userVote;
        }
      });
    }
  }

  void _onEditReason(ReasonEntry reason) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecommendSheet(
        media: widget.item.media,
        initialReason: reason.text,
        isEdit: true,
      ),
    );
    if (result != null && mounted) {
      final error = await CommunityService.editReason(
        mediaType: widget.voteMediaType!,
        mediaId: widget.voteMediaId!,
        newReason: result,
        serviceType: _serviceType,
        profile: _sh.userData.value,
      );
      if (error != null) {
        azyxSnackBar(error);
      } else {
        azyxSnackBar("Recommendation updated successfully");
        Navigator.pop(context);
      }
    }
  }

  void _onDeleteReason(ReasonEntry reason) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Recommendation"),
        content: const Text(
          "Are you sure you want to delete your recommendation for this title?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final (error, pending) = await CommunityService.deleteReasonWithStatus(
        mediaType: widget.voteMediaType!,
        mediaId: widget.voteMediaId!,
        serviceType: _serviceType,
        profile: _sh.userData.value,
        isAdmin: _isAdmin,
      );
      if (error != null) {
        azyxSnackBar(error);
      } else {
        if (pending) {
          azyxSnackBar("Deletion request sent to administrators");
        } else {
          azyxSnackBar("Recommendation deleted successfully");
        }
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AzyXText(
                          text: widget.item.displayTitle,
                          fontSize: 16,
                          fontVariant: FontVariant.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        AzyXText(
                          text: "Community Recommendations",
                          fontSize: 12,
                          color: colors.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                  if (_canAddRecommendation && !_hasMyReason)
                    IconButton.filledTonal(
                      onPressed: () async {
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              RecommendSheet(media: widget.item.media),
                        );
                        if (result != null && mounted) {
                          final error =
                              await CommunityService.submitRecommendation(
                                media: widget.item.media,
                                reason: result,
                                serviceType: _serviceType,
                                profile: _sh.userData.value,
                              );
                          if (error != null) {
                            azyxSnackBar(error);
                          } else {
                            azyxSnackBar("Recommendation submitted!");
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: const Icon(Icons.add_comment_rounded),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (CommunityService.votingEnabled &&
                widget.voteMediaType != null &&
                widget.voteMediaId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _VoteButton(
                          icon: Icons.thumb_up_rounded,
                          count: _votes?.upvotes ?? 0,
                          active: _userVote == 'up',
                          isUp: true,
                          isLoading: _voteLoading,
                          onTap: () => _castVote('up'),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: colors.outline.withOpacity(0.12),
                      ),
                      Expanded(
                        child: _VoteButton(
                          icon: Icons.thumb_down_rounded,
                          count: _votes?.downvotes ?? 0,
                          active: _userVote == 'down',
                          isUp: false,
                          isLoading: _voteLoading,
                          onTap: () => _castVote('down'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: widget.item.reasons.length,
                  itemBuilder: (context, index) {
                    final reason = widget.item.reasons[index];
                    final isMine = _isMyReason(reason);
                    final username =
                        reason.usernameFor(_serviceType) ?? 'Unknown';
                    final avatarUrl = reason.avatarFor(_serviceType);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMine
                            ? colors.primaryContainer.withOpacity(0.15)
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: isMine
                            ? Border.all(
                                color: colors.primary.withOpacity(0.3),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: colors.primary.withOpacity(
                                  0.1,
                                ),
                                backgroundImage: avatarUrl != null
                                    ? CachedNetworkImageProvider(avatarUrl)
                                    : null,
                                child: avatarUrl == null
                                    ? Text(
                                        username.isNotEmpty
                                            ? username[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: colors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (reason.user != null) {
                                      navigateToReasonAuthorProfile(
                                        reason,
                                        _serviceType,
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    if (reason.user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserRecommendationsPage(
                                                user: reason.user!,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: AzyXText(
                                          text: username,
                                          fontSize: 12,
                                          fontVariant: FontVariant.bold,
                                          color: colors.primary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (reason.user?.isAdmin == true) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 12,
                                          color: colors.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (isMine || _isAdmin) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _onEditReason(reason),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    size: 16,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _onDeleteReason(reason),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          AzyXText(
                            text: reason.text,
                            fontSize: 12,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool isUp;
  final bool isLoading;
  final VoidCallback onTap;
  const _VoteButton({
    required this.icon,
    required this.count,
    required this.active,
    required this.isUp,
    required this.isLoading,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeColor = isUp ? colors.primary : colors.error;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: colors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: active
                          ? activeColor
                          : colors.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    AzyXText(
                      text: '$count',
                      fontSize: 11,
                      fontVariant: FontVariant.bold,
                      color: active
                          ? activeColor
                          : colors.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
