import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/params.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

abstract class BaseService {
  Rx<Widget> homeWidgets(BuildContext context);
  Rx<Widget> animeWidgets(BuildContext context);
  Rx<Widget> mangaWidgets(BuildContext context);
  Future<AnilistMediaData> fetchDetails(FetchDetailsParams params);
  Future<void> fetchhomeData();
  Future<List<Anime>> fetchsearchData(SearchParams query);
}

class FetchDetailsParams {
  dynamic id;
  bool isManga;

  FetchDetailsParams({required this.id, this.isManga = false});
}
