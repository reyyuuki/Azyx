import 'package:azyx/Controllers/services/community_service.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class UserRecommendationsPage extends StatefulWidget {
  final ReasonUserProfile user;
  const UserRecommendationsPage({
    super.key,
    required this.user,
  });
  @override
  State<UserRecommendationsPage> createState() =>
      _UserRecommendationsPageState();
}
class _UserRecommendationsPageState extends State<UserRecommendationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _refreshData();
  }
  Future<void> _refreshData() async {
    final svc = Get.find<CommunityService>();
    await svc.refreshData();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  List<_UserRecItem> _getRecommendations() {
    final svc = Get.find<CommunityService>();
    final user = widget.user;
    final items = <_UserRecItem>[];
    for (final item in svc.communityAnimes) {
      final reason = item.recommendationFrom(user);
      if (reason != null) {
        items.add(_UserRecItem(
          media: item.media,
          reason: reason,
          category: 'anime',
        ));
      }
    }
    for (final item in svc.communityMangas) {
      final reason = item.recommendationFrom(user);
      if (reason != null) {
        items.add(_UserRecItem(
          media: item.media,
          reason: reason,
          category: 'manga',
        ));
      }
    }
    for (final item in svc.communityShows) {
      final reason = item.recommendationFrom(user);
      if (reason != null) {
        items.add(_UserRecItem(
          media: item.media,
          reason: reason,
          category: 'shows',
        ));
      }
    }
    for (final item in svc.communityMovies) {
      final reason = item.recommendationFrom(user);
      if (reason != null) {
        items.add(_UserRecItem(
          media: item.media,
          reason: reason,
          category: 'movies',
        ));
      }
    }
    return items;
  }
  List<_UserRecItem> _filterByCategory(String category, List<_UserRecItem> all) {
    if (category == 'all') return all;
    return all.where((i) => i.category == category).toList();
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final username = widget.user.displayName ?? 'Unknown User';
    final avatarUrl = widget.user.displayAvatar;
    final isAdmin = widget.user.isAdmin;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
                backgroundColor: colors.primary.withOpacity(0.1),
                child: avatarUrl == null
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 10, color: colors.primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: AzyXText(
                  text: username,
                  fontSize: 14,
                  fontVariant: FontVariant.bold,
                  color: colors.primary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 4),
                Icon(Icons.verified_rounded, size: 16, color: colors.primary),
              ],
              const SizedBox(width: 4),
              AzyXText(
                text: "'s Recs",
                fontSize: 14,
                fontVariant: FontVariant.bold,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final allItems = _getRecommendations();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
              backgroundColor: colors.primary.withOpacity(0.1),
              child: avatarUrl == null
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 10, color: colors.primary, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AzyXText(
                text: username,
                fontSize: 14,
                fontVariant: FontVariant.bold,
                color: colors.primary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 4),
              Icon(Icons.verified_rounded, size: 16, color: colors.primary),
            ],
            const SizedBox(width: 4),
            AzyXText(
              text: "'s Recs",
              fontSize: 14,
              fontVariant: FontVariant.bold,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: 'All (${allItems.length})'),
            Tab(text: 'Anime (${allItems.where((i) => i.category == 'anime').length})'),
            Tab(text: 'Manga (${allItems.where((i) => i.category == 'manga').length})'),
            Tab(text: 'Shows (${allItems.where((i) => i.category == 'shows').length})'),
            Tab(text: 'Movies (${allItems.where((i) => i.category == 'movies').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrid(context, _filterByCategory('all', allItems)),
          _buildGrid(context, _filterByCategory('anime', allItems)),
          _buildGrid(context, _filterByCategory('manga', allItems)),
          _buildGrid(context, _filterByCategory('shows', allItems)),
          _buildGrid(context, _filterByCategory('movies', allItems)),
        ],
      ),
    );
  }
  Widget _buildGrid(BuildContext context, List<_UserRecItem> items) {
    final colors = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.playlist_remove_rounded, size: 48, color: colors.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 12),
            AzyXText(
              text: 'No recommendations found',
              color: colors.onSurfaceVariant.withOpacity(0.7),
              fontVariant: FontVariant.semiBold,
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _RecCard(item: items[index]);
      },
    );
  }
}
class _RecCard extends StatelessWidget {
  final _UserRecItem item;
  const _RecCard({required this.item});
  void _navigateToDetails(BuildContext context) {
    final isManga = item.category == 'manga';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isManga
            ? MangaDetailsScreen(
                smallMedia: CarousaleData(
                    id: item.media.id ?? '',
                    image: item.media.image ?? '',
                    title: item.media.title ?? ''),
                tagg: 'user-rec-${item.media.id}',
                isOffline: false,
              )
            : AnimeDetailsScreen(
                smallMedia: CarousaleData(
                    id: item.media.id ?? '',
                    image: item.media.image ?? '',
                    title: item.media.title ?? ''),
                tagg: 'user-rec-${item.media.id}',
                isOffline: false,
              ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.media.image ?? '',
                fit: BoxFit.cover,
                placeholder: (context, _) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, _, __) => Container(
                  color: colors.surfaceContainerLow,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          AzyXText(
            text: item.media.title ?? 'Unknown Title',
            fontSize: 11,
            fontVariant: FontVariant.bold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AzyXText(
            text: item.reason.text,
            fontSize: 9,
            color: colors.onSurfaceVariant.withOpacity(0.8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
class _UserRecItem {
  final Media media;
  final ReasonEntry reason;
  final String category;
  _UserRecItem({
    required this.media,
    required this.reason,
    required this.category,
  });
}
