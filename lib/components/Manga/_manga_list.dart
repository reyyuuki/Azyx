// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MangaSearchList extends StatelessWidget {
  dynamic data;
  MangaSearchList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final title = item['name'];
          final image = item['poster'];
          final id = item['id'].toString();
          final tagg = "${id}List";
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/mangaDetail",
                  arguments: {"id": id, "image": image, "tagg": tagg});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Theme.of(context).colorScheme.primary
                            ],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter)),
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: CachedNetworkImage(
                          imageUrl: item['cover'] ?? image,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Theme.of(context).colorScheme.surface,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  Positioned(
                      top: 0,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 150,
                                  width: 103,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Hero(
                                    tag: tagg,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: image,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                Center(
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                item['type'].isNotEmpty
                                    ? Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius: const BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(15),
                                                topLeft: Radius.circular(15)),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Text(
                                                item['type'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryFixedVariant,
                                                    fontFamily: "Poppins-Bold"),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                item['averageScore'] != null
                                    ? Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          height: 22,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius: const BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(10),
                                                topLeft: Radius.circular(25)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  item['averageScore'] != null
                                                      ? (item['averageScore']! /
                                                              10)
                                                          .toString()
                                                      : "N/A",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryFixedVariant,
                                                      fontFamily:
                                                          "Poppins-Bold"),
                                                ),
                                                Icon(
                                                  Iconsax.star1,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryFixedVariant,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                item['status'] != null &&
                                        (item['status'] == "RELEASING" ||
                                            item['status'] == "Ongoing")
                                    ? Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 95, 209, 99),
                                              border: Border.all(
                                                  width: 2,
                                                  color: const Color.fromARGB(
                                                      255, 8, 117, 11)),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ))
                                    : const SizedBox.shrink()
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title.length > 50
                                          ? title.substring(0, 47) + "..."
                                          : title,
                                      style: const TextStyle(
                                          fontFamily: "Poppins-Bold", fontSize: 16),
                                    ),
                                    Text('${item['chapters']} | ${item['volumes']}' )
                                  ],
                                )),
                          ],
                        ),
                      ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
