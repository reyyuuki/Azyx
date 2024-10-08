import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

// ignore: must_be_immutable
class ReusableList extends StatelessWidget {
  dynamic data;
  final String? name;
  final String? taggName; 

  ReusableList({super.key, this.data, required this.name,required this.taggName});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child:CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
               Icon(
                Ionicons.grid,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                name!,
                style:  const TextStyle(fontSize: 25, fontFamily: "Poppins-Bold"),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
       SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data!.length,
            itemBuilder: (context, index) {
              final tagg = data[index]['id'] + taggName;
              return GestureDetector(
                 onTap: () {
                  Navigator.pushNamed(context, '/detailspage',
                      arguments:{"id": data[index]['id'], "image": data[index]['poster'], "tagg": tagg});
                },
                  child: Column(
                    children: [
                      Container(
                        height: 250,
                        width: 150,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Hero(
                          tag: tagg,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                                imageUrl: data[index]['poster'],
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        Center(
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                        ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        data?[index]['name'].length > 20
                            ? '${data![index]['name'].toString().substring(0, 17)}...'
                            : data![index]['name'], style: const TextStyle(fontFamily: "Poppins-Bold"),
                      )
                    ],
                  ));
            },
          ),
        ),
      ],
    );
  }
}
