import 'dart:io';
import 'dart:ui';

import 'package:azyx/Models/anime_details_data.dart';
import 'package:azyx/Providers/theme_provider.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/common/back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ScrollableAppBar extends StatelessWidget {
  final Rx<AnilistMediaData> mediaData;
  final String image;
  final String tagg;
  const ScrollableAppBar({
    super.key,
    required this.mediaData,
    required this.image,
    required this.tagg,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode!;
    return SliverAppBar(
      leading: const CustomBackButton(),
      expandedHeight: Platform.isAndroid || Platform.isIOS ? 380 : 430,
      flexibleSpace: FlexibleSpaceBar(
          background: Stack(children: [
        Obx(
          () => CachedNetworkImage(
            height: 300,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            imageUrl: mediaData.value.coverImage ?? image,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: AzyXContainer(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        Positioned.fill(
            child: AzyXContainer(
          margin: const EdgeInsets.only(top: 270),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(50))),
        )),
        Positioned(
            top: 115,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    AzyXContainer(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 10)
                      ]),
                      child: Hero(
                        tag: tagg,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            height: 280,
                            width: 200,
                            imageUrl: image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ))
      ])),
    );
  }
}
