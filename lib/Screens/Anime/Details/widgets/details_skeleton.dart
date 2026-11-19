import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:flutter/material.dart';

class DetailsSkeleton extends StatefulWidget {
  const DetailsSkeleton({super.key});

  @override
  State<DetailsSkeleton> createState() => _DetailsSkeletonState();
}

class _DetailsSkeletonState extends State<DetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = AzTokens.isExpanded(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        final baseColor = theme.colorScheme.surfaceContainer;
        final highlightColor = theme.colorScheme.surfaceContainerHighest;

        final gradient = LinearGradient(
          begin: Alignment(-2.0 + 4.0 * val, 0.0),
          end: Alignment(-1.0 + 4.0 * val, 0.0),
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
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
              constraints:
                  const BoxConstraints(maxWidth: AzTokens.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: isExpanded ? 200 : 140,
                        height: (isExpanded ? 200 : 140) * 1.5,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AzTokens.radiusCover),
                          gradient: gradient,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 28,
                              width: 220,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AzTokens.radiusChips),
                                gradient: gradient,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: gradient,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 20,
                              width: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: gradient,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AzTokens.radiusTabContainer),
                      gradient: gradient,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 24,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: gradient,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: gradient,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
