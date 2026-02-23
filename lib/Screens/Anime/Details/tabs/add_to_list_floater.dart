import 'dart:ui';

import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class AddToListFloater extends StatelessWidget {
  final int? index;
  final OfflineItem data;
  final AnilistMediaData mediaData;

  const AddToListFloater({
    super.key,
    this.index,
    required this.data,
    required this.mediaData,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isLoggedIn = serviceHandler.userData.value.name != null;

      return Container(
        margin: const EdgeInsets.only(bottom: 28, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.15),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.06),
              blurRadius: 40,
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // ── Library / Bookmark Button ──
                  _LibraryButton(
                    isCompact: isLoggedIn,
                    onTap: () => _openLibrarySheet(context),
                  ),

                  if (isLoggedIn) ...[
                    const SizedBox(width: 8),

                    // ── Add-to-List Button ──
                    Expanded(
                      child: _AddToListButton(
                        mediaData: mediaData,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          anilistAddToListController.addToListSheet(
                            context,
                            mediaData.image ?? '',
                            mediaData.title ?? 'Unknown',
                            mediaData.episodes ?? 24,
                            mediaData.id!,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Library Bottom Sheet ──────────────────────────────────────────

  void _openLibrarySheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.55,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        IonIcons.bookmarks,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Library Collections",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Save to your personal collections",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Divider(
                color: colorScheme.outlineVariant.withOpacity(0.3),
                height: 1,
              ),
              const SizedBox(height: 8),

              // ── Collections List ──
              Flexible(
                child: Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        offlineController.offlineAnimeCategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index ==
                          offlineController.offlineAnimeCategories.length) {
                        return _CreateCollectionTile(
                          onTap: () => _showCreateDialog(context),
                        );
                      }

                      final category =
                          offlineController.offlineAnimeCategories[index];
                      final isSelected = category.anilistIds
                          .contains(data.mediaData.id)
                          .obs;

                      return _CollectionTile(
                        name: category.name!,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          isSelected.value = !isSelected.value;
                          if (isSelected.value) {
                            offlineController.addOfflineItem(
                              data,
                              category.name!,
                            );
                          } else {
                            offlineController.removeOfflineItem(
                              data,
                              category.name!,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  // ─── Create Collection Dialog ──────────────────────────────────────

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        title: Row(
          children: [
            Icon(EvaIcons.plus_circle, color: colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              "New Collection",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: "e.g. Watch Later",
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.6),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                offlineController.createCategory(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Create",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════

class _LibraryButton extends StatelessWidget {
  final bool isCompact;
  final VoidCallback onTap;

  const _LibraryButton({required this.isCompact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final child = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 54,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (isCompact)
              SizedBox(
                width: 54,
                child: Icon(
                  IonIcons.bookmarks,
                  color: colorScheme.primary,
                  size: 20,
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  IonIcons.bookmarks,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                "Save to Library",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );

    return isCompact ? child : Expanded(child: child);
  }
}

class _AddToListButton extends StatelessWidget {
  final AnilistMediaData mediaData;
  final VoidCallback onTap;

  const _AddToListButton({required this.mediaData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.82),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.35),
              blurRadius: 14,
              spreadRadius: -3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Obx(() {
          final status = serviceHandler.currentMedia.value.status;
          final hasStatus = status != null;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  hasStatus ? Icons.check_circle_rounded : Icons.add_rounded,
                  key: ValueKey(hasStatus),
                  color: colorScheme.onPrimary,
                  size: hasStatus ? 19 : 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                (status ?? "Add to List").toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 13,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final String name;
  final RxBool isSelected;
  final VoidCallback onTap;

  const _CollectionTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected.value
              ? colorScheme.primaryContainer.withOpacity(0.35)
              : colorScheme.surfaceContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected.value
                ? colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected.value
                  ? colorScheme.primary.withOpacity(0.15)
                  : colorScheme.surfaceContainerHighest.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              EvaIcons.folder,
              color: isSelected.value
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isSelected.value
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: SizedBox(
            width: 22,
            height: 22,
            child: CheckMark(
              active: isSelected.value,
              activeColor: colorScheme.primary,
              strokeWidth: 2.5,
              curve: Curves.easeOutCubic,
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateCollectionTile extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateCollectionTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            EvaIcons.plus_circle,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          "Create New Collection",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: colorScheme.primary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: colorScheme.primary.withOpacity(0.6),
        ),
      ),
    );
  }
}
