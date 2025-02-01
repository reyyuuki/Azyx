import 'package:azyx/auth/sources_controller.dart';
import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../Preferences/PrefManager.dart';
import 'GetSourceList.dart';

part 'fetch_anime_sources.g.dart';

@riverpod
Future fetchAnimeSourcesList(
  FetchAnimeSourcesListRef ref, {
  int? id,
  required bool reFresh,
}) async {
  if ((PrefManager.getCustomVal('autoUpdate') ?? true) || reFresh) {
    final controller = Get.put(SourcesController());
    await fetchSourcesList(
        sourcesIndexUrl: controller.animeRepo.value,
        refresh: reFresh,
        id: id,
        ref: ref,
        isManga: false);
  }
}
