import 'dart:developer';

import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Models/carousale_data.dart';
import 'package:azyx/Models/media.dart';
import 'package:azyx/Models/user_media.dart';

enum CarousaleVarient { userList, regular, other }

List<CarousaleData> getCarousaleData(
  List<dynamic> data,
  CarousaleVarient varient,
) {
  return data.map((e) {
    if (e is AnilistMediaData) {
      return CarousaleData(
        id: e.id ?? '0',
        image: e.image ?? e.coverImage ?? '',
        extraData: e.rating ?? '??',
        title: e.title ?? '??',
        other: e.status ?? '??',
      );
    }

    switch (varient) {
      case CarousaleVarient.userList:
        if (e is! UserMedia)
          return CarousaleData(id: '0', image: '', title: '');
        final d = e;
        return CarousaleData(
          id: d.id!,
          image: d.image!,
          extraData: d.rating ?? '??',
          title: d.title!,
          other: d.progress.toString(),
        );
      case CarousaleVarient.regular:
        if (e is! Media) return CarousaleData(id: '0', image: '', title: '');
        final d = e;
        return CarousaleData(
          id: d.id!,
          image: d.image!,
          extraData: d.rating!,
          title: d.title!,
          other: d.status.toString(),
        );
      case CarousaleVarient.other:
        if (e is! UserMedia)
          return CarousaleData(id: '0', image: '', title: '');
        final d = e;
        return CarousaleData(
          id: d.id!,
          image: d.image!,
          extraData: d.rating!,
          title: d.title!,
          other: d.progress.toString(),
        );
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
