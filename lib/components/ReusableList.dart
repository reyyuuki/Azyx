import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

// ignore: must_be_immutable
class ReusableList extends StatelessWidget {
  dynamic data;
  final String? name;

  ReusableList({super.key, this.data, required this.name});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Icon(
                Ionicons.grid,
                color: Color.fromARGB(255, 253, 89, 144),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                name!,
                style: const TextStyle(fontSize: 25),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                 onTap: () {
                  Navigator.pushNamed(context, '/detailspage',
                      arguments:{"id": data[index]['id'], "image": data[index]['poster']});
                },
                  child: Column(
                    children: [
                      Container(
                        height: 230,
                        width: 150,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                              imageUrl: data[index]['poster'],
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        data?[index]['name'].length > 20
                            ? '${data![index]['name'].toString().substring(0, 17)}...'
                            : data![index]['name'],
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
