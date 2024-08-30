import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorBall extends StatelessWidget {

  var color;
  
   ColorBall({super.key,this.color});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isBorder = themeProvider.seedColor == color ? true : false;
    return GestureDetector(
      onTap: () { 
        themeProvider.updateSeedColor(color!);
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
    );
  }
}