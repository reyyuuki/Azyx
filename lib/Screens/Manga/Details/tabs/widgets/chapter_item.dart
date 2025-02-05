import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';

class ChapterItem extends StatelessWidget {
  final Chapter chapter;
  final UiSettingController setting;
  const ChapterItem({super.key, required this.chapter, required this.setting});

  @override
  Widget build(BuildContext context) {
    return AzyXContainer(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border(
              left: BorderSide(
                  width: 3, color: Theme.of(context).colorScheme.primary)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                blurRadius: 10 * setting.blurMultiplier,
                spreadRadius: 2 * setting.spreadMultiplier)
          ],
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AzyXText(
                  chapter.title!.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: "Poppins-Bold",
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  height: 5,
                ),
                AzyXText(
                  chapter.releaseDate!,
                  style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10)),
              child: AzyXText(chapter.number!.toString(),style: TextStyle(fontFamily: "Poppins-Bold",color: Theme.of(context).colorScheme.inversePrimary),)),
        ],
      ),
    );
  }
}
