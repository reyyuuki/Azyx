import 'dart:developer';

import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Extensions/ExtensionScreen.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Screens/Settings/setting_screen.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final AnilistAuth controller = Get.put(AnilistAuth());

  @override
  void initState() {
    super.initState();
    log("User: ${controller.userData.value.avatar}");
  }

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
                  controller.userData.value.name != null
                      ? controller.userData.value.name!
                      : "Guest",
                  style:
                      const TextStyle(fontFamily: "Poppins-Bold", fontSize: 18),
                  textAlign: TextAlign.start,
                ),
              ),
              const AzyXText(
                "Enjoy unlimited entertainment",
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ],
          ),
          Obx(
            () => GestureDetector(
              onTap: () {
                showBottomSheet(context);
              },
              child: AzyXContainer(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(50)),
                  child: controller.userData.value.avatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: controller.userData.value.avatar!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Broken.setting_2)),
            ),
          )
        ],
      ),
    );
  }

  void showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (context) {
          final bool isDarkMode =
              Provider.of<ThemeProvider>(context).isDarkMode!;
          return AzyXContainer(
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            Theme.of(context).colorScheme.surface.withAlpha(20),
                            Theme.of(context).colorScheme.primary.withAlpha(90),
                          ]
                        : [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            height: 250,
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
                          controller.userData.value.name != null
                              ? controller.userData.value.name!
                              : "Guest",
                          style: const TextStyle(
                              fontFamily: "Poppins-Bold", fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Obx(() => AzyXContainer(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                              borderRadius: BorderRadius.circular(50)),
                          child: controller.userData.value.avatar != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl: controller.userData.value.avatar!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Broken.user))),
                    ],
                  ),
                ),
                GestureDetector(
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

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return const ExtensionScreen();
                          },
                        ),
                      );
                    },
                    child: tile("Extensions", Icons.extension)),
                GestureDetector(
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

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return SettingScreen();
                          },
                        ),
                      );
                    },
                    child: tile("Settings", Icons.settings)),
                controller.userData.value.name != null
                    ? GestureDetector(
                        onTap: () {
                          controller.logout();
                          Get.back();
                        },
                        child: tile("LogOut", Icons.logout))
                    : GestureDetector(
                        onTap: () {
                          controller.login();
                          Get.back();
                        },
                        child: tile("Login", Icons.login))
              ],
            ),
          );
        });
  }

  Widget tile(String name, IconData icon) {
    return AzyXContainer(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AzyXText(
            name,
            style: const TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
          ),
          Icon(icon)
        ],
      ),
    );
  }
}
