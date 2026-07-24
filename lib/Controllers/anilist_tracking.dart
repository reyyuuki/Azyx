import 'package:azyx/Models/user_media.dart';
import 'package:get/get.dart';
class AnilistTracking extends GetxController {
  final Rx<UserMedia> anime = UserMedia().obs;
  final Rx<UserMedia> manga = UserMedia().obs;
}
