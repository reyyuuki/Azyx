import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
class CustomColorTemplate extends StatelessWidget {
  final Color color;
  final bool? isBorder;
  final String name;
  const CustomColorTemplate({
    super.key,
    required this.color,
    required this.isBorder,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = isBorder == true;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.12),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              height: 110,
              width: 68,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: 14,
                              width: 50,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 8,
                              width: 34,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ball(),
                          _ball(),
                          _ball(),
                          _ball(),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 12,
                        width: 46,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AzyXText(
          text: name,
          fontSize: 11,
          fontVariant: FontVariant.bold,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _ball() {
    return Container(
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}
