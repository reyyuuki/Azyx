import 'package:azyx/utils/downloader/downloader.dart';
import 'package:azyx/utils/helper/download.dart';
import 'package:flutter/material.dart';

void showDownloadquality(BuildContext context, int number,String episodeLink,String name) async {
    final streamData = await extractStreams(episodeLink);
    String baseUrl = makeBaseUrl(episodeLink);

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: Colors.black87.withOpacity(0.3),
      builder: (context) => StatefulBuilder(
        builder: (_, StateSetter setDownload) {
         
          return SizedBox(
            height: 300,
            child: episodeLink.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Column(
                        children:[ ...streamData
                            .map<Widget>((item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      Downloader().download(
                                          '$baseUrl/${item['url']}',
                                          "Episode-$number",
                                          name);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 45,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item['quality'],
                                            style: const TextStyle(
                                                fontFamily: "Poppins-Bold",
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Icon(Icons.download)
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                        ]
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }