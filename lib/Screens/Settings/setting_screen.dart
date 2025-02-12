import 'package:azyx/Screens/Settings/Pages/theme_setting.dart';
import 'package:azyx/Screens/Settings/Pages/ui_settings.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../Widgets/common/custom_app_bar.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AzyXGradientContainer(
          child: ListView(
        children: [
          const CustomAppBar(
            title: "Settings",
            icon: Broken.setting_2,
          ),
          GestureDetector(
            onTap: () {
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
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const ThemeSetting();
                      }));
            },
            child: settingTile(
                context,
                "Theme",
                "Choose Vibe : Light, Dark, Dynamic",
                const Icon(Broken.brush_2)),
          ),
          GestureDetector(
            onTap: () {
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
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return UiSettings();
                      }));
            },
            child: settingTile(
                context,
                "UI",
                "Customize Your UI: Vibrant, Sleek",
                const Icon(Broken.brush_1)),
          ),
          GestureDetector(
            onTap: () {
              openDialogBox(context);
            },
            child: settingTile(context, "Clear Cache",
                "Reset All Cached Settings", const Icon(Broken.trash)),
          ),
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context,
              // PageRouteBuilder(
              //     transitionDuration: const Duration(milliseconds: 300),
              //     transitionsBuilder:
              //         (context, animation, secondaryAnimation, child) {
              //       const begin = Offset(1, 0);
              //       const end = Offset.zero;
              //       const curve = Curves.ease;

              //       var tween = Tween(begin: begin, end: end)
              //           .chain(CurveTween(curve: curve));
              //       var offsetAnimation = animation.drive(tween);

              //       return SlideTransition(
              //           position: offsetAnimation, child: child);
              //     },
              //     pageBuilder:
              //         (context, animation, secondaryAnimation) {
              //       return const AboutSettings();
              //     }));
            },
            child: settingTile(context, "About", "Discover More: About Us",
                const Icon(Broken.information)),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Hive.box('offline-data').clear();
              },
              child: const AzyXText("Testing"))
        ],
      )),
    );
  }

  void openDialogBox(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: AzyXContainer(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              height: 125,
              child: Column(
                children: [
                  const AzyXText(
                    "Want to reset all the settings",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.onSurface),
                              elevation: WidgetStateProperty.all(0)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: AzyXText(
                            "Cancel",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontFamily: "Poppins"),
                          )),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                              elevation: WidgetStateProperty.all(0)),
                          onPressed: () {
                            Navigator.pop(context);
                            // Provider.of<ThemeProvider>(context,listen: false).resetSetting();
                          },
                          child: AzyXText(
                            "Reset",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontFamily: "Poppins"),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  ListTile settingTile(
      BuildContext context, String title, String subtitle, Icon icon) {
    return ListTile(
      leading: icon,
      title: AzyXText(
        title,
        style: const TextStyle(fontFamily: "Poppins-Bold"),
      ),
      trailing: const Icon(Broken.arrow_right_3),
      subtitle: AzyXText(
        subtitle,
        style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
      ),
    );
  }
}
