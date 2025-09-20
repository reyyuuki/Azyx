import 'dart:io';

import 'package:azyx/Widgets/AzyXWidgets/azyx_snack_bar.dart';
import 'package:azyx/utils/extensions.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

class Deeplink {
  static void useDeepLink(Uri uri) {
    if (uri.host != 'add-repo') return;
    ExtensionType type;
    String? animeUrl;
    String? mangaUrl;
    if (Platform.isAndroid) {
      switch (uri.scheme.toLowerCase()) {
        case 'aniyomi':
          type = ExtensionType.aniyomi;
          animeUrl = uri.queryParameters['url']?.trim();
        case 'tachiyomi':
          type = ExtensionType.aniyomi;
          mangaUrl = uri.queryParameters['url']?.trim();
        default:
          type = ExtensionType.mangayomi;
          animeUrl =
              (uri.queryParameters["url"] ?? uri.queryParameters['anime_url'])
                  ?.trim();
          mangaUrl = uri.queryParameters['manga_url']?.trim();
      }
    } else {
      type = ExtensionType.mangayomi;
      animeUrl =
          (uri.queryParameters["url"] ?? uri.queryParameters['anime_url'])
              ?.trim();
      mangaUrl = uri.queryParameters['manga_url']?.trim();
    }

    if (animeUrl != null) Extensions().addRepo(type, animeUrl, ItemType.anime);
    if (mangaUrl != null) Extensions().addRepo(type, mangaUrl, ItemType.manga);

    if (animeUrl != null || mangaUrl != null)
      azyxSnackBar('Repo added succesfully');
    else
      azyxSnackBar('Unsupported link');
  }
}
