import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:flutter/material.dart';

class DetailsSkeleton extends StatelessWidget {
  const DetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = AzTokens.isExpanded(context);
    final width = MediaQuery.of(context).size.width;
    final coverW = AzTokens.coverWidth(width);
    final boxColor =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
    final boxLightColor =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.20);

    final infoPlaceholder = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              height: 26,
              width: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AzTokens.radiusChips),
                color: boxColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 26,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AzTokens.radiusChips),
                color: boxColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 36,
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: boxColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: boxLightColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              height: 26,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AzTokens.radiusChips),
                color: boxLightColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 26,
              width: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AzTokens.radiusChips),
                color: boxLightColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 26,
              width: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AzTokens.radiusChips),
                color: boxLightColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: boxColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: boxLightColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: boxColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 70,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: boxLightColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AzTokens.heroPaddingTop,
        left: AzTokens.contentPaddingHorizontal,
        right: AzTokens.contentPaddingHorizontal,
        bottom: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isExpanded
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: coverW,
                            height: coverW * 1.48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AzTokens.radiusCover),
                              color: boxColor,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(child: infoPlaceholder),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: coverW,
                            height: coverW * 1.48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AzTokens.radiusCover),
                              color: boxColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          infoPlaceholder,
                        ],
                      ),
                const SizedBox(height: 32),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AzTokens.radiusTabContainer),
                    color: boxLightColor,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  height: 24,
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: boxColor,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: boxLightColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: boxLightColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: boxLightColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
