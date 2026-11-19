import 'package:azyx/Screens/Anime/Details/controller/anime_details_controller.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AzToast extends StatelessWidget {
  final AnimeDetailsController controller;

  const AzToast({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isVisible = controller.isToastVisible.value;
      final message = controller.toastMessage.value;

      return Positioned(
        left: 0,
        right: 0,
        bottom: 104,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: AnimatedSlide(
              offset: isVisible ? Offset.zero : const Offset(0, 0.4),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: GlassSurface(
                    borderRadius: 22.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      message,
                      style: AzTokens.body(
                        color: theme.colorScheme.onSurface,
                        weight: FontWeight.w500,
                        size: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
