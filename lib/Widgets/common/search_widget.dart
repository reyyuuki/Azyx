import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final void Function(String value) ontap;
  final String name;
  const SearchBox({super.key, required this.ontap, required this.name});

  @override
  Widget build(BuildContext context) {
    return AzyXContainer(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(1.glowMultiplier()),
            blurRadius: 10.blurMultiplier())
      ]),
      child: TextField(
        onChanged: (String value) {
          ontap(value);
        },
        decoration: InputDecoration(
          labelText: name,
          prefixIcon: const Icon(Broken.search_favorite),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          filled: true,
        ),
      ),
    );
  }
}
