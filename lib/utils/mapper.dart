import 'dart:convert';
import 'dart:developer';

import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/utils/utils.dart';
import 'package:http/http.dart';

enum MappingType { anilist, mal }

class MediaSyncer {
  static Future<String?> mapMediaId(String id,
      {MappingType? type, bool isManga = false}) async {
    Utils.log('srvice; ${serviceHandler.serviceType.value}');
    final mappingType = type ??
        (serviceHandler.serviceType.value == ServicesType.anilist
            ? MappingType.anilist
            : MappingType.mal);

    if (!isManga) {
      return await getMappedAnimeId(id, mappingType);
    } else {
      return await getMappedMangaId(id, mappingType);
    }
  }

  static Future<String?> getMappedAnimeId(String id, MappingType type) async {
    final url =
        'https://raw.githubusercontent.com/bal-mackup/mal-backup/refs/heads/master/${type.name}/anime/$id.json';
    final resp = await get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (type == MappingType.anilist) {
        return data['malId'].toString();
      } else {
        return data['aniId'].toString();
      }
    } else {
      log("URL => $url");
      log('Error While Mapping Id => ${resp.body}');
    }
    return null;
  }

  static Future<String?> getMappedMangaId(String id, MappingType type) async {
    final resp = await get(Uri.parse(
        'https://raw.githubusercontent.com/bal-mackup/mal-backup/refs/heads/master/${type.name}/manga/$id.json'));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (type == MappingType.anilist) {
        return data['malId'].toString();
      } else {
        return data['aniId'].toString();
      }
    } else {
      log('Error While Mapping Id => ${resp.body}');
    }
    return null;
  }
}
