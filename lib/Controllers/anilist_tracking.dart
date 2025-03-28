import 'package:azyx/Classes/anime_all_data.dart';
import 'package:azyx/Classes/user_anime.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Functions/string_extensions.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:get/get.dart';

class AnilistTracking extends GetxController {
  final Rx<UserAnime> anime = UserAnime().obs;
  final Rx<UserAnime> manga = UserAnime().obs;

  // void updateAnimeProgress(AnimeAllData data) {
  //   if (anilistAuthController.userAnimeList.isNotEmpty) {
  //     anime.value = anilistAuthController.userAnimeList.firstWhere(
  //       (i) => i.tilte == data.title,
  //       orElse: () => UserAnime(
  //         id: data.id,
  //         progress: data.number?.toInt(),
  //         status: "CURRENT",
  //         score: 5,
  //       ),
  //     );
  //     anilistAuthController.addToAniList(
  //         mediaId: anime.value.id!,
  //         progress: anime.value.progress,
  //         status: anime.value.status);
  //     azyxSnackBar("Anilist Tracking Episode ${anime.value.progress}");
  //   }
  // }
}
