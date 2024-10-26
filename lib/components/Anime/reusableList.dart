import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/components/Anime/anime_item.dart';
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
                final tagg = data[index]['id'].toString() + taggName! + index.toString();
                return AnimeItem(id: data[index]['id'].toString(), poster: data[index]['poster'], type: data[index]['type'], name: data[index]['name'], rating: data[index]['rating'], tagg: tagg, status: data[index]['status'],);
              },
            ),
          ),
        ],
      ),
    );
  }
}
