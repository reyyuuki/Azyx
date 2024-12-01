import 'package:azyx/Provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ColorBall extends StatelessWidget {

  var color;
  String? name;
  
   ColorBall({super.key,this.color,required this.name});
   

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isBorder = themeProvider.seedColor!.value == color.value ? true : false;
    return Column(
      children: [
        GestureDetector(
          onTap: () { 
            themeProvider.updateSeedColor(color!);
            Hive.box('mybox').put('SeedColor', color);
          },
          child: Container(
            decoration: BoxDecoration(border: Border.all(width: 2, color: isBorder ? color!: Colors.transparent), borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5,),
        Text(isBorder ? name! : "")
      ],
    );
  }
}