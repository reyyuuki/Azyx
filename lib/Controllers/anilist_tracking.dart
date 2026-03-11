import 'package:azyx/Models/user_media.dart';
import 'package:get/get.dart';

class AnilistTracking extends GetxController {
  final Rx<UserMedia> anime = UserMedia().obs;
  final Rx<UserMedia> manga = UserMedia().obs;

  // void updateAnimeProgress(AnimeAllData data) {
  //   if (anilistAuthController.userAnimeList.isNotEmpty) {
  //     anime.value = anilistAuthController.userAnimeList.firstWhere(
  //       (i) => i.title == data.title,
  //       orElse: () => UserMedia(
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
