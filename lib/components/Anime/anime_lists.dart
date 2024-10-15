import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimeLists extends StatelessWidget {
  final List<dynamic> data; 
  final String status; 
  const AnimeLists({super.key, required this.data, required this.status}); 

  @override
  Widget build(BuildContext context) {

    if(data.isEmpty){
      return const Center(child: CircularProgressIndicator(),);
    }
    final filteredData = data.where((anime) => anime['status'] == status).toList();
    log(filteredData.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: filteredData.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.50,
                crossAxisSpacing: 5
              ),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final tagg = filteredData[index]['media']['id']; 
                return Column(
                  children: [
                    Container(
                      height: 150,
                      width: 103,
                      margin: const EdgeInsets.only(right: 10),
                      child: Hero(
                        tag: tagg,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: filteredData[index]['media']['coverImage']['large'],
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                Center(
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(filteredData[index]['media']['title']['romaji'].length > 12 ? '${filteredData[index]['media']['title']['romaji'].substring(0,10)}...': filteredData[index]['media']['title']['romaji']) ,
                    const SizedBox(height: 5),
                    Text('${filteredData[index]['progress'].toString()} | ${filteredData[index]['media']['episodes'].toString()}' )
                  ],
                );
              },
            )
          : Center( 
              child: Text(
                'No ${status.toLowerCase()} animes', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
