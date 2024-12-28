import 'package:azyx/Screens/Manga/mangaDetails.dart';
import 'package:azyx/components/Anime/anime_item.dart';
import 'package:flutter/material.dart';

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
          final tagg = "${item['id']}List";
          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Mangadetails(id: item['id'], image: item['image'], tagg: tagg)));
            },
            child: ItemCard(id: item['id'].toString(), poster: item['poster'], type: item['type'], name: item['name'], rating: item['averageScore'], tagg: tagg,));
        }
      )
    );
  }
}