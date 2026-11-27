import 'dart:developer';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Models/anime_all_data.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/Widgets/list_editor_sheet.dart';
import 'package:azyx/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final AnilistAddToListController anilistAddToListController =
    Get.find<AnilistAddToListController>();

class AnilistAddToListController extends GetxController {
  TextEditingController? controller;

  void findAnime(AnilistMediaData data) {
    for (var i in serviceHandler.userAnimeList) {
      Utils.log(i.id.toString());
    }
    if (serviceHandler.userAnimeList.isNotEmpty) {
      serviceHandler.currentMedia.value = serviceHandler.userAnimeList
          .firstWhere(
            (i) => i.id == data.id!,
            orElse: () {
              return UserMedia(
                id: data.id,
                progress: 0,
                episodes: data.episodes,
                title: data.title,
                image: data.image,
              );
            },
          );
      serviceHandler.currentMedia.value.status =
          serviceHandler.currentMedia.value.status ?? '';
    }
  }

  void findManga(AnilistMediaData data) {
    if (serviceHandler.userMangaList.isNotEmpty) {
      serviceHandler.currentMedia.value = serviceHandler.userMangaList
          .firstWhere(
            (i) => i.id == data.id,
            orElse: () {
              return UserMedia(
                id: data.id,
                progress: 0,
                episodes: data.episodes,
                title: data.title,
                image: data.image,
              );
            },
          );
      serviceHandler.currentMedia.value.status =
          serviceHandler.currentMedia.value.status ?? '';
    }
  }

  void updateAnimeProgress(AnimeAllData data, int number) {
    if (serviceHandler.userAnimeList.isNotEmpty) {
      try {
        serviceHandler.currentMedia.value = serviceHandler.userAnimeList
            .firstWhere(
              (i) => i.title == data.title,
              orElse: () {
                return UserMedia(
                  id: data.id.toString(),
                  status: 'CURRENT',
                  score: 0,
                  progress: number,
                );
              },
            );
        serviceHandler.updateListEntry(
          UserMedia(
            id: serviceHandler.currentMedia.value.id!,
            progress: number,
            status: serviceHandler.currentMedia.value.status,
          ),
          isAnime: true,
        );
      } catch (e) {
        log('Error in updateAnimeProgress: $e');
      }
    }
  }

  void addToListSheet(
    BuildContext context,
    String image,
    String title,
    int totalEpisodes,
    String id,
  ) {
    _openEditorSheet(
      context: context,
      image: image,
      title: title,
      totalCount: totalEpisodes,
      id: id,
      isManga: false,
    );
  }

  void addToMangaListSheet(
    BuildContext context,
    String image,
    String title,
    int totalChapters,
  ) {
    _openEditorSheet(
      context: context,
      image: image,
      title: title,
      totalCount: totalChapters,
      id: serviceHandler.currentMedia.value.id ?? '',
      isManga: true,
    );
  }

  void _openEditorSheet({
    required BuildContext context,
    required String image,
    required String title,
    required int totalCount,
    required String id,
    required bool isManga,
  }) {
    final current = serviceHandler.currentMedia.value;
    final list = isManga
        ? serviceHandler.userMangaList
        : serviceHandler.userAnimeList;
    final existing = list.firstWhereOrNull((e) => e.id == id);
    final entryId = current.entryId ?? existing?.entryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87.withValues(alpha: 0.6),
      backgroundColor: Colors.transparent,
      builder: (_) => ListEditorSheet(
        title: title,
        image: image,
        totalCount: totalCount,
        isManga: isManga,
        initialStatus: current.status ?? existing?.status ?? 'CURRENT',
        initialScore: (current.score ?? existing?.score ?? 0).toDouble(),
        initialProgress: current.progress ?? existing?.progress ?? 0,
        initialStartedAt: current.startedAt ?? existing?.startedAt,
        initialCompletedAt: current.completedAt ?? existing?.completedAt,
        initialIsPrivate: current.isPrivate ?? existing?.isPrivate ?? false,
        initialRepeat: current.repeat ?? existing?.repeat ?? 0,
        canDelete: entryId != null,
        onSave: (result) async {
          final targetId = id.isNotEmpty
              ? id
              : (current.id ?? existing?.id ?? '');
          if (targetId.isEmpty) return;
          await serviceHandler.updateListEntry(
            UserMedia(
              id: targetId,
              status: result.status,
              score: result.score > 0 ? result.score : null,
              progress: result.progress,
              startedAt: result.startedAt,
              completedAt: result.completedAt,
              isPrivate: result.isPrivate,
              repeat: result.repeat,
            ),
            isAnime: !isManga,
          );
          azyxSnackBar('Saved $title to list');
        },
        onDelete: entryId != null
            ? () async {
                final ok = await serviceHandler.deleteMediaListEntry(entryId);
                azyxSnackBar(
                  ok ? 'Removed $title from list' : 'Failed to remove $title',
                );
              }
            : null,
      ),
    );
  }
}
