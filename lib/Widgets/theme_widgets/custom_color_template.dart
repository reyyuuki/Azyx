import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomColorTemplate extends StatelessWidget {
  final Color color;
  bool? isBorder = false;
  final String name;
  CustomColorTemplate(
      {super.key,
      required this.color,
      required this.isBorder,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AzyXContainer(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: isBorder == true
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AzyXContainer(
              margin: const EdgeInsets.all(5),
              height: 130,
              width: 76,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      AzyXContainer(
                        height: 16,
                        width: 65,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      AzyXContainer(
                        height: 10,
                        width: 45,
                        decoration: BoxDecoration(
                            color: color,
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
                        color: color, borderRadius: BorderRadius.circular(5)),
                  ),
                ],
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        AzyXText(
          text: name,
          fontVariant: FontVariant.bold,
        ),
      ],
    );
  }

  AzyXContainer ball() {
    return AzyXContainer(
      height: 10,
      width: 10,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
    );
  }
}
