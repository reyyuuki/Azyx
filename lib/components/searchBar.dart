import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Searchbar extends StatelessWidget {
  const Searchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10),
               child: Container(
                height: 50,
                color: Colors.transparent,
                 child: Expanded(
                   child: TextField(
                      decoration: InputDecoration(
                         prefixIcon: Icon(Icons.search),
                          hintText: 'Search Anime...',
                          focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          fillColor: Theme.of(context).colorScheme.secondary,
                          filled: true,
                          ),
                    ),
                 ),
               ),
             );
  }
}