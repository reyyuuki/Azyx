import 'dart:ui';
import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:azyx/Widgets/helper/platform_builder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatefulWidget {
  final List<Widget> screens;
  final int index;
  final Function(int) onChanged;
  const CustomNavBar({
    super.key,
    required this.screens,
    required this.index,
    required this.onChanged,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  int _previousIndex = 0;
  final List<AnimationController> _bounceControllers = [];
  final List<Animation<double>> _bounceScaleAnimations = [];
  final List<IconData> _icons = [
    Broken.home_1,
    Broken.element_4,
    Icons.movie_filter_rounded,
    Broken.book,
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.index;
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _slideAnimation =
        Tween<double>(
          begin: widget.index.toDouble(),
          end: widget.index.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.fastOutSlowIn,
          ),
        );
    for (int i = 0; i < widget.screens.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      _bounceControllers.add(controller);
      _bounceScaleAnimations.add(scaleAnimation);
    }
    _bounceControllers[widget.index].forward();
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _updateSlideAnimation();
      _triggerBounceAnimation(widget.index);
    }
  }

  void _updateSlideAnimation() {
    _previousIndex = widget.index == 0
        ? _slideAnimation.value.round()
        : _previousIndex;
    _slideAnimation =
        Tween<double>(
          begin: _previousIndex.toDouble(),
          end: widget.index.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.fastOutSlowIn,
          ),
        );
    _slideController.forward(from: 0);
    _previousIndex = widget.index;
  }

  void _triggerBounceAnimation(int index) {
    _bounceControllers[index].reset();
    _bounceControllers[index].forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (final controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = getResponsiveSize(
      context,
      mobileSize: 28,
      dektopSize: Get.width * 0.3,
    );
    final availableWidth = screenWidth - (horizontalMargin * 2) - 12;
    final itemWidth = availableWidth / widget.screens.length;
    final navRadius = 36.0.radiusMultiplier().clamp(18.0, 44.0);

    return AnimatedItemWrapper(
      child: Container(
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 24),
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(navRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(navRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(navRadius),
                border: Border.all(
                  color: colors.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: _slideAnimation.value * itemWidth,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: itemWidth,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(navRadius - 4),
                            border: Border.all(
                              color: colors.primary.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.screens.asMap().entries.map((item) {
                      final isActive = widget.index == item.key;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onChanged(item.key),
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _bounceControllers[item.key],
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isActive
                                        ? _bounceScaleAnimations[item.key].value
                                        : 1.0,
                                    child: AnimatedScale(
                                      scale: isActive ? 1.12 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: Icon(
                                        _icons[item.key],
                                        size: 23,
                                        color: isActive
                                            ? colors.primary
                                            : colors.onSurfaceVariant
                                                  .withOpacity(0.55),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
