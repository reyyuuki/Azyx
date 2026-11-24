import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/glass_surface.dart';
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
    final tones = AzTonesProvider.of(context);
    final theme = Theme.of(context);

    return Obx(() {
      final media = controller.mediaData.value;
      final hasRelations = (media.relations?.isNotEmpty ?? false) ||
          (media.recommendations?.isNotEmpty ?? false);

      final tabs = <MapEntry<String, String>>[
        const MapEntry('ov', 'Overview'),
        const MapEntry('ep', 'Episodes'),
        if (hasRelations) const MapEntry('rl', 'Related'),
        const MapEntry('ch', 'Characters'),
        const MapEntry('cm', 'Community'),
      ];

      final currentTab = controller.activeTab.value;

      final hPad = MediaQuery.of(context).size.width < 600
          ? 16.0
          : AzTokens.horizontalPadding;

      return Container(
        height: 46,
        margin: EdgeInsets.symmetric(
          horizontal: hPad,
        ),
        constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
        child: GlassSurface(
          borderRadius: AzTokens.radiusTabContainer,
          padding: const EdgeInsets.all(4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: tabs.map((tab) {
                final isSelected = currentTab == tab.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AzTokens.radiusTabItem),
                    onTap: () => controller.scrollToSection(tab.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? tones.soft : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AzTokens.radiusTabItem),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.value,
                        style: AzTokens.body(
                          color: isSelected
                              ? tones.accent
                              : theme.colorScheme.onSurfaceVariant,
                          weight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }
}
