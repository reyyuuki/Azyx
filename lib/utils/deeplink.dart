import 'dart:io';

import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart'
    hide isar;
import 'package:azyx/Controllers/source/source_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';

class Deeplink {
  static void useDeepLink(Uri uri) {
    if (uri.host != 'add-repo') return;
    String managerId;
    String? animeUrl;
    String? mangaUrl;
    if (Platform.isAndroid) {
      switch (uri.scheme.toLowerCase()) {
        case 'aniyomi':
          managerId = 'aniyomi';
          animeUrl = uri.queryParameters['url']?.trim();
        case 'tachiyomi':
          managerId = 'aniyomi';
          mangaUrl = uri.queryParameters['url']?.trim();
        default:
          managerId = 'mangayomi';
          animeUrl =
              (uri.queryParameters["url"] ?? uri.queryParameters['anime_url'])
                  ?.trim();
          mangaUrl = uri.queryParameters['manga_url']?.trim();
      }
    } else {
      managerId = 'mangayomi';
      animeUrl =
          (uri.queryParameters["url"] ?? uri.queryParameters['anime_url'])
              ?.trim();
      mangaUrl = uri.queryParameters['manga_url']?.trim();
    }

    if (animeUrl != null)
      sourceController.addRepo(animeUrl, ItemType.anime, managerId);
    if (mangaUrl != null)
      sourceController.addRepo(mangaUrl, ItemType.manga, managerId);

    if (animeUrl != null || mangaUrl != null)
      azyxSnackBar('Repo added succesfully');
    else
      azyxSnackBar('Unsupported link');
  }
}
