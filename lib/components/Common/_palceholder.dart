import 'dart:developer';

import 'package:azyx/Extensions/ExtensionScreen.dart';
import 'package:flutter/material.dart';

class PlaceholderExtensions extends StatelessWidget {
  const PlaceholderExtensions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: "No Source Available",
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'No Source',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            isDense: true,
            items: const [
              DropdownMenuItem<String>(
                value: "No Source Available",
                child: Text("No Source Available"),
              ),
            ],
            onChanged: (String? value) {
              log("No sources available to select.");
            },
          ),
          const SizedBox(
            height: 50,
          ),
          const Text(
            "Oops! u didn't installed any extensions yet",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
          ),
          GestureDetector(
            onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ExtensionScreen()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.extension,color: Theme.of(context).colorScheme.inversePrimary,),
                      const SizedBox(width: 10,),
                      Text("Install Extensions",style: TextStyle(fontFamily: "Poppins-Bold",fontSize: 16,color: Theme.of(context).colorScheme.inversePrimary),)
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}