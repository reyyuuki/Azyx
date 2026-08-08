import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Extensions/ExtensionScreen.dart';
import 'package:azyx/Screens/Settings/setting_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/services_bottom_sheet.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    return AzyXContainer(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => AzyXText(
                  text: serviceHandler.userData.value.name != null
                      ? serviceHandler.userData.value.name!
                      : "Guest",
                  fontVariant: FontVariant.bold,
                  fontSize: 18,
                  textAlign: TextAlign.start,
                ),
              ),
              const AzyXText(text: "Enjoy unlimited entertainment"),
            ],
          ),
          Obx(
            () => InkWell(
              onTap: () {
                showBottomSheet(context);
              },
              child: AzyXContainer(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: serviceHandler.userData.value.avatar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: serviceHandler.userData.value.avatar!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, _) =>
                              const Icon(Broken.user),
                        ),
                      )
                    : const Icon(Broken.setting_2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            top: 10,
            left: 14,
            right: 14,
            bottom: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 3.5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Obx(() {
                final user = serviceHandler.userData.value;
                final isLoggedIn =
                    serviceHandler.isLoggedIn.value || user.name != null;
                final activeService = serviceHandler.serviceType.value.name
                    .toUpperCase();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surfaceContainer,
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.4,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  user.avatar != null && user.avatar!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user.avatar!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
                                        Broken.user,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : Icon(
                                      Broken.user,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLoggedIn
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AzyXText(
                              text: user.name ?? "Guest User",
                              fontVariant: FontVariant.bold,
                              fontSize: 15,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                AzyXText(
                                  text: isLoggedIn
                                      ? "$activeService CONNECTED"
                                      : "GUEST ACCOUNT",
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontVariant: FontVariant.bold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AzyXText(
                          text: isLoggedIn ? "Active" : "Guest",
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontVariant: FontVariant.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  children: [
                    _buildIosTile(
                      context,
                      title: "Extensions",
                      icon: Broken.category,
                      iconColor: theme.colorScheme.primary,
                      iconBgColor: theme.colorScheme.primary.withOpacity(0.15),
                      onTap: () {
                        Get.back();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            transitionsBuilder: (context, animation, _, child) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.easeOutCubic),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            pageBuilder: (_, __, ___) =>
                                const ExtensionScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 48,
                      endIndent: 14,
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildIosTile(
                      context,
                      title: "Active Service",
                      subtitle: serviceHandler.serviceType.value.name
                          .toUpperCase(),
                      icon: Broken.refresh,
                      iconColor: theme.colorScheme.secondary,
                      iconBgColor: theme.colorScheme.secondary.withOpacity(
                        0.15,
                      ),
                      onTap: () {
                        Get.back();
                        ServiceBottomSheet.showServiceBottomSheet(context);
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 48,
                      endIndent: 14,
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildIosTile(
                      context,
                      title: "Settings",
                      icon: Broken.setting_2,
                      iconColor: theme.colorScheme.tertiary,
                      iconBgColor: theme.colorScheme.tertiary.withOpacity(0.15),
                      onTap: () {
                        Get.back();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            transitionsBuilder: (context, animation, _, child) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.easeOutCubic),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            pageBuilder: (_, __, ___) => const SettingScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 48,
                      endIndent: 14,
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                    Obx(() {
                      final isLoggedIn =
                          serviceHandler.isLoggedIn.value ||
                          serviceHandler.userData.value.name != null;
                      final logColor = isLoggedIn
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary;
                      return _buildIosTile(
                        context,
                        title: isLoggedIn ? "Log Out" : "Log In",
                        icon: isLoggedIn ? Broken.logout : Broken.login,
                        iconColor: logColor,
                        iconBgColor: logColor.withOpacity(0.15),
                        textColor: logColor,
                        isLast: true,
                        onTap: () async {
                          Get.back();
                          if (isLoggedIn) {
                            serviceHandler.logout();
                          } else {
                            await Future.delayed(
                              const Duration(milliseconds: 150),
                            );
                            serviceHandler.login();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIosTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    Color? iconBgColor,
    Color? textColor,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveIconBgColor =
        iconBgColor ?? theme.colorScheme.primary.withOpacity(0.15);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: effectiveIconBgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: effectiveIconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AzyXText(
                text: title,
                fontVariant: FontVariant.bold,
                fontSize: 15,
                color: textColor ?? theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              AzyXText(
                text: subtitle,
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontVariant: FontVariant.bold,
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
