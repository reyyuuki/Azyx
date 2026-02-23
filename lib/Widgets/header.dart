import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Extensions/ExtensionScreen.dart';
import 'package:azyx/Screens/Settings/setting_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
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

  void showBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return AzyXGradientContainer(
          height: 320,
          child: Column(
            children: [
              AzyXContainer(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Obx(
                      () => AzyXContainer(
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
                                  imageUrl:
                                      serviceHandler.userData.value.avatar!,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, _) =>
                                      const Icon(Broken.user),
                                ),
                              )
                            : const Icon(Broken.user),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Get.back();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1, 0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const ExtensionScreen();
                      },
                    ),
                  );
                },
                child: _buildTile("Extensions", Icons.extension),
              ),
              InkWell(
                onTap: () {
                  Get.back();
                  ServiceBottomSheet.showServiceBottomSheet(context);
                },
                child: _buildTile("Service", Icons.sync),
              ),
              InkWell(
                onTap: () {
                  Get.back();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1, 0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const SettingScreen();
                      },
                    ),
                  );
                },
                child: _buildTile("Settings", Icons.settings),
              ),
              serviceHandler.userData.value.name != null
                  ? InkWell(
                      onTap: () {
                        serviceHandler.logout();
                        Get.back();
                      },
                      child: _buildTile("LogOut", Icons.logout),
                    )
                  : InkWell(
                      onTap: () {
                        serviceHandler.login();
                        Get.back();
                      },
                      child: _buildTile("Login", Icons.login),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(String name, IconData icon) {
    return AzyXContainer(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AzyXText(text: name, fontVariant: FontVariant.bold, fontSize: 16),
          Icon(icon),
        ],
      ),
    );
  }
}
