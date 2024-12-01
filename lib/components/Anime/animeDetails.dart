// // ignore_for_file: file_names, prefer_const_constructors

// import 'dart:convert';
// import 'dart:developer';
// import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:azyx/Provider/manga_sources.dart';
// import 'package:azyx/Screens/Anime/episode_src.dart';
// import 'package:azyx/auth/auth_provider.dart';
// import 'package:azyx/components/Anime/animeInfo.dart';
// import 'package:azyx/Hive_Data/appDatabase.dart';
// import 'package:azyx/components/Anime/floater.dart';
// import 'package:azyx/utils/api/_anime_api.dart';
// import 'package:azyx/utils/downloader/downloader.dart';
// import 'package:azyx/utils/helper/download.dart';
// import 'package:azyx/utils/scraper/Anime/base_class.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:lite_rolling_switch/lite_rolling_switch.dart';
// import 'package:provider/provider.dart';
// import 'package:text_scroll/text_scroll.dart';
// import 'package:http/http.dart' as http;

// class AnimeDetails extends StatefulWidget {
//   final dynamic animeData;
//   final String id;
//   final String image;

//   const AnimeDetails(
//       {super.key, this.animeData, required this.id, required this.image});

//   @override
//   State<AnimeDetails> createState() => _AnimeDetailsState();
// }

// class _AnimeDetailsState extends State<AnimeDetails> {
  

//   @override
//   void initState() {
//     super.initState();
//     fetchEpisodeList();
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     if (widget.animeData == null) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: 440,
//             ),
//             CircularProgressIndicator(),
//           ],
//         ),
//       );
//     }

    

//     return ;
//   }


 
// }
