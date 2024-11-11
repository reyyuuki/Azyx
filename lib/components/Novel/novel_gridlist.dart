
import 'package:daizy_tv/components/Novel/novel_item.dart';
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
            return NovelItem(id: item['id'], poster: item['image'], name: item['title'], rating: item['rating'], tagg: tagg);
          },
        ),
      ),
    );
  }
}