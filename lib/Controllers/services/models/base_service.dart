import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/params.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

abstract class BaseService {
  RxList<Widget> homeWidgets(BuildContext context);
  Rx<Widget> animeWidgets(BuildContext context);
  RxList<Widget> mangaWidgets(BuildContext context);
  Future<AnilistMediaData> fetchAnimeDetails(int id);
  Future<AnilistMediaData> fetchMangaDetails(int id);
  Future<void> fetchhomeData();
  Future<List<Anime>> fetchsearchData(SearchParams query);
}
