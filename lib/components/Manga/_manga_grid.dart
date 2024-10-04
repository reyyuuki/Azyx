import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class MangaGrid extends StatelessWidget {
  const MangaGrid({
    super.key,
    required this.data,
  });

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    if(data == null){
      return const SizedBox.shrink();
    }
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GridView.builder( 
        shrinkWrap: true, 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          crossAxisSpacing: 20.0, 
          childAspectRatio:
              0.56, 
        ),
        itemCount: data!.length,
        itemBuilder: (context, index) {
          final item = data![index];
          final tagg = item['id'] + "List";
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/mangaDetail',
            arguments: {"id": item['id'], "image": item['image'], "tagg": tagg}
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: 150,
                  child: Hero(
                    tag: tagg,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: item['image'],
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
                SizedBox(
                  width: 150,
                  child: TextScroll(
                    item['title'],
                    mode: TextScrollMode.bouncing,
                    velocity: const Velocity(pixelsPerSecond: Offset(40, 0)),
                    delayBefore: const Duration(milliseconds: 500),
                    pauseBetween: const Duration(milliseconds: 1000),
                    textAlign: TextAlign.center,
                    selectable: true,
                    style: const TextStyle(fontSize: 16, fontFamily: "Poppins-Bold"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}