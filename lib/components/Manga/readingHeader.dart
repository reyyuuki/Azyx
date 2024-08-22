import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class Readingheader extends StatelessWidget {

  bool show;
  dynamic data;
   Readingheader({super.key,required this.show, this.data});

  @override
  Widget build(BuildContext context) {
    if(data == null){
      return const SizedBox.shrink();
    }
    return Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: show
              ? AppBar(
                  backgroundColor: const Color.fromARGB(178, 24, 23, 23),
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextScroll(
                        data['title'],
                        mode: TextScrollMode.bouncing,
                        velocity:
                            const Velocity(pixelsPerSecond: Offset(30, 0)),
                        delayBefore: const Duration(milliseconds: 500),
                        pauseBetween: const Duration(milliseconds: 1000),
                        textAlign: TextAlign.center,
                        selectable: true,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        data['currentChapter'],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      )
                    ],
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                )
              : const SizedBox
                  .shrink(), // Replace with SizedBox.shrink() to take up no space when not visible
        );
  }
}