import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -230,
            right: -10,
            width: MediaQuery.of(context).size.width,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                borderRadius:BorderRadius.circular(200),
                color: Colors.green[200],
              ),
            )
            ),
            Positioned(
            top: -130,
            left: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius:BorderRadius.circular(200),
                color: Colors.green,
              ),
            )
            ),
          Center(
            child: ElevatedButton(
              onPressed:() { Navigator.pushNamed(context, "/choose-mode");},
             child: const Text("welcome")),
          ),
        ],
      ),
    );
  }
}