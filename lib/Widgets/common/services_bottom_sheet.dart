import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceBottomSheet {
  static void showServiceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      // isScrollControlled: true,
      builder: (context) {
        return AzyXGradientContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 310,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const AzyXText(
                text: 'Select Service',
                fontSize: 20,
                fontVariant: FontVariant.bold,
              ),

              const SizedBox(height: 20),

              // Service tiles
              _buildServiceTile(
                context,
                name: 'Anilist',
                image: Assets.anilistLogo,
                serviceType: ServicesType.anilist,
              ),

              const SizedBox(height: 12),

              _buildServiceTile(
                context,
                name: 'MAL',
                image: Assets.malLogo,
                serviceType: ServicesType.mal,
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildServiceTile(
    BuildContext context, {
    required String name,
    required String image,
    required ServicesType serviceType,
  }) {
    return Obx(() {
      final isSelected = serviceHandler.serviceType.value == serviceType;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!isSelected) {
                serviceHandler.serviceType.value = serviceType;
                serviceHandler.refresh();

                // Optional: Close bottom sheet after selection
                Navigator.of(context).pop();

                // Optional: Show feedback
                Get.snackbar(
                  'Service Changed',
                  'Switched to $name',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Service logo with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      image,
                      width: 32,
                      height: 32,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Service name
                  Expanded(
                    child: AzyXText(
                      text: name,
                      fontSize: 16,
                      fontVariant:
                          isSelected ? FontVariant.bold : FontVariant.regular,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),

                  // Selection indicator
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                            key: const ValueKey('selected'),
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                            size: 24,
                            key: const ValueKey('unselected'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
