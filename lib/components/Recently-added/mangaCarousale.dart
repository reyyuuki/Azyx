import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class Mangacarousale extends StatelessWidget {
  final List<dynamic>? carosaleData;

  const Mangacarousale({super.key, required this.carosaleData});

  @override
  Widget build(BuildContext context) {
    if(carosaleData == null){
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Continue Reading",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: carosaleData == null || carosaleData!.isEmpty
              ? const Center(
                  child: Text(
                    "No manga available",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : InfiniteCarousel.builder(
                  itemCount: carosaleData!.length,
                  itemExtent: MediaQuery.of(context).size.width / 2.3,
                  loop: false,
                  center: false,
                  anchor: 0,
            velocityFactor: 0.7,
            axisDirection: Axis.horizontal,
                  itemBuilder: (context, itemIndex, realIndex) {
                    final manga = carosaleData![itemIndex];
                    final id = manga['mangaId'];
                    final poster = manga['mangaImage'];
                    final title = manga['mangaTitle'];
                    final currentEpisode = manga['currentChapter'];
                    const String proxyUrl =
                  'https://goodproxy.goodproxy.workers.dev/fetch?url=';
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/mangaDetail",
                                arguments: {"id": id, "image": proxyUrl + poster},
                              );
                            },
                            child: SizedBox(
                              height: 180,
                              width: 130,
                              child: Hero(
                                tag: id ?? "defaultTag",
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    imageUrl: poster ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title ?? 'Unknown Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentEpisode ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
