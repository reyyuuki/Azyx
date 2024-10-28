// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/components/Anime/animeInfo.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/utils/api/_anime_api.dart';
import 'package:daizy_tv/utils/scraper/Anilist/anilist_add.dart';
import 'package:daizy_tv/utils/scraper/other/episodeScrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:http/http.dart' as http;

class AnimeDetails extends StatefulWidget {
  final dynamic animeData;
  final String id;

  const AnimeDetails({super.key, this.animeData, required this.id});

  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
  dynamic filteredEpisodes;
  dynamic consumetEpisodesList;
  dynamic episodeData;
  String? episodeLink;
  int? episodeId;
  String? category;
  String? server;
  dynamic tracks;
  bool dub = false;
  String? title;
  bool isloading = false;
  bool withPhoto = true;
  String selectedValue = "CURRENT";
  double score = 5.0;
  String localSelectedValue = "CURRENT";
  String defaultScore = "1.0";
  final TextEditingController _episodeController =
      TextEditingController(text: '1');

  final String episodeUrl =
      '${dotenv.get("HIANIME_URL")}anime/episode-srcs?id=';

  final List<String> _items = [
    "CURRENT",
    "PLANNING",
    "COMPLETED",
    "REPEATING",
    "PAUSED",
    "DROPPED"
  ];

  final List<String> _scoresItems = [
    "0.5",
    "1.0",
    "1.5",
    "2.0",
    "2.5",
    "3.0",
    "3.5",
    "4.0",
    "4.5",
    "5.5",
    "6.0",
    "6.5",
    "7.0",
    "7.5",
    "8.0",
    "8.5",
    "9.0",
    "10.0"
  ];

  @override
  void initState() {
    super.initState();
    fetchEpisodeList();
  }

  void route() {
    if (episodeLink.toString().isNotEmpty && !isloading) {
      Navigator.pushNamed(
        context,
        '/stream',
        arguments: {
          'episodeSrc': episodeLink,
          'episodeData': filteredEpisodes,
          'currentEpisode': episodeId,
          'episodeTitle': title,
          'subtitleTracks': tracks,
          'animeTitle': widget.animeData['name'],
          'activeServer': server,
          'isDub': dub,
          'animeId': widget.id,
        },
      );
      log(dub.toString());
    }
  }

  Future<void> fetchEpisodeList() async {
    String url =
        "https://raw.githubusercontent.com/RyanYuuki/Anilist-Database/refs/heads/master/anilist/anime/${widget.id}.json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String? zoroUrl;
      final provider = Provider.of<Data>(context, listen: false);

      if (data['Sites']['Zoro'] != null) {
        data['Sites']['Zoro'].forEach((key, value) {
          if (zoroUrl == null && value['url'] != null) {
            zoroUrl = value['url'];
          }
        });
      }

      if (zoroUrl != null) {
        final animeId = zoroUrl?.split('/').last;
        final episodeResponse = await scrapeAnimeEpisodes(animeId!);
        final consumetEpisodes =
            await fetchStreamingDataConsumet(int.parse(widget.id));
  log(widget.animeData.toString());
        if (episodeResponse.isNotEmpty && episodeResponse != null) {
          setState(() {
            episodeData = episodeResponse['episodes'];
            filteredEpisodes = episodeResponse['episodes'];
            consumetEpisodesList = consumetEpisodes;
            episodeId = int.tryParse(provider.getCurrentEpisodeForAnime(
                widget.animeData['id']?.toString() ?? '1')!);
            category = dub ? "dub" : "sub";
          });
        }
      } else {
        log('No Zoro URL found.');
      }
    }
  }

  Future<void> fetchEpisodeUrl() async {
    if (episodeData == null || episodeId == null) return;
    setState(() {
      category = dub ? "dub": "sub";
    });
    try {
      final provider = Provider.of<Data>(context, listen: false);
      final episodeIdValue = episodeData[(episodeId! - 1)]['episodeId'];
          final trackResponse = await fetchStreamingLinksAniwatch(episodeIdValue, server!,"sub");
      log('$episodeUrl$episodeIdValue?server=$server&category=$category');
      final response = await fetchStreamingLinksAniwatch(episodeIdValue, server!, category!);
      log(category!);
      if (response != null) {
        setState(() {
          episodeLink = response['sources'][0]["url"];
          isloading = false;
          tracks = trackResponse['tracks'];
        });
        Navigator.pop(context);
        route();
        provider.addWatchedAnimes(
          animeId: widget.animeData['id'],
          animeTitle: widget.animeData['name'],
          currentEpisode: episodeId!.toString(),
          posterImage: widget.animeData['poster'],
        );
      } else {
        log('Error fetching episode data');
        isloading = true;
      }
    } catch (e) {
      log("Error in fetchEpisode: $e");
      isloading = true;
    }
  }

  void handleEpisode(int? episode, String selectedServer, String getTitle) {
    if (episode != null && selectedServer.isNotEmpty) {
      setState(() {
        episodeId = episode;
        episodeLink = "";
        server = selectedServer;
        title = getTitle;
        isloading = true;
      });
      fetchEpisodeUrl();
    }
  }

  void handleCategory(String newCategory) {
    if (episodeData != null) {
      setState(() {
        category = newCategory;
        episodeLink = "";
      });
      fetchEpisodeUrl();
    }
  }

  void handleEpisodeList(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredEpisodes = episodeData;
      } else {
        filteredEpisodes = episodeData?.where((episode) {
          final episodes = episode['number']?.toString() ?? '';
          return episodes.contains(value);
        }).toList();
      }
    });
  }

  void showDecimalPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a Score"),
          content: SizedBox(
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecimalNumberPicker(
                  value: score,
                  minValue: 0,
                  maxValue: 10,
                  decimalPlaces: 2,
                  onChanged: (value) => setState(() => score = value),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void addToList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 1),
              child: SizedBox(
                height: 640,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(30)),
                              child: CachedNetworkImage(
                                imageUrl: widget.animeData['coverImage'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 25,
                            child: SizedBox(
                              width: 85,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.animeData['poster'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 55,
                            left: 130,
                            child: Text(
                              widget.animeData['name'],
                              style: const TextStyle(
                                fontFamily: "Poppins-Bold",
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 45,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: DropdownButton<String>(
                              value: localSelectedValue,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              icon: const Icon(Iconsax.arrow_bottom),
                              items: _items.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    localSelectedValue = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Score",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 45,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: DropdownButton<String>(
                              value: defaultScore,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              icon: const Icon(Iconsax.arrow_bottom),
                              items: _scoresItems.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    defaultScore = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                          inputbox(context, "Episode progress",
                              _episodeController, filteredEpisodes.length),
                          const SizedBox(height: 30),
                          saveAnime(localSelectedValue, context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  GestureDetector saveAnime(String localSelectedValue, BuildContext context) {
    return GestureDetector(
      onTap: () {
        addToAniList(
          mediaId: int.parse(widget.id),
          status: localSelectedValue,
          score: double.tryParse(defaultScore),
          progress: int.parse(_episodeController.text),
        );
        Navigator.pop(context);
      },
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Save",
            style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animeData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 440,
            ),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);

    return Positioned(
      top: 340,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextScroll(
                widget.animeData['name'],
                mode: TextScrollMode.bouncing,
                velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                delayBefore: const Duration(milliseconds: 500),
                pauseBetween: const Duration(milliseconds: 1000),
                textAlign: TextAlign.center,
                selectable: true,
                style:
                    const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Ionicons.star,
                  color: Colors.yellow,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.animeData['rating'].toString(),
                  style:
                      const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                if (Provider.of<AniListProvider>(context, listen: false)
                        .userData['name'] ==
                    null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Whoa there! 🛑 You’re not logged in! Let’s fix that 😜",
                        style:
                            TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  if (filteredEpisodes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          '🍿 Hold tight! Grabbing those episodes like a ninja... 🥷',
                          style: TextStyle(
                              fontSize: 16, fontFamily: "Poppins-Bold"),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    addToList(context);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 85,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      border: Border(bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.4)
                      )),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHigh),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceBright),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.add),
                          SizedBox(width: 5,),
                          Text(
                            "Add to list",
                            style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SegmentedTabControl(
                      height: 60,
                      barDecoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(10))),
                      selectedTabTextColor:
                          Theme.of(context).colorScheme.inverseSurface,
                      tabTextColor:
                          Theme.of(context).colorScheme.inverseSurface,
                      indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      squeezeIntensity: 2,
                      textStyle: textStyle,
                      selectedTextStyle: selectedTextStyle,
                      indicatorDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                      tabs: [
                        SegmentTab(
                          label: 'Details',
                          color: Theme.of(context).colorScheme.inversePrimary,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                        ),
                        SegmentTab(
                            label: 'Watch',
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  tabs(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox tabs(BuildContext context) {
    return SizedBox(
      height: 620,
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        children: [
          AnimeInfo(animeData: widget.animeData),
          Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Episodes",
                      style:
                          TextStyle(fontFamily: "Poppins-Bold", fontSize: 22),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          withPhoto ? Iconsax.image : Iconsax.menu_board,
                          size: 25,
                        ),
                        onPressed: () {
                          setState(() {
                            withPhoto = !withPhoto;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              LiteRollingSwitch(
                value: true,
                width: 150,
                textOn: 'Sub',
                textOff: 'Dub',
                textOnColor: Colors.white,
                colorOn: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                colorOff: Theme.of(context).colorScheme.onTertiaryFixedVariant,
                iconOn: Icons.closed_caption,
                iconOff: Icons.mic,
                animationDuration: const Duration(milliseconds: 300),
                onChanged: (bool state) {
                  setState(() {
                    dub = !dub;
                  });
                  log(dub.toString());
                },
                onDoubleTap: () => {},
                onSwipe: () => {},
                onTap: () => {},
              ),
              const SizedBox(
                height: 10,
              ),
              !withPhoto
                  ? episodeList(context)
                  : Container(
                      height: 470,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: filteredEpisodes == null
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredEpisodes?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final item = filteredEpisodes![index];
                                  final title = item['title'];
                                  final episodeNumber = item['number'];
                                  final proxy = dotenv.get("PROXY_URL");
                                  final image = proxy +
                                      consumetEpisodesList![index]['image'];
                                  return GestureDetector(
                                    onTap: () {
                                      displayBottomSheet(
                                          context, episodeNumber, title);
                                    },
                                    child: Container(
                                      height: 100,
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: episodeNumber == episodeId
                                            ? Theme.of(context)
                                                .colorScheme
                                                .inversePrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 150,
                                            child: ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .horizontal(
                                                    left: Radius.circular(10)),
                                                child: CachedNetworkImage(
                                                  imageUrl: image.isNotEmpty
                                                      ? image
                                                      : widget
                                                          .animeData['image'],
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              title.length > 25
                                                  ? '${title.substring(0, 25)}...'
                                                  : title,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inverseSurface,
                                                fontFamily: "Poppins-Bold",
                                              ),
                                            ),
                                          ),
                                          episodeNumber == episodeId
                                              ? Icon(
                                                  Ionicons.play,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface,
                                                )
                                              : Text(
                                                  'Ep- $episodeNumber',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inverseSurface,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                          const SizedBox(
                                            width: 5,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Container episodeList(BuildContext context) {
    return Container(
      height: 440,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredEpisodes?.length ?? 0,
          itemBuilder: (context, index) {
            final item = filteredEpisodes![index];
            final title = item['title'];
            final episodeNumber = item['number'];
            return GestureDetector(
              onTap: () {
                displayBottomSheet(context, episodeNumber, title);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: BorderSide(
                      width: 5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  color: episodeNumber == episodeId
                      ? Theme.of(context).colorScheme.inversePrimary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 220,
                        child: Text(
                          title.length > 25
                              ? '${title.substring(0, 25)}...'
                              : title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                      ),
                      episodeNumber == episodeId
                          ? Icon(
                              Ionicons.play,
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                            )
                          : Text(
                              'Ep- $episodeNumber',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Column inputbox(BuildContext context, String name, _controller, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          name,
          style: TextStyle(color: Theme.of(context).colorScheme.surface),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 45,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              if (value.isNotEmpty) {
                int number = int.tryParse(value) ?? 0;
                if (number > max) {
                  _controller.value = TextEditingValue(
                    text: max.toString(),
                  );
                } else if (number < 0) {
                  _controller.value = const TextEditingValue(
                    text: '0',
                  );
                }
              }
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '/ $max',
                  style:
                      const TextStyle(fontFamily: "Poppins-Bold", fontSize: 16),
                ),
              ),
              contentPadding: const EdgeInsets.all(10),
              fillColor: Theme.of(context).colorScheme.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void displayBottomSheet(BuildContext context, int number, String setTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      showDragHandle: true,
      barrierColor: Colors.black87.withOpacity(0.5),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 240,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Select server",
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Poppins-Bold",
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  Ionicons.earth,
                  color: Theme.of(context).colorScheme.onSecondary,
                )
              ]),
              const SizedBox(
                height: 10,
              ),
              serverContainer(
                  context, "HD - 1", number, "vidstreaming", setTitle),
              const SizedBox(height: 10),
              serverContainer(context, "HD - 2", number, "megacloud", setTitle),
              const SizedBox(height: 10),
              serverContainer(
                  context, "Vidstream", number, "streamsb", setTitle),
            ],
          ),
        ),
      ),
    );
  }

  void showCenteredLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  GestureDetector serverContainer(BuildContext context, String name, int number,
      String serverType, String setTitle) {
    return GestureDetector(
      onTap: () async {
        handleEpisode(number, serverType, setTitle);
        Navigator.pop(context);
        showCenteredLoader();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
              width: 1, color: Theme.of(context).colorScheme.inverseSurface),
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
