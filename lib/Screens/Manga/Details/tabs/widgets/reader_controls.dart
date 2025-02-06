import 'dart:developer';

import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/back_button.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReaderControls extends StatelessWidget {
  final String mangaTitle;
  final Rx<String> chapterTitle;
  final Rx<int> totalImages;
  final Rx<bool> isShowed;
  const ReaderControls(
      {super.key,
      required this.chapterTitle,
      required this.mangaTitle,
      required this.isShowed,
      required this.totalImages});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => AnimatedContainer(
              transform: Matrix4.identity()
                ..translate(0.0, isShowed.value ? 0 : -100),
              padding: const EdgeInsets.all(10),
              width: Get.width,
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const CustomBackButton(),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AzyXText(
                                mangaTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: "Poppins-Bold",
                                    fontSize: 18),
                              ),
                              AzyXText(
                                chapterTitle.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontFamily: "Poppins",
                                    color: Colors.grey.shade400),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Broken.setting_2,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary,
                            blurRadius: 10.blurMultiplier(),
                            spreadRadius: 2.spreadMultiplier(),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
          Obx(
            () => AnimatedContainer(
              transform: Matrix4.identity()
                ..translate(0.0, isShowed.value ? 0 : 100),
              curve: Curves.elasticOut,
              padding: const EdgeInsets.all(10),
              width: Get.width,
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CustomBackButton(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AzyXText(
                            mangaTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: "Poppins-Bold",
                                fontSize: 18),
                          ),
                          AzyXText(
                            chapterTitle.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontFamily: "Poppins",
                                color: Colors.grey.shade400),
                          )
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Broken.setting_2,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary,
                            blurRadius: 10.blurMultiplier(),
                            spreadRadius: 2.spreadMultiplier(),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
