// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'dart:io';
import 'package:azyx/Extensions/ExtensionScreen.dart';
import 'package:azyx/Screens/settings/_about.dart';
import 'package:azyx/Screens/settings/_languages.dart';
import 'package:azyx/Screens/settings/_theme_changer.dart';
import 'package:azyx/Screens/settings/download_settings.dart';
import 'package:azyx/api/Mangayomi/Extensions/extensions_provider.dart';
import 'package:azyx/api/Mangayomi/Extensions/fetch_anime_sources.dart';
import 'package:azyx/api/Mangayomi/Model/Source.dart';
import 'package:azyx/components/Common/setting_tile.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/update_notifier.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Setting extends ConsumerStatefulWidget {
  const Setting({super.key});

  @override
  ConsumerState<Setting> createState() => _SettingState();
}

class _SettingState extends ConsumerState<Setting> {
  late List<Source>? extensionsList;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.primary
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10),
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: Platform.isAndroid || Platform.isIOS ? 25 : 35,
                      icon: const Icon(Broken.arrow_left_2)),
                  const Text("Settings",
                      style:
                          TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),textAlign: TextAlign.center,),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const SettingTile(
                icon: Icon(Icons.palette),
                name: "Themes",
                routeName: ThemeChange(),
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Broken.language_circle),
                name: "Languages",
                routeName: Languages(),
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Ionicons.cloud_download_sharp),
                name: "Download settings",
                routeName: DownloadSettings(),
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Iconsax.info_circle),
                name: "About",
                routeName: About(),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    "Check for updates",
                    style: const TextStyle(
                      fontFamily: "Poppins-Bold",
                    ),
                  ),
                  leading: Icon(Icons.update),
                  trailing: Transform.rotate(
                    angle: 3.14,
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                  onTap: () {
                    checkUpdate(context);
                  },
                ),
              ),
              //
            ],
          ),
        ));
  }
}
