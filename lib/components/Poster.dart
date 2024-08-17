import 'package:flutter/material.dart';

class Poster extends StatelessWidget {

  final String? imageUrl;

  const Poster({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
   if(imageUrl == null){
    return const Center(child: CircularProgressIndicator(),);
   }

   return Positioned(
              top: 70,
              left: 80,
              child: SizedBox(
                height: 280,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
  }
}
 