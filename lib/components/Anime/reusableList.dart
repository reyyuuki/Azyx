import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ignore: must_be_immutable
class ReusableList extends StatelessWidget {
  dynamic data;
  final String? name;
  final String? taggName;

  ReusableList(
      {super.key, this.data, required this.name, required this.taggName});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name!,
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
              Icon(
                Iconsax.arrow_right_4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final tagg = data[index]['id'] + taggName + index.toString();
                return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/detailspage', arguments: {
                        "id": data[index]['id'],
                        "image": data[index]['poster'],
                        "tagg": tagg
                      });
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
                                    imageUrl: data[index]['poster'],
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
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 22,
                                  width: 50,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 231, 179, 254),
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          topLeft: Radius.circular(25))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          data[index]['rating'] != null
                                              ? (double.tryParse(data[index]
                                                              ['rating']
                                                          .toString())! /
                                                      10)
                                                  .toStringAsFixed(1)
                                              : "N/A",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 75, 24, 101),
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
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          data?[index]['name'].length > 12
                              ? '${data![index]['name'].toString().substring(0, 10)}...'
                              : data![index]['name'],
                          style: const TextStyle(fontFamily: "Poppins-Bold"),
                        )
                      ],
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
