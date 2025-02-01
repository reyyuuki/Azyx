import 'package:azyx/auth/auth_provider.dart';
import 'package:azyx/auth/sources_controller.dart';
import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../Preferences/PrefManager.dart';
import 'GetSourceList.dart';

part 'fetch_manga_sources.g.dart';

@riverpod
Future fetchMangaSourcesList(FetchMangaSourcesListRef ref,
    {int? id, required reFresh}) async {
  if ((PrefManager.getCustomVal('something') ?? true) || reFresh) {
    final controller = Get.put(SourcesController());
    await fetchSourcesList(
        sourcesIndexUrl: controller.mangaRepo.value,
        refresh: reFresh,
        id: id,
        ref: ref,
        isManga: true);
  }
}
