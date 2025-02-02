import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final IconData icon;
  const CustomAppBar({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Broken.arrow_left_2,
              size: 40,
            )),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AzyXText(
                title,
                style:
                    const TextStyle(fontFamily: "Poppins-Bold", fontSize: 25),
              ),
              Icon(
                icon,
                size: 35,
              )
            ],
          ),
        )
      ],
    );
  }
}
