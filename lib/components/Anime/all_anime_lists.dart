import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AllAnimeLists extends StatelessWidget {
  final List<dynamic> data;
  const AllAnimeLists({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.9, maxHeight);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: data.isNotEmpty
          ? GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: max(itemCount, minCount),
                  childAspectRatio: gridWidth / gridHeight,
                  crossAxisSpacing: 5),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final tagg = data[index]['media']['id'].toString();
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, "/detailspage", arguments: {
                          "id": tagg,
                          "image": data[index]['media']['coverImage']['large'],
                          "tagg": tagg,
                          "title": data[index]['media']['title']['romaji']
                        });
                      },
                      child: Container(
                        height: Platform.isAndroid || Platform.isIOS ? 150 : 200,
                        width: Platform.isAndroid || Platform.isIOS ? 103 : 140,
                        margin: const EdgeInsets.only(right: 10),
                        child: Hero(
                          tag: tagg,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: data[index]['media']['coverImage']
                                  ['large'],
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(data[index]['media']['title']['romaji'].length > 12
                        ? '${data[index]['media']['title']['romaji'].substring(0, 10)}...'
                        : data[index]['media']['title']['romaji']),
                    const SizedBox(height: 5),
                    Text(
                        '${data[index]['progress'].toString()} | ${data[index]['media']['episodes'].toString()}')
                  ],
                );
              },
            )
          : const Center(
              child: Text(
                'No animes found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
