import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final Icon icon;
  final String name;
  final Widget routeName;

   const SettingTile(
      {super.key,
      required this.icon,
      required this.name,
      required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontFamily: "Poppins-Bold", ),
        ),
        leading: icon,
        trailing: Transform.rotate(
          angle: 3.14,
          child: const Icon(Icons.arrow_back_ios),
        ),
        onTap: () {
          Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => routeName,
                    ));
        },
      ),
    );
  }
}
