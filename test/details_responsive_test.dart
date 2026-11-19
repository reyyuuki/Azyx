import 'package:azyx/Database/isar_models/anime_details_data.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tokens.dart';
import 'package:azyx/Screens/Anime/Details/tokens/az_tones.dart';
import 'package:azyx/Screens/Anime/Details/widgets/hero_section.dart';
import 'package:azyx/Screens/Anime/Details/widgets/mobile_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleMedia = AnilistMediaData(
    id: '16498',
    title: 'Attack on Titan',
    titleRomaji: 'Shingeki no Kyojin',
    titleNative: '進撃の巨人',
    rating: '85',
    type: 'TV',
    status: 'FINISHED',
    favourites: 172000,
    episodes: 25,
    genres: ['Action', 'Fantasy', 'Drama'],
  );

  const testTones = AzTones(
    accent: Color(0xFFFFB1C1),
    onAccent: Color(0xFF3D0B1B),
    soft: Color(0x29FFB1C1),
    glow: Color(0x52FFB1C1),
  );

  Widget createTestWidget({
    required Size size,
    required Widget child,
  }) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: AzTonesProvider(
          tones: testTones,
          child: Scaffold(
            body: child,
          ),
        ),
      ),
    );
  }

  testWidgets('Renders properly on 390px mobile viewport without overflow',
      (tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestWidget(
        size: size,
        child: HeroSection(
          media: sampleMedia,
          primaryLabel: 'Start watching',
          listButtonLabel: 'Add to list',
          isListOn: false,
          isFavourite: false,
          onWatchTap: () {},
          onListTap: () {},
          onFavTap: () {},
        ),
      ),
    );

    expect(find.text('Attack on Titan'), findsOneWidget);
    expect(find.text('進撃の巨人'), findsOneWidget);
    expect(find.text('Finished'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Renders properly on 820px tablet viewport', (tester) async {
    const size = Size(820, 1180);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestWidget(
        size: size,
        child: HeroSection(
          media: sampleMedia,
          primaryLabel: 'Start watching',
          listButtonLabel: 'Add to list',
          isListOn: false,
          isFavourite: false,
          onWatchTap: () {},
          onListTap: () {},
          onFavTap: () {},
        ),
      ),
    );

    expect(find.text('Attack on Titan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Renders properly on 1280px desktop viewport with desktop actions',
      (tester) async {
    const size = Size(1280, 800);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestWidget(
        size: size,
        child: HeroSection(
          media: sampleMedia,
          primaryLabel: 'Start watching',
          listButtonLabel: 'Add to list',
          isListOn: false,
          isFavourite: false,
          onWatchTap: () {},
          onListTap: () {},
          onFavTap: () {},
        ),
      ),
    );

    expect(find.text('Attack on Titan'), findsOneWidget);
    expect(find.text('Start watching'), findsOneWidget);
    expect(find.text('Add to list'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mobile dock renders correctly on mobile viewport',
      (tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestWidget(
        size: size,
        child: MobileDock(
          primaryLabel: 'Continue watching',
          onWatchTap: () {},
          onListTap: () {},
          onFavTap: () {},
          isFavourite: true,
          isListOn: true,
        ),
      ),
    );

    expect(find.text('Continue watching'), findsOneWidget);
    expect(find.byIcon(Icons.playlist_add_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
