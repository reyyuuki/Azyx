import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionTabs extends StatelessWidget {
  final AnimeDetailsController controller;

  const SectionTabs({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      const tabs = <MapEntry<String, String>>[
        MapEntry('ov', 'Details'),
        MapEntry('ep', 'Episodes'),
        MapEntry('cm', 'Comments'),
      ];

      final currentTab = controller.activeTab.value;

      final hPad = MediaQuery.of(context).size.width < 600
          ? 16.0
          : AzTokens.horizontalPadding;

      return Container(
        height: 48,
        margin: EdgeInsets.symmetric(
          horizontal: hPad,
        ),
        constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = currentTab == tab.key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => controller.scrollToSection(tab.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab.value,
                      style: AzTokens.body(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
