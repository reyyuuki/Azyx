import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SearchBox extends StatelessWidget {
  final void Function() ontap;
  final void Function(String value) onChanged;
  final String name;
  final EdgeInsets? margin;
  final TextEditingController? controller;

  const SearchBox({
    super.key,
    required this.ontap,
    required this.name,
    required this.onChanged,
    this.margin,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (v) => ontap(),
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface,
          fontFamily: theme.textTheme.bodyMedium?.fontFamily,
        ),
        decoration: InputDecoration(
          labelText: name,
          labelStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            fontFamily: theme.textTheme.bodyMedium?.fontFamily,
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 13,
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontFamily: theme.textTheme.bodyMedium?.fontFamily,
          ),
          prefixIcon: Icon(
            EvaIcons.search,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary.withOpacity(0.5),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.transparent,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
