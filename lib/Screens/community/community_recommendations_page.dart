import 'dart:ui';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/services/community_service.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Screens/Anime/Details/anime_details_screen.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/reasons_sheet.dart';
import 'package:azyx/Database/kv_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class CommunityRecommendationsPage extends StatefulWidget {
  final MediaType type;
  final String category;
  final String title;
  const CommunityRecommendationsPage({
    super.key,
    required this.category,
    required this.type,
    this.title = 'Community Recommendations',
  });
  @override
  State<CommunityRecommendationsPage> createState() =>
      _CommunityRecommendationsPageState();
}

class _CommunityRecommendationsPageState
    extends State<CommunityRecommendationsPage> {
  final Map<String, VoteResult?> _votes = {};
  final Map<String, String?> _userVotes = {};
  final Map<String, bool> _loading = {};
  bool _isGridView = KvHelper.get<bool>('communityListViewIsGrid', true);
  @override
  void initState() {
    super.initState();
    final svc = Get.find<CommunityService>();
    svc.fetchAll().then((_) {
      if (CommunityService.votingEnabled) {
        final sourceList = _getFilteredData();
        for (final item in sourceList) {
          _loadVotes(item);
        }
      }
    });
  }

  String _mediaType(CommunityMedia item) {
    final id = item.media.id ?? '';
    if (id.endsWith('*MOVIE')) return 'movie';
    if (id.endsWith('*SERIES')) return 'show';
    return widget.type == MediaType.manga ? 'manga' : 'anime';
  }

  String _mediaId(CommunityMedia item) {
    final id = item.media.id ?? '';
    if (id.contains('*')) return id.split('*').first;
    return id;
  }

  List<CommunityMedia> _getFilteredData() {
    final svc = Get.find<CommunityService>();
    return switch (widget.category) {
      'anime' => svc.getFilteredCommunityAnimes(),
      'manga' => svc.getFilteredCommunityMangas(),
      'shows' => svc.getFilteredCommunityShows(),
      'movies' => svc.getFilteredCommunityMovies(),
      _ => <CommunityMedia>[],
    };
  }

  Future<void> _loadVotes(CommunityMedia item) async {
    final id = _mediaId(item);
    final serviceHandler = Get.find<ServiceHandler>();
    final profile = serviceHandler.userData.value;
    final serviceType = serviceHandler.serviceType.value;
    int? anilistId;
    int? malId;
    int? simklId;
    if (serviceType == ServicesType.anilist) {
      anilistId = profile.id;
    } else if (serviceType == ServicesType.mal) {
      malId = profile.id;
    } else if (serviceType == ServicesType.simkl) {
      simklId = profile.id;
    }
    final result = await CommunityService.fetchVotes(
      _mediaType(item),
      id,
      anilistUserId: anilistId,
      malUserId: malId,
      simklUserId: simklId,
    );
    if (mounted) {
      setState(() {
        _votes[id] = result;
        if (result != null) {
          _userVotes[id] = result.userVote;
        }
      });
    }
  }

  Future<void> _castVote(CommunityMedia item, String direction) async {
    final id = _mediaId(item);
    if (_loading[id] == true) return;
    final serviceHandler = Get.find<ServiceHandler>();
    final profile = serviceHandler.userData.value;
    final serviceType = serviceHandler.serviceType.value;
    int? anilistId;
    int? malId;
    int? simklId;
    String displayName = profile.name ?? 'User';
    if (serviceType == ServicesType.anilist) {
      anilistId = profile.id;
    } else if (serviceType == ServicesType.mal) {
      malId = profile.id;
    } else if (serviceType == ServicesType.simkl) {
      simklId = profile.id;
    } else if (profile.id != null) {
      anilistId = profile.id;
    }
    if (anilistId == null && malId == null && simklId == null) {
      azyxSnackBar('Please log in to AniList or MAL to vote!');
      return;
    }
    setState(() => _loading[id] = true);
    final result = await CommunityService.castVote(
      mediaType: _mediaType(item),
      mediaId: id,
      direction: direction,
      anilistUserId: anilistId,
      malUserId: malId,
      simklUserId: simklId,
      displayName: displayName,
    );
    if (mounted) {
      setState(() {
        _loading[id] = false;
        if (result != null) {
          _votes[id] = result;
          _userVotes[id] = result.userVote;
        }
      });
    }
  }

  void _showSettingsSheet(BuildContext context) {
    final svc = Get.find<CommunityService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Obx(() {
        final colors = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AzyXText(
                      text: 'Filter Settings',
                      fontSize: 16,
                      fontVariant: FontVariant.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const AzyXText(
                      text: 'Hide by List Status',
                      fontSize: 13,
                      fontVariant: FontVariant.semiBold,
                    ),
                    subtitle: const AzyXText(
                      text: 'Filter out entries already in your lists',
                      fontSize: 11,
                    ),
                    value: svc.filterByListEnabled.value,
                    onChanged: (v) {
                      svc.filterByListEnabled.value = v;
                      KvHelper.set('community_filterByListEnabled', v);
                    },
                  ),
                  if (svc.filterByListEnabled.value) ...[
                    SwitchListTile(
                      title: const AzyXText(
                        text: 'Hide Completed',
                        fontSize: 12,
                      ),
                      value: svc.filterCompleted.value,
                      onChanged: (v) {
                        svc.filterCompleted.value = v;
                        KvHelper.set('community_filterCompleted', v);
                      },
                    ),
                    SwitchListTile(
                      title: const AzyXText(
                        text: 'Hide Watching / Reading',
                        fontSize: 12,
                      ),
                      value: svc.filterWatching.value,
                      onChanged: (v) {
                        svc.filterWatching.value = v;
                        KvHelper.set('community_filterWatching', v);
                      },
                    ),
                    SwitchListTile(
                      title: const AzyXText(text: 'Hide Dropped', fontSize: 12),
                      value: svc.filterDropped.value,
                      onChanged: (v) {
                        svc.filterDropped.value = v;
                        KvHelper.set('community_filterDropped', v);
                      },
                    ),
                    SwitchListTile(
                      title: const AzyXText(
                        text: 'Hide Planning',
                        fontSize: 12,
                      ),
                      value: svc.filterPlanning.value,
                      onChanged: (v) {
                        svc.filterPlanning.value = v;
                        KvHelper.set('community_filterPlanning', v);
                      },
                    ),
                    SwitchListTile(
                      title: const AzyXText(
                        text: 'Hide On Hold / Paused',
                        fontSize: 12,
                      ),
                      value: svc.filterPaused.value,
                      onChanged: (v) {
                        svc.filterPaused.value = v;
                        KvHelper.set('community_filterPaused', v);
                      },
                    ),
                    SwitchListTile(
                      title: const AzyXText(
                        text: 'Hide Rewatching',
                        fontSize: 12,
                      ),
                      value: svc.filterRepeating.value,
                      onChanged: (v) {
                        svc.filterRepeating.value = v;
                        KvHelper.set('community_filterRepeating', v);
                      },
                    ),
                  ],
                  SwitchListTile(
                    title: const AzyXText(
                      text: 'Hide NSFW',
                      fontSize: 13,
                      fontVariant: FontVariant.semiBold,
                    ),
                    value: svc.hideNsfw.value,
                    onChanged: (v) {
                      svc.hideNsfw.value = v;
                      KvHelper.set('hideNsfwRecommendations', v);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: AzyXText(
          text: widget.title,
          fontSize: 18,
          fontVariant: FontVariant.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
                KvHelper.set('communityListViewIsGrid', _isGridView);
              });
            },
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
          IconButton(
            onPressed: () => _showSettingsSheet(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final data = _getFilteredData();
        final crossAxisCount = isDesktop ? 5 : 3;
        final isLoading = switch (widget.category) {
          'anime' => Get.find<CommunityService>().isLoadingAnime.value,
          'manga' => Get.find<CommunityService>().isLoadingManga.value,
          'shows' => Get.find<CommunityService>().isLoadingShows.value,
          'movies' => Get.find<CommunityService>().isLoadingMovies.value,
          _ => false,
        };
        if (isLoading && data.isEmpty) {
          return const Center(child: LoadingIndicatorM3E());
        }
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_off_rounded,
                  size: 48,
                  color: colors.onSurfaceVariant.withOpacity(0.5),
                ),
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
        return RefreshIndicator(
          onRefresh: () => Get.find<CommunityService>().refreshData(),
          child: _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 16,
                    childAspectRatio: isDesktop ? 0.6 : 0.48,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final id = _mediaId(item);
                    return _CommunityCard(
                      item: item,
                      type: widget.type,
                      votes: _votes[id],
                      userVote: _userVotes[id],
                      isLoading: _loading[id] == true,
                      onVote: (dir) => _castVote(item, dir),
                      mediaType: _mediaType(item),
                      mediaId: id,
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final id = _mediaId(item);
                    return _CommunityListTile(
                      item: item,
                      type: widget.type,
                      votes: _votes[id],
                      userVote: _userVotes[id],
                      isLoading: _loading[id] == true,
                      onVote: (dir) => _castVote(item, dir),
                      mediaType: _mediaType(item),
                      mediaId: id,
                    );
                  },
                ),
        );
      }),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityMedia item;
  final MediaType type;
  final VoteResult? votes;
  final String? userVote;
  final bool isLoading;
  final void Function(String direction) onVote;
  final String mediaType;
  final String mediaId;
  const _CommunityCard({
    required this.item,
    required this.type,
    required this.votes,
    required this.userVote,
    required this.isLoading,
    required this.onVote,
    required this.mediaType,
    required this.mediaId,
  });
  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => type == MediaType.manga
            ? MangaDetailsScreen(
                smallMedia: CarousaleData(
                  id: item.media.id ?? '',
                  image: item.media.image ?? '',
                  title: item.media.title ?? '',
                ),
                tagg: 'community-all-${item.media.id}',
                isOffline: false,
              )
            : AnimeDetailsScreen(
                smallMedia: CarousaleData(
                  id: item.media.id ?? '',
                  image: item.media.image ?? '',
                  title: item.media.title ?? '',
                ),
                tagg: 'community-all-${item.media.id}',
                isOffline: false,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final serviceType = Get.find<ServiceHandler>().serviceType.value;
    final author = item.usernameFor(serviceType) ?? '';
    final avatarUrl = item.avatarFor(serviceType);
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.08), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetails(context),
              onLongPress: () => ReasonsSheet.show(
                context,
                item: item,
                mediaItemType: type,
                voteMediaType: mediaType,
                voteMediaId: mediaId,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: item.media.image ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, _) =>
                            const Center(child: LoadingIndicatorM3E()),
                        errorWidget: (context, _, __) => Container(
                          color: colors.surfaceContainerLow,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  if (item.media.rating != null && item.media.rating != '?')
                    Positioned(
                      top: 6,
                      right: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            color: Colors.black.withOpacity(0.4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  item.media.rating!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          color: Colors.black.withOpacity(0.4),
                          child: item.hasMultipleReasons
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.people_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${item.reasonCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : author.isEmpty
                              ? const SizedBox.shrink()
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 6,
                                      backgroundImage: avatarUrl != null
                                          ? CachedNetworkImageProvider(
                                              avatarUrl,
                                            )
                                          : null,
                                      backgroundColor: colors.primary
                                          .withOpacity(0.1),
                                      child: avatarUrl == null
                                          ? Text(
                                              author[0].toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 5,
                                                color: colors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 45,
                                      ),
                                      child: Text(
                                        author,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 7.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AzyXText(
            text: item.displayTitle,
            fontSize: 10.5,
            fontVariant: FontVariant.bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 10,
                color: colors.primary.withOpacity(0.6),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  item.reason != null && item.reason!.isNotEmpty
                      ? item.reason!
                      : "Highly recommended by the community.",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: colors.onSurfaceVariant.withOpacity(0.8),
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          if (CommunityService.votingEnabled) ...[
            const SizedBox(height: 6),
            _VoteSmallBar(
              votes: votes,
              userVote: userVote,
              isLoading: isLoading,
              onVote: onVote,
            ),
          ],
        ],
      ),
    );
  }
}

class _CommunityListTile extends StatelessWidget {
  final CommunityMedia item;
  final MediaType type;
  final VoteResult? votes;
  final String? userVote;
  final bool isLoading;
  final void Function(String direction) onVote;
  final String mediaType;
  final String mediaId;
  const _CommunityListTile({
    required this.item,
    required this.type,
    required this.votes,
    required this.userVote,
    required this.isLoading,
    required this.onVote,
    required this.mediaType,
    required this.mediaId,
  });
  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => type == MediaType.manga
            ? MangaDetailsScreen(
                smallMedia: CarousaleData(
                  id: item.media.id ?? '',
                  image: item.media.image ?? '',
                  title: item.media.title ?? '',
                ),
                tagg: 'community-all-${item.media.id}',
                isOffline: false,
              )
            : AnimeDetailsScreen(
                smallMedia: CarousaleData(
                  id: item.media.id ?? '',
                  image: item.media.image ?? '',
                  title: item.media.title ?? '',
                ),
                tagg: 'community-all-${item.media.id}',
                isOffline: false,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final serviceType = Get.find<ServiceHandler>().serviceType.value;
    final author = item.usernameFor(serviceType) ?? '';
    final avatarUrl = item.avatarFor(serviceType);
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      onLongPress: () => ReasonsSheet.show(
        context,
        item: item,
        mediaItemType: type,
        voteMediaType: mediaType,
        voteMediaId: mediaId,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.primary.withOpacity(0.08),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.media.image ?? '',
                  width: 85,
                  height: 115,
                  fit: BoxFit.cover,
                  placeholder: (context, _) =>
                      const Center(child: LoadingIndicatorM3E()),
                  errorWidget: (context, _, __) => Container(
                    width: 85,
                    height: 115,
                    color: colors.surfaceContainerHigh,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
                if (item.media.rating != null && item.media.rating != '?')
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          color: Colors.black.withOpacity(0.4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 9,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.media.rating!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AzyXText(
                      text: item.displayTitle,
                      fontSize: 13,
                      fontVariant: FontVariant.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 10,
                          color: colors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: AzyXText(
                            text: item.reason != null && item.reason!.isNotEmpty
                                ? item.reason!
                                : "Highly recommended by the community.",
                            fontSize: 11,
                            color: colors.onSurfaceVariant.withOpacity(0.8),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (author.isNotEmpty) ...[
                          CircleAvatar(
                            radius: 8,
                            backgroundImage: avatarUrl != null
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null,
                            backgroundColor: colors.primary.withOpacity(0.1),
                            child: avatarUrl == null
                                ? Text(
                                    author[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 6),
                          AzyXText(
                            text: author,
                            fontSize: 11,
                            fontVariant: FontVariant.semiBold,
                            color: colors.primary,
                          ),
                          if (item.isFirstReasonAdmin) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: colors.primary,
                            ),
                          ],
                          const SizedBox(width: 12),
                        ],
                        if (item.hasMultipleReasons)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 10,
                                  color: colors.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                AzyXText(
                                  text: '${item.reasonCount} recs',
                                  fontSize: 8.5,
                                  color: colors.onSecondaryContainer,
                                  fontVariant: FontVariant.semiBold,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (CommunityService.votingEnabled) ...[
                      const SizedBox(height: 6),
                      _VoteSmallBar(
                        votes: votes,
                        userVote: userVote,
                        isLoading: isLoading,
                        onVote: onVote,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteSmallBar extends StatelessWidget {
  final VoteResult? votes;
  final String? userVote;
  final bool isLoading;
  final void Function(String direction) onVote;
  const _VoteSmallBar({
    required this.votes,
    required this.userVote,
    required this.isLoading,
    required this.onVote,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.2,
                  color: colors.primary,
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: _VoteSmallButton(
                    icon: Icons.thumb_up_rounded,
                    count: votes?.upvotes ?? 0,
                    active: userVote == 'up',
                    isUp: true,
                    onTap: () => onVote('up'),
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: colors.outline.withOpacity(0.12),
                ),
                Expanded(
                  child: _VoteSmallButton(
                    icon: Icons.thumb_down_rounded,
                    count: votes?.downvotes ?? 0,
                    active: userVote == 'down',
                    isUp: false,
                    onTap: () => onVote('down'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _VoteSmallButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool isUp;
  final VoidCallback onTap;
  const _VoteSmallButton({
    required this.icon,
    required this.count,
    required this.active,
    required this.isUp,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeColor = isUp ? colors.primary : colors.error;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 11,
              color: active
                  ? activeColor
                  : colors.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: active
                    ? activeColor
                    : colors.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
