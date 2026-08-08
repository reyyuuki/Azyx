import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';
class ThemeTemplate extends StatelessWidget {
  final Color color;
  final bool? isBorder;
  final String name;
  const ThemeTemplate({
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
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.15),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              height: 120,
              width: 72,
              decoration: BoxDecoration(
                color: color,
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
                              width: 54,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.4)
                                    : const Color.fromARGB(140, 189, 189, 189),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 8,
                              width: 38,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(140, 189, 189, 189),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ball(),
                          _ball(),
                          _ball(),
                          _ball(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 12,
                        width: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
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
        const SizedBox(height: 8),
        AzyXText(
          text: name,
          fontSize: 12,
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
      height: 8,
      width: 8,
      decoration: const BoxDecoration(
        color: Color.fromARGB(140, 189, 189, 189),
        shape: BoxShape.circle,
      ),
    );
  }
}
