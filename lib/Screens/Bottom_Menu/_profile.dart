import 'dart:ui';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Recently-added/animeCarousale.dart';
import 'package:daizy_tv/components/Recently-added/mangaCarousale.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var appData = Hive.box("app-data");
  String imagePath = "";
  String userName = "";
  List<dynamic>? animeWatches;
  List<dynamic>? mangaReads;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    animeWatches = appData.get("currently-Watching");
    mangaReads = appData.get("currently-Reading");
    _nameController.text = userName;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AniListProvider>(context, listen: false);
    List<Map<String, dynamic>> data = [
      {
        'title': 'Anime Count',
        'value': provider.userData['statistics']['anime']['count']
      },
      {
        'title': 'Episodes Watched',
        'value': provider.userData['statistics']['anime']['episodesWatched']
      },
      {
        'title': 'Minutes Watched',
        'value': provider.userData['statistics']['anime']['minutesWatched']
      },
      // {'title': 'Days Watched', 'value': provider.userData['statistics']['anime']['daysWatched']},
      // {'title': 'Anime Mean Score', 'value': provider.userData['statistics']['anime']['episodeWatched']},
      {
        'title': 'Manga Count',
        'value': provider.userData['statistics']['manga']['count']
      },
      {
        'title': 'Chapters Read',
        'value': provider.userData['statistics']['manga']['chaptersRead']
      },
      // {'title': 'Volumes Read', 'value': 0},
      // {'title': 'Manga Mean Score', 'value': 0.0},
    ];
    final animeData = provider.userData['animeList']
        ?.where((anime) => anime['status'] == "CURRENT")
        .toList();

    final mangaData = provider.userData['mangaList']
        ?.where((manga) => manga['status'] == "CURRENT")
        .toList();

    String name = provider.userData['name'] ?? "Guest";
    String image = provider.userData['avatar']['large'] ?? "";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.transparent,
                        ),
                ),
              ),
              
              Positioned(
                bottom: -20,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryFixedVariant,
                                    child: const Icon(
                                      Iconsax.user,
                                      size: 80,
                                    ))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "Poppins-Bold"),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                child: IconButton(
                  alignment: Alignment.topLeft,
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Center(
              child: Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Anime",
                            style: TextStyle(
                              fontFamily: "Poppins-Bold",
                            ),
                          ),
                          Text(
                              provider.userData['statistics']['anime']['count']
                                  .toString(),
                              style:
                                  const TextStyle(fontFamily: "Poppins-Bold")),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Manga",
                              style: TextStyle(
                                fontFamily: "Poppins-Bold",
                              )),
                          Text(
                              provider.userData['statistics']['manga']['count']
                                  .toString(),
                              style: const TextStyle(
                                fontFamily: "Poppins-Bold",
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Stats",
              style: TextStyle(fontSize: 25, fontFamily: "Poppins-Bold"),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map<Widget>((item) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['title'],
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontFamily: "Poppins-Bold")),
                              Text(
                                item['value'].toString().isNotEmpty
                                    ? item['value'].toString()
                                    : "0",
                                style: const TextStyle(
                                    fontFamily: "Poppins-Bold", fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          provider.userData['animeList'] != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Animecarousale(carosaleData: animeData),
                )
              : const SizedBox.shrink(),
          provider.userData['mangaList'] != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Mangacarousale(carosaleData: mangaData),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
