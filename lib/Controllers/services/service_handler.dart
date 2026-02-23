import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/mal_service.dart';
import 'package:azyx/Controllers/services/models/base_service.dart';
import 'package:azyx/Controllers/services/models/online_service.dart';
import 'package:azyx/Controllers/services/simkl_service.dart';
import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/anime_class.dart';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/params.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

enum ServicesType { anilist, mal, simkl }

final serviceHandler = Get.find<ServiceHandler>();

class ServiceHandler extends GetxController {
  final serviceType = ServicesType.mal.obs;
  final anilistService = Get.find<AnilistService>();
  final malService = Get.find<MalService>();
  final simklService = Get.find<SimklService>();

  BaseService get service {
    switch (serviceType.value) {
      case ServicesType.anilist:
        return anilistService;
      case ServicesType.mal:
        return malService;
      case ServicesType.simkl:
        return simklService;
    }
  }

  OnlineService get onlineService {
    switch (serviceType.value) {
      case ServicesType.anilist:
        return anilistService;
      case ServicesType.mal:
        return malService;
      case ServicesType.simkl:
        return simklService;
    }
  }

  Rx<User> get userData => onlineService.userData;
  RxList<UserAnime> get userAnimeList => onlineService.userAnimeList;
  RxList<UserAnime> get userMangaList => onlineService.userMangaList;

  Rx<UserAnime> get currentMedia => onlineService.currentMedia;

  RxBool get isLoggedIn => onlineService.isLoggedIn;

  Future<void> login() => onlineService.login();
  Future<void> logout() => onlineService.logout();
  Future<void> autoLogin() => Future.wait([
    malService.autoLogin(),
    anilistService.autoLogin(),
    simklService.autoLogin(),
  ]);
  @override
  Future<void> refresh() => onlineService.refresh();

  Future<void> updateListEntry(
    UserAnime params, {
    required bool isAnime,
    String? syncId,
  }) async => await onlineService.updateEntry(params, isAnime: isAnime);

  Rx<Widget> animeWidgets(BuildContext context) =>
      service.animeWidgets(context);
  Rx<Widget> mangaWidgets(BuildContext context) =>
      service.mangaWidgets(context);
  Rx<Widget> homeWidgets(BuildContext context) => service.homeWidgets(context);

  @override
  void onInit() {
    super.onInit();
    _initServices();
  }

  Future<void> _initServices() async {
    final box = Hive.box('auth');
    serviceType.value =
        ServicesType.values[box.get("serviceType", defaultValue: 0)];
    await fetchHomePage();
    await autoLogin();
  }

  Future<void> fetchHomePage() => service.fetchhomeData();

  Future<AnilistMediaData> fetchAnimeDetails(FetchDetailsParams params) async {
    return service.fetchDetails(params);
  }

  Future<List<Anime>?> search(SearchParams params) async =>
      service.fetchsearchData(params);

  void changeService(ServicesType type) {
    final box = Hive.box('auth');
    box.put("serviceType", type.index);
    serviceType.value = type;
    fetchHomePage();
  }
}
