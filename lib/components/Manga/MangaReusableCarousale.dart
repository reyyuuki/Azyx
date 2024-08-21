import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

// ignore: must_be_immutable
class Mangareusablecarousale extends StatelessWidget {
  final List<dynamic>? data;
  final String? name;

  const Mangareusablecarousale({super.key, this.data, required this.name});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Ionicons.grid,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                name!,
                style: const TextStyle(fontSize: 25),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data!.length,
            itemBuilder: (context, index) {
              // Ensure data[index] has required fields
              final item = data![index];
              final imageUrl = item['image'] ?? '';
              final title = item['title'] ?? '';
              final id = item['id'] ?? '';

              return GestureDetector(
                onTap: () {
                  if (id.isNotEmpty && imageUrl.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/mangaDetail',
                      arguments: {"id": id, "image": imageUrl},
                    );
                  } else {
                    // Optionally show an error or perform an alternative action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: Missing data')),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      height: 230,
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Hero(
                        tag: id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      title.length > 20
                          ? '${title.substring(0, 17)}...'
                          : title,
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
