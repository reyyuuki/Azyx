
import 'package:daizy_tv/components/Anime/anime_item.dart';
import 'package:flutter/material.dart';

class GridList extends StatelessWidget {
  const GridList({
    super.key,
    required this.data,
    required this.route
  });
  final route;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    if(data == null){
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: GridView.builder(  
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 5.0, 
            childAspectRatio:
                0.56, 
          ),
          itemCount: data!.length,
          itemBuilder: (context, index) {
            final item = data![index];
            final tagg = "${item['id']}List";
            return ItemCard(id: item['id'].toString(), poster: item['poster'], type: item['type'], name: item['name'], rating: item['averageScore'], tagg: tagg, route: route,);
          },
        ),
      ),
    );
  }
}