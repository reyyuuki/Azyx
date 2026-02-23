import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final double? size;
  final VoidCallback? ontap;
  const CustomAppBar(
      {super.key,
      required this.title,
      required this.icon,
      this.size,
      this.ontap});

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
                text: title,
                fontVariant: FontVariant.bold,
                fontSize: size ?? 25,
              ),
              GestureDetector(
                onTap: ontap,
                child: Icon(
                  icon,
                  size: 35,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
