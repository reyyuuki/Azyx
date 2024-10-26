import 'package:flutter/material.dart';

class Languages extends StatelessWidget {
  const Languages ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(child: Text("This page content seeing soon", style: TextStyle(fontSize: 20),)),
    );
  }
}