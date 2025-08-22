// ignore_for_file: must_be_immutable
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/helper/platform_builder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatelessWidget {
  final List<Widget> screens;
  int index;
  final Function(int) onChanged;

  CustomNavBar({
    super.key,
    required this.screens,
    required this.index,
    required this.onChanged,
  });

  final List<IconData> _icons = [
    Broken.home_1,
    Broken.element_4,
    Icons.movie_filter,
    Broken.book,
    // Icons.book,
  ];

  @override
  Widget build(BuildContext context) {
    return AzyXContainer(
      margin: EdgeInsets.fromLTRB(
          getResponsiveSize(context,
              mobileSize: 15, dektopSize: Get.width * 0.35),
          0,
          getResponsiveSize(context,
              mobileSize: 15, dektopSize: Get.width * 0.35),
          20),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainer
                    .withOpacity(0.7),
                blurRadius: 10,
                spreadRadius: 2)
          ]),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: screens.asMap().entries.map((item) {
          final isActive = index == item.key;
          return GestureDetector(
            onTap: () => onChanged(item.key),
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                          color: isActive
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(1.glowMultiplier())
                              : Colors.transparent,
                          blurRadius: 10.blurMultiplier(),
                          spreadRadius: 2.spreadMultiplier())
                    ]),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: isActive ? 1.1 : 0.9),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        _icons[item.key],
                        size: 25,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
