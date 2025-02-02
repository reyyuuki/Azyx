import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AzyXContainer(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.6),
            blurRadius: 10
          )
        ]
      ),
      child: TextField(
                decoration: InputDecoration(
                  labelText: "Search Anime",
                  prefixIcon: const Icon(Broken.search_favorite),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  filled: true,
                ),
              ),
    );
  }
}