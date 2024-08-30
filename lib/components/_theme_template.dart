import 'package:flutter/material.dart';

class ThemeTemplate extends StatelessWidget {
  final Color topLeft;
  final Color topRight;
  final Color bottomLeft;
  final Color bottomRight;
  bool? isBorder = false;
  final String name;
  ThemeTemplate(
      {super.key,
      required this.topLeft,
      required this.bottomLeft,
      required this.bottomRight,
      required this.topRight,
      required this.isBorder,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: isBorder == true
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              height: 130,
              width: 76,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 50,
                            width: 38,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18)),
                                color: topLeft),
                          ),
                          Container(
                            height: 80,
                            width: 38,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18)),
                                color: bottomLeft),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 50,
                            width: 38,
                            decoration: BoxDecoration(
                                color: topRight,
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(18))),
                          ),
                          Container(
                            height: 80,
                            width: 38,
                            decoration: BoxDecoration(
                                color: bottomRight,
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(18))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                      top: 10,
                      width: 76,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 16,
                                width: 65,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        143, 189, 189, 189),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 10,
                                width: 45,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        143, 189, 189, 189),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ball(),
                              ball(),
                              ball(),
                              ball(),
                              ball(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 14,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(name),
      ],
    );
  }

  Container ball() {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
          color: const Color.fromARGB(143, 189, 189, 189),
          borderRadius: BorderRadius.circular(5)),
    );
  }
}
