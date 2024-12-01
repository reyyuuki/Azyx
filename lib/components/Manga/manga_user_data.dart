import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MangaLists extends StatelessWidget {
  final List<dynamic> data;
  final String status;
  const MangaLists({super.key, required this.data, required this.status});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final filteredData =
        data.where((manga) => manga['status'] == status).toList();
    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.9, maxHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: filteredData.isNotEmpty
          ? GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: max(itemCount, minCount),
                  childAspectRatio: gridWidth / gridHeight,
                  crossAxisSpacing: 5),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final tagg = filteredData[index]['media']['id'].toString();

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/mangaDetail",
                            arguments: {
                              "id": tagg,
                              "image": filteredData[index]['media']
                                  ['coverImage']['large'],
                              "tagg": tagg
                            });
                      },
                      child: Container(
                        height: Platform.isAndroid ? 150 : 200,
                        width: Platform.isAndroid ? 103 : 140,
                        margin: const EdgeInsets.only(right: 10),
                        child: Hero(
                          tag: tagg,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: filteredData[index]['media']
                                  ['coverImage']['large'],
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
                    Text(filteredData[index]['media']['title']['romaji']
                                .length >
                            12
                        ? '${filteredData[index]['media']['title']['romaji'].substring(0, 10)}...'
                        : filteredData[index]['media']['title']['romaji']),
                    const SizedBox(height: 5),
                    Text(
                        '${filteredData[index]['progress'].toString()} | ${filteredData[index]['media']['chapters'] == null ? 0 : filteredData[index]['media']['chapters'].toString()}')
                  ],
                );
              },
            )
          : Center(
              child: Text(
                'No ${status.toLowerCase()} mangas',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
