import 'package:azyx/Controllers/services/episode_metadata_service.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_gradient_container.dart';
import 'package:azyx/Widgets/AzyXWidgets/azyx_text.dart';
import 'package:azyx/Widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';

class EpisodeMetadataSettings extends StatefulWidget {
  const EpisodeMetadataSettings({super.key});

  @override
  State<EpisodeMetadataSettings> createState() =>
      _EpisodeMetadataSettingsState();
}

class _EpisodeMetadataSettingsState extends State<EpisodeMetadataSettings> {
  late bool _enabled;
  late EpisodeMetadataProvider _provider;

  @override
  void initState() {
    super.initState();
    _enabled = EpisodeMetadataService.isEnabled;
    _provider = EpisodeMetadataService.selectedProvider;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: AzyXGradientContainer(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          physics: const BouncingScrollPhysics(),
          children: [
            const CustomAppBar(
              title: 'Episode Metadata',
              icon: Icons.movie_filter_rounded,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: AzyXText(
                text: 'EPISODE METADATA',
                fontSize: 12,
                fontVariant: FontVariant.bold,
                color: colorScheme.primary,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: const AzyXText(
                  text: 'Fetch Episode Metadata',
                  fontSize: 15,
                  fontVariant: FontVariant.bold,
                ),
                subtitle: AzyXText(
                  text: 'Load episode titles, descriptions, and thumbnails',
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                value: _enabled,
                onChanged: (val) {
                  setState(() {
                    _enabled = val;
                    EpisodeMetadataService.isEnabled = val;
                  });
                },
              ),
            ),
            AnimatedOpacity(
              opacity: _enabled ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: AzyXText(
                        text: 'METADATA PROVIDER',
                        fontSize: 12,
                        fontVariant: FontVariant.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.surfaceContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: EpisodeMetadataProvider.values
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final p = entry.value;
                          final isSelected = _provider == p;

                          return Column(
                            children: [
                              if (index > 0)
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.18),
                                ),
                              RadioListTile<EpisodeMetadataProvider>(
                                value: p,
                                groupValue: _provider,
                                activeColor: colorScheme.primary,
                                title: AzyXText(
                                  text: p.label,
                                  fontSize: 14.5,
                                  fontVariant: isSelected
                                      ? FontVariant.bold
                                      : FontVariant.regular,
                                ),
                                subtitle: AzyXText(
                                  text: p.description,
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onChanged: (val) {
                                  if (val == null) return;
                                  setState(() {
                                    _provider = val;
                                    EpisodeMetadataService.selectedProvider =
                                        val;
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
