import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Screens/Home/UserLists/widgets/grid_list.dart';

final List<double> scoresItems = [
  0.0,
  0.5,
  1.0,
  1.5,
  2.0,
  2.5,
  3.0,
  3.5,
  4.0,
  4.5,
  5.0,
  5.5,
  6.0,
  6.5,
  7.0,
  7.5,
  8.0,
  8.5,
  9.0,
  9.5,
  10.0
];

final List<String> items = [
  "CURRENT",
  "PLANNING",
  "COMPLETED",
  "REPEATING",
  "PAUSED",
  "DROPPED"
];

final List<Map<String, dynamic>> animeCategories = [
  {
    "name": "All",
    "view": UserGridList(
      data: anilistAuthController.userAnimeList,
      isManga: false,
    )
  },
  {
    "name": "Completed",
    "view": UserGridList(
        isManga: false,
        data: anilistAuthController.userSepratedAnimeList.value!.completed)
  },
  {
    "name": "Planning",
    "view": UserGridList(
        isManga: false,
        data: anilistAuthController.userSepratedAnimeList.value!.planning)
  },
  {
    "name": "Watching",
    "view": UserGridList(
        isManga: false,
        data: anilistAuthController
            .userSepratedAnimeList.value!.currentlyWatching)
  },
  {
    "name": "Repeating",
    "view": UserGridList(
        isManga: false,
        data: anilistAuthController.userSepratedAnimeList.value!.repeating)
  },
  {
    "name": "Paused",
    "view": UserGridList(
        isManga: false,
        data: anilistAuthController.userSepratedAnimeList.value!.paused)
  },
];

final List<Map<String, dynamic>> mangaCategories = [
  {
    "name": "All",
    "view": UserGridList(
      data: anilistAuthController.userMangaList,
      isManga: true,
    )
  },
  {
    "name": "Completed",
    "view": UserGridList(
        isManga: true,
        data:
            anilistAuthController.userSepratedMangaList.value?.completed ?? [])
  },
  {
    "name": "Planning",
    "view": UserGridList(
        isManga: true,
        data: anilistAuthController.userSepratedMangaList.value?.planning ?? [])
  },
  {
    "name": "Reading",
    "view": UserGridList(
        isManga: true,
        data: anilistAuthController
                .userSepratedMangaList.value?.currentlyWatching ??
            [])
  },
  {
    "name": "Repeating",
    "view": UserGridList(
        isManga: true,
        data:
            anilistAuthController.userSepratedMangaList.value?.repeating ?? [])
  },
  {
    "name": "Paused",
    "view": UserGridList(
        isManga: true,
        data: anilistAuthController.userSepratedMangaList.value?.paused ?? [])
  },
];
