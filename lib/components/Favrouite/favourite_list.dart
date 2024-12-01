import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimeFavrouiteList extends StatelessWidget {
  dynamic data;
  AnimeFavrouiteList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }
    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.7, maxHeight);
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: max(itemCount, minCount),
                crossAxisSpacing: 5,
                childAspectRatio: gridWidth / gridHeight),
            itemCount: data!.length,
            itemBuilder: (context, index) {
              final tagg = '${data![index]['id']}new';
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/animeFavorite', arguments: {
                    "id": data![index]['id'].toString(),
                    "image": data![index]['image'],
                    "tagg": tagg
                  });
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: Platform.isAndroid || Platform.isIOS ? 150 : 200,
                          width: Platform.isAndroid || Platform.isIOS ? 103 : 140,
                          margin: const EdgeInsets.only(right: 10),
                          child: Hero(
                            tag: tagg,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: data![index]['image'],
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
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data![index]['name'].length > 12
                          ? '${data![index]['name'].substring(0, 10)}...'
                          : data![index]['name'],
                      style: const TextStyle(fontFamily: "Poppins-Bold"),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
