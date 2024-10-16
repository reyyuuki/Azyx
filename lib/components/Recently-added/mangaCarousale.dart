import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class Mangacarousale extends StatelessWidget {
  final List<dynamic>? carosaleData;

  const Mangacarousale({super.key, required this.carosaleData});

  @override
  Widget build(BuildContext context) {
    if(carosaleData == null){
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Currently Watching",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Poppins-Bold",
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.inverseSurface,
                            Theme.of(context).colorScheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                ),
                Icon(Iconsax.arrow_right_4, color: Theme.of(context).colorScheme.primary,)
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: carosaleData == null || carosaleData!.isEmpty
                ? const Center(
                    child: Text(
                      "No manga available",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : InfiniteCarousel.builder(
                    itemCount: carosaleData!.length,
                    itemExtent: MediaQuery.of(context).size.width / 2.9,
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
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: 103,
                                    child: Hero(
                                      tag: id ?? "defaultTag",
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
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
                                  Positioned(
                                top: 0,
                                child: Container(
                                  height: 28,
                                  width: 33,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.8),
                                    borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        topLeft: Radius.circular(10)),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '# ${1 + realIndex}',
                                    style: const TextStyle(
                                        fontFamily: "Poppins-Bold"),
                                  )),
                                ),
                              ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                           Text(
                              title.length > 12 ? '${title.substring(0, 12)}...' : title,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontFamily: "Poppins-Bold"),
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
      ),
    );
  }
}
