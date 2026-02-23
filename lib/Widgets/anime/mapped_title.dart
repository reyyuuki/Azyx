import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class MappedTitle extends StatelessWidget {
  const MappedTitle({
    super.key,
    required this.name,
    required this.animeTitle,
    required this.totalEpisodes,
  });

  final Rx<String> animeTitle;
  final Rx<String> totalEpisodes;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(EvaIcons.link_2, color: colorScheme.primary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AzyXText(
                    text: "Mapped Title",
                    fontSize: 10,
                    fontVariant: FontVariant.bold,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  const SizedBox(height: 3),
                  AzyXText(
                    text: animeTitle.value,
                    fontVariant: FontVariant.bold,
                    fontSize: 14,
                    maxLines: 1,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AzyXText(
                text: "${totalEpisodes.value} EP",
                fontVariant: FontVariant.bold,
                fontSize: 12,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
