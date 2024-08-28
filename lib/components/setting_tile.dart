import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final Icon icon;
  final String name;
  final String routeName;

  const SettingTile({super.key, required this.icon, required this.name, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon, // Use the provided icon
                  const SizedBox(width: 10),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), // Use the provided name
                ],
              ),
              Transform.rotate(
                angle: 3.14,
                child: const Icon(Icons.arrow_back_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
