import 'package:azyx/Controllers/anilist_auth.dart';
import 'package:azyx/Controllers/services/episode_metadata_service.dart';
import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/community_charts.dart';
import 'package:azyx/Screens/Anime/Details/widgets/tags_section.dart';
import 'package:azyx/Screens/Manga/Details/manga_details_screen.dart';
import 'package:azyx/Screens/Settings/Pages/episode_metadata_settings.dart';
import 'package:azyx/utils/color_profiler.dart';
import 'package:azyx/utils/shaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testTones = AzTones(
    accent: Color(0xFFFFB1C1),
    onAccent: Color(0xFF3D0B1B),
    soft: Color(0x29FFB1C1),
    glow: Color(0x52FFB1C1),
  );

  Widget wrap(Widget child, {Size size = const Size(1200, 900)}) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: AzTonesProvider(
          tones: testTones,
          child: Scaffold(
            body: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('TagsSection renders tiers, expands tag, mutes and toggles spoilers',
      (tester) async {
    final tags = [
      const AzMediaTag(name: 'Kaiju', rank: 93),
      const AzMediaTag(name: 'Military', rank: 88),
      const AzMediaTag(name: 'Post-Apocalyptic', rank: 84),
      const AzMediaTag(name: 'Secret Identity', rank: 79, isMediaSpoiler: true),
    ];

    String? mutedTag;

    await tester.pumpWidget(
      wrap(
        TagsSection(
          tags: tags,
          onMuteTag: (name) => mutedTag = name,
        ),
      ),
    );

    expect(find.text('What it is tagged as'), findsOneWidget);
    expect(find.text('Kaiju'), findsOneWidget);
    expect(find.text('DEFINING'), findsOneWidget);
    expect(find.text('Military'), findsOneWidget);
    expect(find.text('STRONG'), findsOneWidget);
    expect(find.text('Post-Apocalyptic'), findsOneWidget);
    expect(find.text('Secret Identity'), findsNothing);

    await tester.tap(find.text('Post-Apocalyptic'));
    await tester.pumpAndSettle();

    expect(find.text('84% of voters agree this fits.'), findsOneWidget);
    expect(find.text('Find similar anime'), findsOneWidget);
    expect(find.text('Mute tag'), findsOneWidget);

    await tester.tap(find.text('Mute tag'));
    await tester.pumpAndSettle();

    expect(mutedTag, 'Post-Apocalyptic');
    expect(find.text('Post-Apocalyptic'), findsNothing);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Secret Identity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CommunityCharts renders score curve and donut without overflow on mobile',
      (tester) async {
    final media = AnilistMediaData(
      id: '16498',
      title: 'Attack on Titan',
      scoreDistribution: const [
        AzScoreBucket(score: 80, amount: 10000),
        AzScoreBucket(score: 90, amount: 45000),
        AzScoreBucket(score: 100, amount: 52000),
      ],
      statusDistribution: const [
        AzStatusBucket(status: 'COMPLETED', amount: 906500),
        AzStatusBucket(status: 'PLANNING', amount: 74300),
        AzStatusBucket(status: 'CURRENT', amount: 68400),
      ],
    );

    await tester.pumpWidget(
      wrap(
        CommunityCharts(
          media: media,
          showHeading: false,
          showComments: false,
        ),
        size: const Size(390, 844),
      ),
    );

    expect(find.text('How people scored it'), findsOneWidget);
    expect(find.text('Where it sits in lists'), findsOneWidget);
    expect(find.text('in lists'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('MangaDetailsScreen type is constructible', () {
    const widget = MangaDetailsScreen(tagg: 'test_manga');
    expect(widget.tagg, 'test_manga');
  });

  test('EpisodeMetadataProvider & EpisodeMetadataSettings types resolve', () {
    expect(
      EpisodeMetadataProvider.fromId('kitsu'),
      EpisodeMetadataProvider.kitsu,
    );
    expect(
      EpisodeMetadataProvider.fromId('unknown'),
      EpisodeMetadataProvider.auto,
    );
    const settingsPage = EpisodeMetadataSettings();
    expect(settingsPage, isNotNull);
    final service = AnilistService();
    expect(service.spotlight, isEmpty);
  });

  test('PlayerShaders profiles and ColorProfileBottomSheet resolve', () {
    expect(PlayerShaders.getShaderByName('Anime4K: Mode A (Fast)').length, 3);
    expect(PlayerShaders.getShaderByName('Anime4K: Mode A (HQ)').length, 6);
    final sheet = ColorProfileBottomSheet(
      currentProfile: 'natural',
      onProfileSelected: (_) {},
      onCustomSettingsChanged: (_) {},
      player: null,
    );
    expect(sheet.currentProfile, 'natural');
  });
}
