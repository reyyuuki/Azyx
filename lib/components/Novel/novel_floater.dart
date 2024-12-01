
import 'dart:io';

import 'package:azyx/Hive_Data/appDatabase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class NovelFloater extends StatefulWidget {
  Map<String, dynamic> data;
  String currentLink;
  String currentChapterTitle;
  String image;
  NovelFloater({super.key, required this.data, required this.currentLink, required this.currentChapterTitle, required this.image});

  @override
  State<NovelFloater> createState() => _NovelFloaterState();
}

class _NovelFloaterState extends State<NovelFloater> {
  bool isFavrouite = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Data>(context, listen: false);
    isFavrouite = provider.getFavroiteNovel(widget.data['id']);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500 ),
            curve: Curves.easeInOut, 
            width: isFavrouite ? 100 : MediaQuery.of(context).size.width * 0.5,
            child: GestureDetector(
              onTap: () {
                if (!isFavrouite) {
                  provider.addFavrouiteNovel(
                    title: widget.data['title'],
                    id: widget.data['id'],
                    image: widget.image,
                    description: widget.data['description'],
                    chapterList: widget.data['chapterList'],
                    currentChapter: widget.currentChapterTitle,
                    currentLink: widget.currentLink
                  );
                  setState(() {
                    isFavrouite = true;
                  });
                } else {
                  provider.removefavrouiteNovel(widget.data['id']);
                  setState(() {
                    isFavrouite = false;
                  });
                }
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20))
                ),
                width: !isFavrouite ? MediaQuery.of(context).size.width * 0.5 : 100,
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
                    !isFavrouite ? 
                    const Text(
                      "Favorite",
                      style: TextStyle(fontFamily: "Poppins-Bold"),
                    ) : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/novelRead', arguments: {
                  'novelId': widget.data['id'],
                  'image': widget.data['image'],
                  'chapterLink': widget.currentLink,
                  'title': widget.data['title']
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
                      Icons.book_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // Icon color
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Platform.isAndroid ?
                      (widget.currentChapterTitle.length > 15 ? "${widget.currentChapterTitle.substring(0,15)}..." : widget.currentChapterTitle) : (widget.currentChapterTitle.length > 40 ? "${widget.currentChapterTitle.substring(0,40)}..." : widget.currentChapterTitle),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: "Poppins-Bold" // Text color
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
