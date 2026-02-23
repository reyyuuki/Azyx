import 'package:azyx/Widgets/common/custom_app_bar.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/Widgets/theme_widgets/custom_color.dart';
import 'package:azyx/Widgets/theme_widgets/theme_color.dart';
import 'package:azyx/Widgets/theme_widgets/theme_modes.dart';
import 'package:flutter/material.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({super.key});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AzyXGradientContainer(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: const [
            CustomAppBar(title: "Theme Settings",icon: Broken.brush,),
            Padding(
              padding: EdgeInsets.all(12),
              child: ThemeModes(),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: ThemeColor(),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsets.all(12),
              child: CustomColor(),
            )
          ],
        ),
      ),
    );
  }
}
