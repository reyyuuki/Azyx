import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class GridList extends StatelessWidget {
  const GridList({
    super.key,
    required this.data,
  });

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(), 
      shrinkWrap: true, 
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 20.0, 
        childAspectRatio:
            0.5, 
      ),
      itemCount: data!.length,
      itemBuilder: (context, index) {
        final item = data![index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/detailspage',
          arguments: {"id": item['id'], "image": item['poster']}
          ),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                width: 230,
                child: Hero(
                  tag: item['id'],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: item['poster'],
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
              const SizedBox(height: 10),
              Expanded(
                child: TextScroll(
                  item['name'],
                  mode: TextScrollMode.bouncing,
                  velocity: const Velocity(pixelsPerSecond: Offset(40, 0)),
                  delayBefore: const Duration(milliseconds: 500),
                  pauseBetween: const Duration(milliseconds: 1000),
                  textAlign: TextAlign.center,
                  selectable: true,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}