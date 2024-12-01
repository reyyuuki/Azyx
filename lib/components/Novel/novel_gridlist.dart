
import 'dart:math';

import 'package:azyx/components/Novel/novel_item.dart';
import 'package:flutter/material.dart';

class NovelGridlist extends StatelessWidget {
  const NovelGridlist({
    super.key,
    required this.data,
  });
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    if(data == null){
      return const SizedBox.shrink();
    }
    int itemCount = (MediaQuery.of(context).size.width ~/200).toInt();
    int minCount = 3;
    double gridWidth = MediaQuery.of(context).size.width / max(itemCount, minCount); 
    double maxHeight = MediaQuery.of(context).size.height / 2.5;
    double gridHeight = min(gridWidth * 1.9, maxHeight);
    return GridView.builder(  
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: max(itemCount, minCount), 
        crossAxisSpacing: 5.0, 
        childAspectRatio: gridWidth / gridHeight 
      ),
      itemCount: data!.length,
      itemBuilder: (context, index) {
        final item = data![index];
        final tagg = "${item['id']}List";
        return NovelItem(id: item['id'], poster: item['image'], name: item['title'], rating: item['rating'], tagg: tagg);
      },
    );
  }
}