import 'package:cached_network_image/cached_network_image.dart';
import 'package:daizy_tv/components/Anime/anime_item.dart';
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
    if(data == null){
      return const SizedBox.shrink();
    }
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GridView.builder( 
        shrinkWrap: true, 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 20.0, 
          childAspectRatio:
              0.56, 
        ),
        itemCount: data!.length,
        itemBuilder: (context, index) {
          final item = data![index];
          final tagg = "${item['id']}List";
          return AnimeItem(id: item['id'].toString(), poster: item['poster'], type: item['type'], name: item['name'], rating: item['rating'], tagg: tagg);
        },
      ),
    );
  }
}