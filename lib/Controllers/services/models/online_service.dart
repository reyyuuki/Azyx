import 'package:azyx/Models/anilist_user_data.dart';
import 'package:azyx/Models/user_anime.dart';
import 'package:azyx/Models/user_lists_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

abstract class OnlineService {
  Rx<UserListsModel> get userAnimeList;
  Rx<UserListsModel> get userMangaList;
  Rx<User> get userData;
  Future<void> autoLogin();
  Future<void> login();
  Future<void> logout();
  Future<void> refresh();
  Future<void> updateEntry(UserAnime entry, {required bool isAnime});
  Future<void> deleteEntry(String entry, {required bool isAnime});
}
