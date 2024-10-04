import 'dart:io';

import 'package:daizy_tv/_anime_api.dart';
import 'package:daizy_tv/components/setting_tile.dart';
import 'package:daizy_tv/dataBase/user.dart';
import 'package:daizy_tv/scraper/episodeScrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';

class Setting extends StatefulWidget {
  Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var box = Hive.box("mybox");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userName = box.get("userName") ?? "Guest";
    String image = box.get("imagePath") ?? "";
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text("Settings",
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.file(
                          File(image),
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(
                              Iconsax.user,
                              size: 100,
                            );
                          },
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              const SettingTile(
                icon: Icon(Icons.palette),
                name: "Themes",
                routeName: './theme-changer',
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Icons.language),
                name: "Languages",
                routeName: './languages',
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Iconsax.user_tag),
                name: "Profile",
                routeName: "./profile",
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Iconsax.info_circle),
                name: "About",
                routeName: "./about",
              ),
            ],
          ),
        ));
  }
}
