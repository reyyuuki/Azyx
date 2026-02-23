import 'dart:ui';

import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class MangaAddToList extends StatelessWidget {
  final int? index;
  final OfflineItem data;
  final AnilistMediaData mediaData;
  const MangaAddToList({
    super.key,
    this.index,
    required this.data,
    required this.mediaData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                if (serviceHandler.userData.value.name != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        anilistAddToListController.addToMangaListSheet(
                          context,
                          mediaData.image ?? '',
                          mediaData.title ?? 'Unknown',
                          mediaData.episodes ?? 24,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (serviceHandler.currentMedia.value.status ==
                                  null)
                                Icon(
                                  Icons.add_rounded,
                                  color: colorScheme.onPrimary,
                                  size: 22,
                                ),
                              if (serviceHandler.currentMedia.value.status ==
                                  null)
                                const SizedBox(width: 8),
                              Text(
                                (serviceHandler.currentMedia.value.status ??
                                        "Add to List")
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => addToLibrary(context),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      IonIcons.albums,
                      color: colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addToLibrary(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                "LIBRARY COLLECTIONS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  children: offlineController.offlineMangaCategories.map((i) {
                    final Rx<bool> isSelected = i.anilistIds
                        .contains(data.mediaData.id)
                        .obs;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () {
                          isSelected.value = !isSelected.value;
                          isSelected.value
                              ? offlineController.addMangaOfflineItem(
                                  data,
                                  i.name!,
                                )
                              : offlineController.removeMangaOfflineItem(
                                  data,
                                  i.name!,
                                );
                        },
                        leading: Icon(
                          EvaIcons.folder,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          i.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Obx(
                          () => SizedBox(
                            width: 20,
                            child: CheckMark(
                              active: isSelected.value,
                              activeColor: theme.colorScheme.primary,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () => dialogBox(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outline, width: 1),
                ),
                leading: const Icon(EvaIcons.plus_circle),
                title: const Text(
                  "CREATE NEW COLLECTION",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void dialogBox(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: const Text(
          "New Collection",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: "Collection Name",
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: () {
              offlineController.createMangaCategory(controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              "CREATE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
