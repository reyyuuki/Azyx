import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_button.dart';
import 'package:flutter/material.dart';

class DetailsError extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onSearch;

  const DetailsError({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 18),
              Text(
                "Couldn't load this title",
                style: AzTokens.h2(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage.isNotEmpty
                    ? '$errorMessage. Check your connection or search for another title.'
                    : 'Check your connection or search for another title.',
                style: AzTokens.body(
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AzButton.primary(
                    label: 'Try again',
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
                  const SizedBox(width: 12),
                  AzButton.tonal(
                    label: 'Search',
                    icon: Icons.search_rounded,
                    onPressed: onSearch,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
