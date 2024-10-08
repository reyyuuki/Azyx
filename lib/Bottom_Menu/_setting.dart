import 'dart:developer';
import 'dart:io';

import 'package:daizy_tv/_anime_api.dart';
import 'package:daizy_tv/components/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatefulWidget {
  Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var box = Hive.box("mybox");

 Future<void> _launchInWebView() async {
  // Correctly parse the URL using Uri.parse
  Uri url = Uri.parse('https://anilist.co/api/v2/oauth/authorize?client_id=21626&redirect_uri=azyx://callback&response_type=code');
  // Launch the URL in a WebView mode
  if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
    throw Exception('Could not launch $url');
  }
}


 Future<void> loginWithAniList() async {
    final authUrl = Uri.parse(
        'https://anilist.co/api/v2/oauth/authorize?client_id=21626&redirect_uri=azyx://callback&response_type=code');

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl);
      log("done");
    } else {
      throw 'Could not launch $authUrl';
    }
  }

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
              style: TextStyle(fontFamily: "Poppins-Bold")),
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
                        fontFamily: "Poppins-Bold", fontSize: 20),
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
               SettingTile(
                icon: Icon(Iconsax.user_tag),
                name: "Profile",
                routeName: box.get("userName") != null ? "./profile" : "/login-page",
              ),
              const SizedBox(
                height: 10,
              ),
              const SettingTile(
                icon: Icon(Iconsax.info_circle),
                name: "About",
                routeName: "./about",
              ),
              Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          "Anilist - List",
          style: const TextStyle(fontFamily: "Poppins-Bold", ),
        ),
        leading: Icon(Icons.face_retouching_natural),
        trailing: Transform.rotate(
          angle: 3.14,
          child: const Icon(Icons.arrow_back_ios),
        ),
        onTap: () {
          loginWithAniList();
        },
      ),
    )
            ],
          ),
        ));
  }
}
