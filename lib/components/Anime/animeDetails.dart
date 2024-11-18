// // ignore_for_file: file_names, prefer_const_constructors

// import 'dart:convert';
// import 'dart:developer';
// import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:daizy_tv/Provider/manga_sources.dart';
// import 'package:daizy_tv/Screens/Anime/episode_src.dart';
// import 'package:daizy_tv/auth/auth_provider.dart';
// import 'package:daizy_tv/components/Anime/animeInfo.dart';
// import 'package:daizy_tv/Hive_Data/appDatabase.dart';
// import 'package:daizy_tv/components/Anime/floater.dart';
// import 'package:daizy_tv/utils/api/_anime_api.dart';
// import 'package:daizy_tv/utils/downloader/downloader.dart';
// import 'package:daizy_tv/utils/helper/download.dart';
// import 'package:daizy_tv/utils/scraper/Anime/base_class.dart';
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
