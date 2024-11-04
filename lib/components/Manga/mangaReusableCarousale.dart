import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ignore: must_be_immutable
class Mangareusablecarousale extends StatelessWidget {
  final dynamic data;
  final String? name;
  final String? taggName;

  const Mangareusablecarousale(
      {super.key, this.data, required this.name, required this.taggName});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return const SizedBox();
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
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final item = data![index];
                final imageUrl = item['coverImage'] ?? '';
                final title = item['name'] ?? '';
                final id = item['id'] ?? '';
                final tagg = id + taggName;

                return GestureDetector(
                  onTap: () {
                    if (id.isNotEmpty && imageUrl.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        '/mangaDetail',
                        arguments: {"id": id, "image": imageUrl, "tagg": tagg},
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: Missing data')),
                      );
                    }
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
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
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
                                '# ${1 + index}',
                                style:
                                    const TextStyle(fontFamily: "Poppins-Bold"),
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        title.length > 12
                            ? '${title.substring(0, 10)}...'
                            : title,
                        style: const TextStyle(fontFamily: "Poppins-Bold"),
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
