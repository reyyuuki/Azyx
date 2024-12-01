import 'dart:io';

import 'package:flutter/material.dart';

class Languages extends StatelessWidget {
  const Languages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Languages",
          style: TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: Platform.isAndroid || Platform.isIOS ? 25 : 35,
            icon: const Icon(Icons.arrow_back_ios)),
        centerTitle: true,
      ),
      body: const Center(
          child: Text(
        "This page content seeing soon",
        style: TextStyle(fontSize: 20),
      )),
    );
  }
}
