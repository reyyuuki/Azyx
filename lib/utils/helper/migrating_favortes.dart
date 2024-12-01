
// import 'dart:developer';

// import 'package:azyx/Hive_Data/appDatabase.dart';
// import 'package:azyx/auth/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:provider/provider.dart';

// void migratefavoritesdata(BuildContext context){
//   final dataProvider = Provider.of<Data>(context, listen: false);
//   final anilistProvider = Provider.of<AniListProvider>(context, listen: false);
//   final bool isLoogedIn = anilistProvider.userData['name'] != null;
//   dataProvider.favoriteManga = isLoogedIn ? anilistProvider.favorites['manga'] : dataProvider.favoriteManga;
//   var box = Hive.box("app-data");
//   box.put("favoriteManga", dataProvider.favoriteManga);
//   log(dataProvider.favoriteManga.toString());
//   anilistProvider.fetchAniListFavorites();
// }

// void addFavrouite({
//    required String title,
//    required String id,
//    required String image,
//    context,
//    type
// }) {
//   final dataProvider = Provider.of<Data>(context, listen: false);
//   final anilistProvider = Provider.of<AniListProvider>(context, listen: false);
//   final bool isLoogedIn = anilistProvider.userData['name'] != null;

//   dataProvider.favoriteManga ??= [];
//   final manga = {
//     'title': title,
//     'id': id,
//     'image': image,
//   };

//   if (isLoogedIn) {
//     if (!anilistProvider.favorites[type].any((item) => item['id'] == manga['id'].toString())) {
//       anilistProvider.favorites[type].add(manga);
//       log('${anilistProvider.favorites} item added to favorites.');
//     }
//   }

//   dataProvider.favoriteManga!.removeWhere((manga) => manga['id'].toString() == id);
//   dataProvider.favoriteManga!.add(manga);

//   var box = Hive.box("app-data");
//   box.put("favoriteManga", dataProvider.favoriteManga);
//   log('updated new favorite: ${dataProvider.favoriteManga}');
//   anilistProvider.fetchAniListFavorites();
// }

// void removefavrouite(String id, context, type) {
//   final dataProvider = Provider.of<Data>(context, listen: false);
//   final anilistProvider = Provider.of<AniListProvider>(context, listen: false);

//   if (anilistProvider.userData['name'] != null) {
//     anilistProvider.favorites[type].removeWhere((item) => item['id'].toString() == id);
//     dataProvider.favoriteManga!.removeWhere((manga) => manga['id'].toString() == id);
    
//     var box = Hive.box("app-data");
//     box.put("favoriteManga", dataProvider.favoriteManga);
//     log("After Remove: ${anilistProvider.favorites}");
//   }
//   anilistProvider.fetchAniListFavorites();
// }

//  bool getFavroite(String id, context) {
//   final dataProvider = Provider.of<Data>(context, listen: false);
//     log(dataProvider.favoriteManga!.any((manga) => manga['id'].toString() == id).toString());
//     return dataProvider.favoriteManga!.any((manga) => manga['id'].toString() == id);
//   }