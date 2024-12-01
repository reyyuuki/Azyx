import 'dart:math';

import 'package:azyx/components/Anime/anime_item.dart';
import 'package:flutter/material.dart';

class GridList extends StatelessWidget {
  final String route;
  final dynamic data;
  const GridList({super.key, required this.data, required this.route});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }

    int itemCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
    int minCount = 3;
    double gridWidth =
        MediaQuery.of(context).size.width / max(itemCount, minCount);
    double maxHeight = MediaQuery.of(context).size.height /
        2.5; 
    double gridHeight = min(gridWidth * 1.9, maxHeight);
    return Container(
      padding: const EdgeInsets.only(left: 12),
      color: Theme.of(context).colorScheme.surface,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max(itemCount, minCount),
          crossAxisSpacing: 5.0,
          childAspectRatio: gridWidth / gridHeight,
        ),
        itemCount: data!.length,
        itemBuilder: (context, index) {
          final item = data![index];
          final tagg = "${item['id']}List";
          return ItemCard(
            id: item['id'].toString(),
            poster: item['poster'],
            type: item['type'],
            name: item['name'],
            rating: item['averageScore'],
            tagg: tagg,
            route: route,
          );
        },
      ),
    );
  }
}
