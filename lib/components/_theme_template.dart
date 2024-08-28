import 'package:flutter/material.dart';

class ThemeTemplate extends StatelessWidget {

  final Color topLeft;
  final Color topRight;
  final Color bottomLeft;
  final Color bottomRight;
  bool? isBorder = false;
   ThemeTemplate({super.key, required this.topLeft, required this.bottomLeft, required this.bottomRight, required this.topRight, this.isBorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isBorder == true
          ? BoxDecoration(
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(20),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          height: 150,
          width: 86,
          decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 60,
                        width: 43,
                        decoration:  BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)), color: topLeft),
                      ),
                      Container(
                        height: 90,
                        width: 43,
                        decoration:  BoxDecoration(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)), color:bottomLeft),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 60,
                        width: 43,
                        decoration:  BoxDecoration(color:topRight, borderRadius: const BorderRadius.only(topRight: Radius.circular(20) )),
                      ),
                      Container(
                        height: 90,
                        width: 43,
                        decoration:  BoxDecoration(color:bottomRight, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20) )),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                    top: 10,
                    width: 86,
                    child: Column(
                    children: [
                      const SizedBox(height: 5),
                      Column(
                        children: [
                          Container(
                            height: 16,
                            width: 65,
                            decoration: BoxDecoration(color: const Color.fromARGB(143, 189, 189, 189),borderRadius: BorderRadius.circular(5)),
                          ),
                          const SizedBox(height: 5,),
                          Container(
                            height: 10,
                            width: 45,
                            decoration: BoxDecoration(color: const Color.fromARGB(143, 189, 189, 189),borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
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
                        height: 16,
                        width: 70,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,borderRadius: BorderRadius.circular(5)),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Container ball() {
    return Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(color: const Color.fromARGB(143, 189, 189, 189),borderRadius: BorderRadius.circular(5)),
                    );
  }
}