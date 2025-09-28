// ignore_for_file: must_be_immutable
import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:azyx/Widgets/helper/platform_builder.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatefulWidget {
  final List<Widget> screens;
  int index;
  final Function(int) onChanged;

  CustomNavBar({
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
  List<AnimationController> _bounceControllers = [];
  List<Animation<double>> _bounceScaleAnimations = [];
  List<Animation<double>> _bounceOpacityAnimations = [];

  final List<IconData> _icons = [
    Broken.home_1,
    Broken.element_4,
    Icons.movie_filter,
    Broken.book,
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.index;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<double>(
          begin: widget.index.toDouble(),
          end: widget.index.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubicEmphasized,
          ),
        );

    for (int i = 0; i < widget.screens.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      final scaleAnimation = Tween<double>(
        begin: 0.7,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

      final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        ),
      );

      _bounceControllers.add(controller);
      _bounceScaleAnimations.add(scaleAnimation);
      _bounceOpacityAnimations.add(opacityAnimation);
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
            curve: Curves.easeInOutCubicEmphasized,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = getResponsiveSize(
      context,
      mobileSize: 24,
      dektopSize: Get.width * 0.3,
    );
    final availableWidth = screenWidth - (horizontalMargin * 2) - 8;
    final itemWidth = availableWidth / widget.screens.length;

    return AnimatedItemWrapper(
      child: Container(
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 20),
        height: 64,
        child: Container(
          padding: const EdgeInsets.only(left: 5.5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainer.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _slideAnimation.value * itemWidth,
                    top: 4,
                    bottom: 4,
                    child: Container(
                      width: itemWidth - 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
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
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _bounceControllers[item.key],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isActive
                                    ? _bounceScaleAnimations[item.key].value
                                    : 1.0,
                                child: Opacity(
                                  opacity: isActive
                                      ? _bounceOpacityAnimations[item.key].value
                                      : 1.0,
                                  child: AnimatedScale(
                                    scale: isActive ? 1.2 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOutCubicEmphasized,
                                    child: AnimatedRotation(
                                      turns: isActive ? 0.01 : 0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOutCubicEmphasized,
                                      child: Icon(
                                        _icons[item.key],
                                        size: 22,
                                        color: isActive
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.65),
                                      ),
                                    ),
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
    );
  }
}
