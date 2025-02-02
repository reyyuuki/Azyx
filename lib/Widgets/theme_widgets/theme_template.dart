
import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ThemeTemplate extends StatelessWidget {
  final Color color;
  bool? isBorder = false;
  final String name;
  ThemeTemplate(
      {super.key,
      required this.color,
      required this.isBorder,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AzyXContainer(
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
            child: AzyXContainer(
              height: 130,
              width: 76,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(18)),
              child: Column(
                        children: [
                          const SizedBox(height: 10,),
                          Column(
                            children: [
                              AzyXContainer(
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
                              AzyXContainer(
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
                          AzyXContainer(
                            height: 14,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      )
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AzyXText(name, style: const TextStyle(fontFamily: "Poppins"),),
      ],
    );
  }

  AzyXContainer ball() {
    return AzyXContainer(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
          color: const Color.fromARGB(143, 189, 189, 189),
          borderRadius: BorderRadius.circular(5)),
    );
  }
}