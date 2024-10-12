import 'package:flutter/material.dart';

class Mangalist extends StatelessWidget {
  const Mangalist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Text("Welcome master!")
        ],
      ),
    );
  }
}