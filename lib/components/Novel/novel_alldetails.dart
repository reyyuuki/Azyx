import 'dart:io';

import 'package:daizy_tv/components/Novel/naovel_info.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:text_scroll/text_scroll.dart';

class NovelAlldetails extends StatelessWidget {
  final dynamic novelData;
  const NovelAlldetails({super.key, this.novelData});

  @override
  Widget build(BuildContext context) {
    if (novelData == null) {
      return const Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 300,
          )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextScroll(
              novelData == null ? "Loading" : novelData['title'],
              mode: TextScrollMode.bouncing,
              velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
              delayBefore: const Duration(milliseconds: 500),
              pauseBetween: const Duration(milliseconds: 1000),
              textAlign: TextAlign.center,
              selectable: true,
              style: const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold"),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Ionicons.star,
                size: 20,
                color: Colors.yellow,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                novelData['rating'],
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          NovelInfo(
            novelData: novelData,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            Platform.isAndroid ?
            (novelData['description'].length > 380
                ? '${novelData['description'].substring(0, 380)}...'
                : novelData['description']) : novelData['description'],
            style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(232, 165, 159, 159)),
          ),
        ],
      ),
    );
  }
}
