
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/setting_tile.dart';
import 'package:daizy_tv/scraper/Anilist/anilist.dart';
import 'package:daizy_tv/scraper/Anilist/scrapper_home.dart';
import 'package:daizy_tv/scraper/Flames%20Comics/scrap_manwha.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AniListProvider>(context, listen: false);

    String userName = provider.userData['name'] ?? "Guest";
    String image = provider.userData?['avatar']?['large'] ?? "";
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
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Iconsax.user,
                                size: 150,
                              )),
                  ),
                  const SizedBox(
                    height: 5,
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
              provider.userData['name'] != null
                  ? const SettingTile(
                      icon: Icon(Iconsax.user_tag),
                      name: "Profile",
                      routeName: "./profile",
                    )
                  : const SizedBox.shrink(),
              provider.userData['name'] != null
                  ? const SizedBox(
                      height: 10,
                    )
                  : const SizedBox.shrink(),
              const SettingTile(
                icon: Icon(Iconsax.info_circle),
                name: "About",
                routeName: "./about",
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(onPressed: () async{
                await fetchAnilistAnimes();
              }, child: Text("Fetch"))
            ],
          ),
        ));
  }
}

