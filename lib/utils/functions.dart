import 'dart:developer';

import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/user_anime.dart';

enum CarousaleVarient { userList, regular, other }

List<CarousaleData> getCarousaleData(
    List<dynamic> data, CarousaleVarient varient) {
  return data.map((e) {
    switch (varient) {
      case CarousaleVarient.userList:
        final d = e as UserAnime;
        return CarousaleData(
            id: d.id!,
            image: d.image!,
            extraData: d.rating!,
            title: d.title!,
            other: d.progress.toString());
      case CarousaleVarient.regular:
        final d = e as Anime;
        return CarousaleData(
            id: d.id!,
            image: d.image!,
            extraData: d.rating!,
            title: d.title!,
            other: d.status.toString());
      case CarousaleVarient.other:
        final d = e as UserAnime;
        return CarousaleData(
            id: d.id!,
            image: d.image!,
            extraData: d.rating!,
            title: d.title!,
            other: d.progress.toString());
    }
  }).toList();
}

extension Utility on String {
  String ellipsis([args]) {
    log(args.toString());
    if (args.length > 2) {
      throw Exception('You can only pass 2 max params');
    }

    if (args.length == 1) {
      return substring(0, args[0]);
    } else {
      return substring(args[0], args[1]);
    }
  }
}
