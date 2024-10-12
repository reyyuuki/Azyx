import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class Animecarousale extends StatelessWidget {
  final List<dynamic>? carosaleData;

  const Animecarousale({super.key,required this.carosaleData});

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
            child: InfiniteCarousel.builder(
              itemCount: carosaleData!.length,
              itemExtent: MediaQuery.of(context).size.width / 2.3,
              loop: false,
              center: false,
              itemBuilder: (context, itemIndex,realIndex) {
                final anime = carosaleData![itemIndex];
                final id = anime['animeId'];
                final poster = anime['posterImage'];
                final title = anime['animeTitle'];
                final currentEpisode = anime['currentEpisode'];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/detailspage",
                          arguments: {"id": id, "image": poster}
                          );
                        },
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 150,
                              width: 103,
                              child: Hero(
                                tag: id,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: poster ?? '',
                                    fit: BoxFit.cover,
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
                        'Episode ${currentEpisode ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: "Poppins"
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
