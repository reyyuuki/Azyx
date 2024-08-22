import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// ignore: must_be_immutable
class Progressbar extends StatelessWidget {
  bool show;
  Progressbar({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: show
          ? Container(
              color: const Color.fromARGB(178, 24, 23, 23),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: 3.14, // 180 degrees in radians
                      child: const Icon(Ionicons.play),
                    ),
                    LinearPercentIndicator(
                      lineHeight: 10,
                      width: 280,
                      barRadius: const Radius.circular(10),
                    ),
                    Icon(Ionicons.play),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
