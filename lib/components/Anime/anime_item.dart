// anime_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AnimeItem extends StatelessWidget {
  final String id;
  final String poster;
  final String type;
  final String name;
  final int? rating;
  final String tagg;
  final String? status;

  const AnimeItem(
      {super.key,
      required this.id,
      required this.poster,
      required this.type,
      required this.name,
      required this.rating,
      required this.tagg,
      this.status});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detailspage',
            arguments: {"id": id, "image": poster, "tagg": tagg});
      },
      child: Column(
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
                      imageUrl: poster,
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
                top: 0,
                left: 0,
                child: Container(
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 231, 179, 254),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topLeft: Radius.circular(15)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        type,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 75, 24, 101),
                            fontFamily: "Poppins-Bold"),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 22,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 231, 179, 254),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topLeft: Radius.circular(25)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          rating != null ? (rating! / 10).toString() : "N/A",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 75, 24, 101),
                              fontFamily: "Poppins-Bold"),
                        ),
                        const Icon(
                          Iconsax.star1,
                          size: 16,
                          color: Color.fromARGB(255, 75, 24, 101),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              status == "RELEASING"
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 95, 209, 99),
                            border: Border.all(
                                width: 2,
                                color: const Color.fromARGB(255, 8, 117, 11)),
                            borderRadius: BorderRadius.circular(20)),
                      ))
                  : const SizedBox.shrink()
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name.length > 12 ? '${name.substring(0, 10)}...' : name,
            style: const TextStyle(fontFamily: "Poppins-Bold"),
          ),
        ],
      ),
    );
  }
}
