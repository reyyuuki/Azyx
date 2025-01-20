// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: width,
                  height: 340,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(100))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              borderRadius: BorderRadius.circular(50)),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset('assets/icon/icon.png')),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "AzyX",
                        style:
                            TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
                      ),
                      Text(
                        "v2.6.2",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _launchURL("https://github.com/reyyuuki");
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 295, left: 40, right: 40),
                  height: 80,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        profile_circle(context),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "ReyYuuki",
                                    style: TextStyle(
                                        fontFamily: "Poppins", fontSize: 18),
                                  ),
                                  Text(
                                    "Main Developer",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              const Icon(Ionicons.logo_android)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 10,
                  left: 0,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 35,
                      icon: const Icon(Icons.arrow_back_ios)))
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                list_tile(
                    width,
                    context,
                    const Icon(Ionicons.logo_github),
                    "Github",
                    "Explore and contribute to the code.",
                    "https://github.com/reyyuuki/Azyx"),
                const SizedBox(
                  height: 10,
                ),
                list_tile(
                    width,
                    context,
                    const Icon(Ionicons.logo_discord),
                    "Discord",
                    "Chat and collaborate with community.",
                    "https://discord.gg/rDwNf4BYfz"),
                const SizedBox(
                  height: 10,
                ),
                list_tile(
                    width,
                    context,
                    const Icon(Icons.telegram),
                    "Telegram",
                    "Stay updated and connect with others.",
                    "https://t.me/Azyxanime"),
                const SizedBox(
                  height: 10,
                ),
                list_tile(
                    width,
                    context,
                    const Icon(Ionicons.logo_reddit),
                    "Reddit",
                    "Discuss features and share feedback.",
                    "https://www.reddit.com/?rdt=44738"),
              ],
            ),
          )
        ],
      ),
    );
  }

  GestureDetector list_tile(double width, BuildContext context, Icon icon,
      String name, String subTitle, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        height: 70,
        width: width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          borderRadius: BorderRadius.circular(50)),
                      child: icon),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontFamily: "Poppins-Bold", fontSize: 20),
                      ),
                      Text(
                        subTitle,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container profile_circle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(50)),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: SizedBox(
          height: 50,
          width: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                  'https://avatars.githubusercontent.com/u/160479695?s=400&u=add067b9d010ce53b58df7d104c1eb606042e3c6&v=4')),
        ),
      ),
    );
  }
}
