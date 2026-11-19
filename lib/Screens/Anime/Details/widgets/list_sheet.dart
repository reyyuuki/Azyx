import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListSheet extends StatelessWidget {
  final AnimeDetailsController controller;

  const ListSheet({
    super.key,
    required this.controller,
  });

  static const List<String> statuses = [
    'Currently watching',
    'Plan to watch',
    'Completed',
    'Paused',
    'Dropped',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tones = AzTonesProvider.of(context);

    return Obx(() {
      final currentStatus = controller.listStatus.value;
      final hasCurrentStatus = currentStatus.isNotEmpty;

      return Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AzTokens.radiusBottomSheet),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Text(
              'Add to list',
              style: AzTokens.body(
                color: theme.colorScheme.onSurface,
                weight: FontWeight.w600,
                size: 17,
              ),
            ),
            const SizedBox(height: 8),
            ...statuses.map((status) {
              final isSelected =
                  currentStatus.toLowerCase() == status.toLowerCase();

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.setMediaListStatus(status);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status,
                        style: AzTokens.body(
                          color: isSelected
                              ? tones.accent
                              : theme.colorScheme.onSurface,
                          weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          size: 15.5,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: tones.accent,
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (hasCurrentStatus)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.deleteFromList();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Remove from list',
                        style: AzTokens.body(
                          color: theme.colorScheme.error,
                          weight: FontWeight.w500,
                          size: 15.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
