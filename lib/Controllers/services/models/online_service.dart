import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/user_media.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

abstract class OnlineService {
  RxList<UserMedia> get userAnimeList;
  RxList<UserMedia> get userMangaList;
  Rx<UserMedia> get currentMedia;
  RxBool get isLoggedIn;
  Rx<User> get userData;
  Future<void> autoLogin();
  Future<void> login();
  Future<void> logout();
  Future<void> refresh();
  Future<void> updateEntry(UserMedia entry, {required bool isAnime});
  Future<void> deleteEntry(String entry, {required bool isAnime});
}
