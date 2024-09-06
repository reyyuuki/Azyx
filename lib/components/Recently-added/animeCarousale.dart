import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class Animecarousale extends StatelessWidget {
  final List<dynamic>? carosaleData;

  const Animecarousale({super.key,required this.carosaleData});

  @override
  Widget build(BuildContext context) {
    if(carosaleData == null){
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Continue Watching",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
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
                      child: SizedBox(
                        height: 180,
                        width: 130,
                        child: Hero(
                          tag: id,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: poster ?? '',
                              fit: BoxFit.cover,
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
                      'Episode ${currentEpisode ?? 'N/A'}',
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
