import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Poster extends StatelessWidget {

  final String? imageUrl;
  final dynamic id;

  const Poster({super.key, this.imageUrl, this.id});

  @override
  Widget build(BuildContext context) {

   return Positioned(
              top: 70,
              left: 80,
              child: SizedBox(
                height: 280,
                width: 200,
                child: Hero(
                  tag: id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                                imageUrl: imageUrl!,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                  ),
                ),
              ),
            );
  }
}
 