import 'dart:io';

import 'package:azyx/Classes/anime_details_data.dart';
import 'package:azyx/Widgets/Animation/scale_animation.dart';
import 'package:azyx/Widgets/anime/character_card.dart';
import 'package:azyx/Widgets/common/gradient_title.dart';
import 'package:flutter/material.dart';

class CharactersList extends StatelessWidget {
  final List<Character> characterList;
  final String title;
  const CharactersList(
      {super.key, required this.characterList, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientTitle(title: title),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: Platform.isAndroid || Platform.isIOS ? 200 : 270,
          child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: characterList.length,
              itemBuilder: (context, index) {
                return SlideAndScaleAnimation(
                  child: CharacterCard(
                    item: characterList[index],
                  ),
                );
              }),
        )
      ],
    );
  }
}
