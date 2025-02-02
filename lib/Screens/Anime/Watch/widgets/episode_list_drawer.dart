
import 'package:azyx/Classes/episode_class.dart';
import 'package:azyx/Classes/player_class.dart';
import 'package:azyx/Controllers/ui_setting_controller.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpisodeListDrawer extends StatelessWidget {
  final Function(Episode) ontap;
  final Rx<bool> showEpisodesBox;
  final RxList<Episode> filteredEpisodes;
  final Rx<PlayerData> animeData;
  final UiSettingController settingController;
  final Rx<String> episodeNumber;
  final Rx<bool> isPotraitOrientaion;

  const EpisodeListDrawer(
      {super.key,
      required this.ontap,
      required this.showEpisodesBox,
      required this.animeData,
      required this.episodeNumber,
      required this.settingController,
      required this.isPotraitOrientaion,
      required this.filteredEpisodes});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedPositioned(
        right: showEpisodesBox.value ? 0 : -Get.width,
        curve: Curves.easeInOutCubicEmphasized,
        top: 0,
        duration: const Duration(milliseconds: 1000),
        child: AzyXContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: isPotraitOrientaion.value ? Get.width : Get.width / 2,
          height: Get.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: Get.isDarkMode
                      ? [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.primary,
                        ]
                      : [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surface
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    IconButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Colors.black.withOpacity(0.4))),
                      onPressed: () {
                        showEpisodesBox.value = false;
                      },
                      icon: const Icon(Icons.close),
                      alignment: Alignment.topLeft,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            filteredEpisodes.value = animeData
                                .value.episodeList!
                                .where(
                                    (i) => i.number!.contains(value))
                                .toList();
                          } else {
                            filteredEpisodes.value =
                                animeData.value.episodeList!;
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          hintText: "Search episodes",
                          labelText: "Search",
                          prefixIcon: const Icon(Broken.search_status_1),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Obx(
                  () => ListView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredEpisodes.length,
                      itemBuilder: (context, index) {
                        final image = filteredEpisodes[index].thumbnail!.isEmpty
                            ? animeData.value.image
                            : filteredEpisodes[index].thumbnail!;
                        return GestureDetector(
                          onTap: () => ontap(filteredEpisodes[index]),
                          child: Stack(
                            children: [
                              AzyXContainer(
                                height: 120,
                                width: 400,
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                  child: AzyXContainer(
                                height: 120,
                                width: 400,
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                              Positioned.fill(
                                child: AzyXContainer(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: filteredEpisodes[index].number ==
                                              episodeNumber.value
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                                left: Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          height: 150,
                                          width: 180,
                                          imageUrl: image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AzyXText(
                                                filteredEpisodes[index].title!,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontFamily: "Poppins-Bold",
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              AzyXText(
                                                filteredEpisodes[index]
                                                        .desc!
                                                        .isEmpty
                                                    ? "Get ready for an exciting episode filled with twists, action, and unforgettable moments!"
                                                    : filteredEpisodes[index]
                                                        .desc!,
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey.shade400
                                                        .withOpacity(0.7),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 3,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 0,
                                  left: 0,
                                  child: AzyXContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(settingController
                                                    .glowMultiplier),
                                            blurRadius: 5 *
                                                settingController
                                                    .blurMultiplier,
                                          )
                                        ],
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: AzyXText(
                                      filteredEpisodes[index].number.toString(),
                                      style: const TextStyle(
                                          fontFamily: "Poppins-Bold",
                                          color: Colors.black,
                                          fontSize: 20),
                                    ),
                                  ))
                            ],
                          ),
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
