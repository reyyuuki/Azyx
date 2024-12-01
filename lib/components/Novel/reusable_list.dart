
import 'dart:io';

import 'package:daizy_tv/components/Novel/novel_item.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ignore: must_be_immutable
class NovelList extends StatelessWidget {
  dynamic data;
  final String? name;
  final String? taggName;
  final String route;

  NovelList(
      {super.key, this.data, required this.name, required this.taggName,required this.route});

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
                  fontSize: Platform.isAndroid ? 18 : 25,
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
                size: Platform.isAndroid ? 25 : 35,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: Platform.isAndroid ? 190 : 300,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final tagg = data[index]['id'] + taggName! + index.toString();
                return NovelItem(id: data[index]['id'], poster: data[index]['image'] ?? '', name: data[index]['title'], rating: data[index]['rating'].toString(), tagg: tagg,);
              },
            ),
          ),
        ],
      ),
    );
  }
}
