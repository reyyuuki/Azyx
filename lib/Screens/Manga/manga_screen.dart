import 'package:azyx/Controllers/services/service_handler.dart';
import 'package:azyx/Controllers/source/source_mapper.dart';
import 'package:azyx/Widgets/Animation/drop_animation.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/common/community_scrollable_list.dart';
import 'package:azyx/Widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class MangaScreen extends StatelessWidget {
  const MangaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AzyXGradientContainer(
      child: BouncePageAnimation(
        child: ListView(
          children: [
            const Header(),
            Obx(() => serviceHandler.mangaWidgets(context).value),
            const CommunityScrollableList(
              title: "Community Recommendations",
              mediaType: MediaType.manga,
              category: "manga",
            ),
          ],
        ),
      ),
    );
  }
}
