// ignore_for_file: inva, invalid_use_of_protected_member
import 'dart:ui';
import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Models/offline_item.dart';
import 'package:azyx/Controllers/anilist_add_to_list_controller.dart';
import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/offline_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class AddToListFloater extends StatelessWidget {
  final int? index;
  final OfflineItem data;
  final AnilistMediaData mediaData;
  const AddToListFloater(
      {super.key, this.index, required this.data, required this.mediaData});

  @override
  Widget build(BuildContext context) {
    final double positionOffset = (index ?? 0) * 10.0;
    final double opacity =
        (index != null) ? (1.0 - index! * 0.1).clamp(0.0, 1.0) : 1.0;

    return AnimatedPositioned(
      bottom: positionOffset,
      left: 0,
      right: 0,
      duration: Duration(milliseconds: 1000 + (index ?? 0) * 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    anilistAuthController.userData.value.name != null
                        ? Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  anilistAddToListController.addToListSheet(
                                      context,
                                      mediaData.image!,
                                      mediaData.title!,
                                      mediaData.episodes ?? 24),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withOpacity(1.glowMultiplier()),
                                          blurRadius: 10.blurMultiplier(),
                                          spreadRadius: 2.spreadMultiplier())
                                    ]),
                                child: Obx(
                                  () => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      anilistAddToListController
                                                  .anime.value.status ==
                                              null
                                          ? Icon(
                                              Broken.add,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              shadows: [
                                                BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    blurRadius:
                                                        10.blurMultiplier(),
                                                    spreadRadius:
                                                        2.spreadMultiplier())
                                              ],
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Obx(
                                        () => Text(
                                          anilistAddToListController
                                                  .animeStatus.value.isEmpty
                                              ? "Add to list"
                                              : anilistAddToListController
                                                  .animeStatus.value,
                                          style: TextStyle(
                                              fontFamily: "Poppins-Bold",
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        addToLibrary(context);
                      },
                      child: anilistAuthController.userData.value.name == null
                          ? libraryButton(context, width: Get.width - 50)
                          : libraryButton(context),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container libraryButton(BuildContext context, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(1.glowMultiplier()),
                blurRadius: 10.blurMultiplier(),
                spreadRadius: 2.spreadMultiplier())
          ]),
      child: Icon(
        IonIcons.albums,
        color: Theme.of(context).colorScheme.primary,
        shadows: [
          BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(1.glowMultiplier()),
              blurRadius: 10.blurMultiplier(),
              spreadRadius: 2.spreadMultiplier())
        ],
      ),
    );
  }

  Row addButtonText(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Broken.add,
          color: Theme.of(context).colorScheme.primary,
          shadows: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 10.blurMultiplier(),
                spreadRadius: 2.spreadMultiplier())
          ],
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          title,
          style: TextStyle(
              fontFamily: "Poppins-Bold",
              color: Theme.of(context).colorScheme.primary),
        )
      ],
    );
  }

  void addToLibrary(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return AzyXGradientContainer(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  AzyXText(
                    text: "Set Categories",
                    textAlign: TextAlign.center,
                    fontVariant: FontVariant.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => offlineController
                          .offlineAnimeCategories.value.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children:
                              offlineController.offlineAnimeCategories.map((i) {
                            final Rx<bool> isSelected =
                                i.anilistIds.contains(data.mediaData.id).obs;
                            return Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerLowest
                                            .withOpacity(1.glowMultiplier()),
                                        blurRadius: 10.blurMultiplier(),
                                        spreadRadius: 2.spreadMultiplier())
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AzyXText(
                                    text: i.name!,
                                    fontVariant: FontVariant.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      isSelected.value = !isSelected.value;
                                      isSelected.value
                                          ? offlineController.addOfflineItem(
                                              data, i.name!)
                                          : offlineController.removeOfflineItem(
                                              data, i.name!);
                                    },
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Obx(
                                        () => CheckMark(
                                          strokeWidth: 2,
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          inactiveColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          active: isSelected.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )),
                  GestureDetector(
                    onTap: () {
                      dialogBox(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLowest
                                      .withOpacity(1.glowMultiplier()),
                                  blurRadius: 10.blurMultiplier(),
                                  spreadRadius: 2.spreadMultiplier())
                            ]),
                        child: addButtonText(context, "Create new category")),
                  ),
                ],
              ));
        });
  }

  void dialogBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController textEditingController = TextEditingController();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    blurRadius: 10.blurMultiplier(),
                    spreadRadius: 2.spreadMultiplier())
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add New Category",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins-Bold",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: textEditingController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Enter something...",
                    hintText: 'Enter something...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        offlineController
                            .createCategory(textEditingController.text);
                        Navigator.of(context).pop(textEditingController.text);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
