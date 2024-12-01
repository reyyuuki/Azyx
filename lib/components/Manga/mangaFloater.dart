// ignore_for_file: file_names

import 'dart:io';

import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Mangafloater extends StatefulWidget {
  Map<String, dynamic> data;
  String currentLink;
  String currentChapter;
  List<Map<String, dynamic>> chapterList;
  Mangafloater({super.key, required this.data, required this.currentLink, required this.chapterList,required this.currentChapter});

  @override
  State<Mangafloater> createState() => _MangafloaterState();
}

class _MangafloaterState extends State<Mangafloater> {
  bool isFavrouite = false;


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Data>(context, listen: false);
    isFavrouite = provider.getFavroite(widget.data['id']);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
             duration: const Duration(milliseconds: 500),
        width: !isFavrouite ? MediaQuery.of(context).size.width * 0.5 : 100,
        curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                if (!isFavrouite) {
                 provider.addFavrouiteManga(
                          title: widget.data['name'] ?? "Unknown",
                          id: widget.data['id'],
                          image: widget.data['poster'],
                          chapterList: widget.chapterList,
                          currentLink: widget.currentLink,
                          currentChapter: widget.currentChapter,
                          description: widget.data['description'],
                        );
                  setState(() {
                    isFavrouite = true;
                  });
                } else {
                   provider.removefavrouite(widget.data['id']);
                  setState(() {
                    isFavrouite = false;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20))
              ),
                height: 60,
                width:
                    !isFavrouite ? MediaQuery.of(context).size.width * 0.5 : 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFavrouite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    !isFavrouite
                        ? const Text(
                            "Favorite",
                            style: TextStyle(fontFamily: "Poppins-Bold"),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/read', arguments: {
                  'mangaId': widget.data['id'],
                  'image': widget.data['poster'],
                  'chapterLink': widget.currentLink
                });
              },
              child: Container(
                decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20))
              ),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ionicons.book_outline,
                      color:
                          Theme.of(context).colorScheme.primary, // Icon color
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Platform.isAndroid ? 
                      (widget.currentChapter.length > 15 ?  '${widget.currentChapter.substring(0,15)}...' : widget.currentChapter) : widget.currentChapter,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: "Poppins-Bold",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
