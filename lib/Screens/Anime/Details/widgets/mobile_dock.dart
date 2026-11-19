import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/az_button.dart';
import 'package:azyx/Screens/Anime/Details/widgets/glass_surface.dart';
import 'package:flutter/material.dart';

class MobileDock extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onWatchTap;
  final VoidCallback onListTap;
  final VoidCallback onFavTap;
  final bool isFavourite;
  final bool isListOn;

  const MobileDock({
    super.key,
    required this.primaryLabel,
    required this.onWatchTap,
    required this.onListTap,
    required this.onFavTap,
    required this.isFavourite,
    this.isListOn = false,
  });

  @override
  Widget build(BuildContext context) {
    final tones = AzTonesProvider.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, bottomInset > 0 ? bottomInset : 12.0),
        child: GlassSurface(
          borderRadius: AzTokens.radiusDock,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: AzButton.primary(
                  width: double.infinity,
                  label: primaryLabel,
                  icon: const Icon(Icons.play_arrow_rounded),
                  onTap: onWatchTap,
                ),
              ),
              const SizedBox(width: 10.0),
              AzButton.square(
                icon: const Icon(Icons.playlist_add_rounded),
                isOn: isListOn,
                onTap: onListTap,
                semanticsLabel: 'Add to list',
              ),
              const SizedBox(width: 10.0),
              AzButton.square(
                icon: Icon(
                  isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavourite ? tones.accent : null,
                ),
                isOn: isFavourite,
                onTap: onFavTap,
                semanticsLabel: 'Favourite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
