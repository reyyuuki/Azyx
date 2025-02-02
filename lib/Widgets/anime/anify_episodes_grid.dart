// // ignore_for_file: must_be_immutable

// import 'dart:developer';

// import 'package:azyx/Classes/anify_episodes.dart';
// import 'package:azyx/Classes/episode_class.dart';
// import 'package:azyx/Classes/player_class.dart';
// import 'package:azyx/Controllers/ui_setting_controller.dart';
// import 'package:azyx/Screens/Anime/Watch/watch_screen.dart';
// import 'package:azyx/Widgets/common/shimmer_effect.dart';
// import 'package:azyx/api/Mangayomi/Eval/dart/model/video.dart';
// import 'package:azyx/api/Mangayomi/Model/Source.dart';
// import 'package:azyx/api/Mangayomi/Search/getVideo.dart';
// import 'package:azyx/utils/loaders/bottom_sheet_loader.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AnifyEpisodesGrid extends StatelessWidget {
//   final RxList<AnifyEpisodes> anifyEpisodes;
//   final RxList<Episode> episodesList;
//   final UiSettingController settings;
//   final Source selectedSource;
//   final String title;
//   final int id;
//   AnifyEpisodesGrid(
//       {super.key,
//       required this.title,
//       required this.id,
//       required this.anifyEpisodes,
//       required this.settings,
//       required this.episodesList,
//       required this.selectedSource});

//   final RxList<Video> epiosdeUrls = RxList();
//   final Rx<String> episodeTitle = ''.obs;
//   PlayerData playerData = PlayerData();
//   Future<void> fetchEpisodeLink(
//       String url, int number, String setTitle, context) async {
//     try {
//       final response = await getVideo(source: selectedSource, url: url);
//       if (response.isNotEmpty) {
//         epiosdeUrls.value = response;
//         episodeTitle.value = setTitle;
//         Get.back();
//         displayBottomSheet(context, number);
//       }
//     } catch (e) {
//       log("Error while fetching episode url: $e");
//     }
//   }

//   void fillData(
//       String url,
//       String episodeTitle,
//       String title,
//       int number,
//       int id,
//       List<Video> episodeUrls,
//       List<Episode> episodeList,
//       Source source) {
//     playerData = PlayerData(
//         url: url,
//         episodeTitle: episodeTitle,
//         title: title,
//         number: number,
//         id: id,
//         episodeUrls: episodeUrls,
//         episodeList: episodeList);
//   }

//   void displayBottomSheet(BuildContext context, int number) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       showDragHandle: true,
//       barrierColor: Colors.black87.withOpacity(0.5),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 15),
//         child: SizedBox(
//           height: 320,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const AzyXText(
//                   "Select Server",
//                   style: TextStyle(fontSize: 25, fontFamily: "Poppins-Bold"),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 ...epiosdeUrls.map<Widget>((item) {
//                   return serverAzyXContainer(
//                       context, item.quality, item.url, number);
//                 }),
//                 const SizedBox(
//                   height: 10,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   GestureDetector serverAzyXContainer(
//     BuildContext context,
//     String name,
//     String url,
//     int number,
//   ) {
//     return GestureDetector(
//       onTap: () async {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => WatchScreen(
//                 playerData: PlayerData(
//                     url: url,
//                     episodeTitle: episodeTitle.value,
//                     title: title,
//                     number: number,
//                     id: id,
//                     episodeUrls: epiosdeUrls,
//                     episodeList: episodesList),
//               ),
//             ));
//       },
//       child: AzyXContainer(
//         margin: const EdgeInsets.all(10),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//                 width: 1, color: Theme.of(context).colorScheme.inversePrimary)),
//         child: Center(
//           child: AzyXText(
//             name,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SingleChildScrollView(
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate:
//                 const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//             itemBuilder: (context, i) {
//               final entry = episodesList[i];
//               final index = entry.number! - 1;
//               final title = anifyEpisodes[index].title!;
//               return GestureDetector(
//                 onTap: () {
//                   if (episodeTitle.value == title) {
//                     displayBottomSheet(context, entry.number!);
//                   } else {
//                     showloader(context);
//                     fetchEpisodeLink(entry.url!, entry.number!, title, context);
//                   }
//                 },
//                 child: AzyXContainer(
//                     margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.black.withOpacity(0.5),
//                               blurRadius: 10,
//                               offset: const Offset(0, 2))
//                         ]),
//                     child: Column(
//                       children: [
//                         Stack(
//                           children: [
//                             SizedBox(
//                               height: 150,
//                               width: MediaQuery.of(context).size.width,
//                               child: ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(20)),
//                                 child: CachedNetworkImage(
//                                   imageUrl: anifyEpisodes[index].image!,
//                                   fit: BoxFit.cover,
//                                   filterQuality: FilterQuality.high,
//                                   placeholder: (context, url) => ShimmerEffect(
//                                       height: 150,
//                                       width: MediaQuery.of(context).size.width),
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 child: AzyXContainer(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 5),
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).colorScheme.primary,
//                                     borderRadius: const BorderRadius.only(
//                                         bottomRight: Radius.circular(10),
//                                         topLeft: Radius.circular(10)),
//                                     boxShadow: [
//                                       BoxShadow(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .primary
//                                               .withOpacity(settings.glowMultiplier),
//                                           blurRadius: 10 * settings.blurMultiplier,
//                                           spreadRadius: 2 * settings.spreadMultiplier)
//                                     ],
//                                   ),
//                                   child: AzyXText(
//                                     anifyEpisodes[index].number.toString(),
//                                     style: TextStyle(
//                                         fontFamily: "Poppins-Bold",
//                                         fontSize: 20,
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .inversePrimary),
//                                   ),
//                                 ))
//                           ],
//                         ),
//                         AzyXContainer(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .surfaceAzyXContainerHighest,
//                               borderRadius: const BorderRadius.vertical(
//                                   bottom: Radius.circular(20))),
//                           child: Column(
//                             children: [
//                               AzyXText(
//                                 anifyEpisodes[index].title!,
//                                 style: TextStyle(
//                                     fontFamily: "Poppins-Bold",
//                                     fontSize: 16,
//                                     color: Theme.of(context).colorScheme.primary),
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               AzyXText(
//                                 anifyEpisodes[index].description!,
//                                 style: const TextStyle(
//                                     fontFamily: "Poppins", fontSize: 12),
//                                 maxLines: 3,
//                               )
//                             ],
//                           ),
//                         )
//                       ],
//                     )),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
