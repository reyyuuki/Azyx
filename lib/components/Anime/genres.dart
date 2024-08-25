import 'package:flutter/material.dart';

class Genres extends StatelessWidget {
  final dynamic genres;
  const Genres({super.key, this.genres});

  @override
  Widget build(BuildContext context) {
    if (genres == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0, // Space between items
      runSpacing: 2.0, // Space between lines
      children: genres!.map<Widget>((genre) {
        return Chip(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          label: Text(
            genre,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
