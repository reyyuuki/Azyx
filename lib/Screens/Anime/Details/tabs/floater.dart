import 'dart:ui';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';

class FloaterWidget extends StatelessWidget {
  final String title;
  final String name;
  final IconData icon;
  final int? index;

  const FloaterWidget(
      {super.key,
      required this.title,
      required this.icon,
      required this.name,
      this.index});

  @override
  Widget build(BuildContext context) {
    // Adding a delay based on index to stagger the animations
    final double positionOffset = (index ?? 0) *
        10.0; // Adjust the multiplier to control the gap between floaters
    final double opacity =
        (index != null) ? (1.0 - index! * 0.1).clamp(0.0, 1.0) : 1.0;

    return AnimatedPositioned(
      bottom: positionOffset,
      left: 0,
      right: 0,
      duration: Duration(milliseconds: 1000 + (index ?? 0) * 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: opacity, // Apply opacity change based on index
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: "Poppins-Bold"),
                          ),
                          AzyXText(
                              text: "Episode 1",
                              fontVariant: FontVariant.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[500]),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(1.glowMultiplier()),
                                blurRadius: 10.blurMultiplier(),
                                spreadRadius: 2.spreadMultiplier())
                          ],
                          color: Theme.of(context).colorScheme.primary),
                      child: Row(
                        children: [
                          Icon(
                            Icons.movie_filter,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Watch",
                            style: TextStyle(
                                fontFamily: "Poppins-Bold",
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
