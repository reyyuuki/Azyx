import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Widgets/list_editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListSheet extends StatelessWidget {
  final AnimeDetailsController controller;

  const ListSheet({
    super.key,
    required this.controller,
  });

  String _mapDisplayToAniList(String display) {
    switch (display.toLowerCase()) {
      case 'currently watching':
        return 'CURRENT';
      case 'plan to watch':
        return 'PLANNING';
      case 'completed':
        return 'COMPLETED';
      case 'rewatching':
        return 'REPEATING';
      case 'paused':
        return 'PAUSED';
      case 'dropped':
        return 'DROPPED';
      default:
        return display.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = controller.mediaData.value;
    final mediaId = media.id ?? controller.currentAnimeId?.toString() ?? '';
    final existing = serviceHandler.userAnimeList.firstWhereOrNull(
      (e) => e.id == mediaId,
    );
    final entry = media.mediaListEntry;
    final initialStatus = entry?.status ??
        existing?.status ??
        (controller.listStatus.value.isNotEmpty
            ? _mapDisplayToAniList(controller.listStatus.value)
            : 'CURRENT');
    final initialProgress =
        entry?.progress ?? existing?.progress ?? controller.listProgress.value;
    final initialScore = entry?.score?.toDouble() ?? existing?.score ?? 0.0;
    final totalCount = media.episodes ?? existing?.episodes ?? 0;

    return ListEditorSheet(
      title: media.title ?? 'Unknown',
      image: media.image ?? '',
      totalCount: totalCount,
      isManga: false,
      initialStatus: initialStatus,
      initialScore: initialScore,
      initialProgress: initialProgress,
      initialStartedAt: existing?.startedAt,
      initialCompletedAt: existing?.completedAt,
      initialIsPrivate: existing?.isPrivate ?? false,
      initialRepeat: existing?.repeat ?? 0,
      canDelete: controller.listStatus.value.isNotEmpty ||
          entry != null ||
          existing != null,
      onSave: (result) => controller.saveMediaListEntry(result),
      onDelete: () => controller.deleteFromList(),
    );
  }
}
