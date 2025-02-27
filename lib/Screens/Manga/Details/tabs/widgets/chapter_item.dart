import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';

class ChapterItem extends StatelessWidget {
  final Chapter chapter;
  const ChapterItem({super.key, required this.chapter});

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
                blurRadius: 10.blurMultiplier(),
                spreadRadius: 2 .spreadMultiplier())
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
          AzyXContainer(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 10.blurMultiplier(),
                      spreadRadius: 2.spreadMultiplier()
                    )
                  ],
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10)),
              child: AzyXText(chapter.number!.toString(),style: TextStyle(fontFamily: "Poppins-Bold",color: Theme.of(context).colorScheme.inversePrimary),)),
        ],
      ),
    );
  }
}
