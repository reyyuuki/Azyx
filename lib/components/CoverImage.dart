import 'dart:ui';

import 'package:flutter/material.dart';

class CoverImage extends StatelessWidget {

  final String? imageUrl;

  const CoverImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
   if(imageUrl == null){
    return const Center(child: CircularProgressIndicator(),);
   }

   return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 