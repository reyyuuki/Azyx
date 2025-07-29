import 'package:azyx/Widgets/AzyXWidgets/azyx_container.dart';
import 'package:azyx/core/icons/icons_broken.dart';
import 'package:azyx/utils/Functions/multiplier_extension.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final void Function() ontap;
  final void Function(String value) onChanged;
  final String name;
  final EdgeInsets? margin;
  final TextEditingController? controller;
  const SearchBox(
      {super.key,
      required this.ontap,
      required this.name,
      required this.onChanged,
      this.margin,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return AzyXContainer(
      margin: margin,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(1.glowMultiplier()),
            blurRadius: 10.blurMultiplier())
      ]),
      child: TextField(
        controller: controller,
        onChanged: (String value) {
          onChanged(value);
        },
        onSubmitted: (v) {
          ontap();
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
