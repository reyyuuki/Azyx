import 'package:daizy_tv/components/_theme_template.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeChange extends StatefulWidget {
  const ThemeChange({super.key});

  @override
  State<ThemeChange> createState() => __ThemeChangeState();
}

class __ThemeChangeState extends State<ThemeChange> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("App Themes", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Theme"),
            const SizedBox(height: 10,),
            Container(
              height: 300,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Theme.of(context).colorScheme.surfaceContainerHighest,),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Mode", style: TextStyle(fontSize: 20),),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ThemeTemplate(topLeft: Colors.white, topRight: Colors.white, bottomLeft: Colors.white, bottomRight: Colors.white,),
                      ThemeTemplate(topLeft: Color.fromARGB(193, 0, 0, 0), topRight: Color.fromARGB(193, 0, 0, 0), bottomLeft: Colors.black, bottomRight: Colors.black,),
                      ThemeTemplate(topLeft: Colors.white, topRight: Color.fromARGB(193, 0, 0, 0), bottomLeft: Colors.white, bottomRight: Colors.black,),
                    ],
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}