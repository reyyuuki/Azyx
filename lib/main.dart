import 'dart:ui';

import 'package:daizy_tv/Provider/manga_sources.dart';
import 'package:daizy_tv/Screens/Bottom_Menu/_profile.dart';
import 'package:daizy_tv/Screens/Bottom_Menu/_setting.dart';
import 'package:daizy_tv/Provider/theme_provider.dart';
import 'package:daizy_tv/auth/auth_provider.dart';
import 'package:daizy_tv/Hive_Data/appDatabase.dart';
import 'package:daizy_tv/Hive_Data/user.dart';
import 'package:daizy_tv/Screens/Anime/watch_screen.dart';
import 'package:daizy_tv/Screens/Lists/animelist.dart';
import 'package:daizy_tv/Screens/Lists/mangalist.dart';
import 'package:daizy_tv/Screens/Manga/mangaDetails.dart';
import 'package:daizy_tv/Screens/Manga/read.dart';
import 'package:daizy_tv/Screens/Anime/searchAnime.dart';
import 'package:daizy_tv/Screens/Manga/searchManga.dart';
import 'package:daizy_tv/Screens/settings/_about.dart';
import 'package:daizy_tv/Screens/settings/_languages.dart';
import 'package:daizy_tv/Screens/settings/_theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:daizy_tv/Screens/Anime/details.dart';
import 'package:daizy_tv/Screens/Home/_homepage.dart';
import 'package:daizy_tv/Screens/Manga/mangaPage.dart';
import 'package:daizy_tv/Screens/Anime/animePage.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

void main() async {
  // init the Hive
  await Hive.initFlutter();
  await Hive.openBox('mybox');
  await Hive.openBox("app-data");
  await dotenv.load(fileName: ".env");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Data()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AniListProvider()..tryAutoLogin()),
      ChangeNotifierProvider(
          create: (_) => MangaSourcesProvider()..allMangaSources())
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  UserDataBase? userDataBase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      color: Theme.of(context).colorScheme.surface,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
          // Anime - Routes
          case '/detailspage':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Details(id: id, image: image, tagg: tagg),
            );

          case '/stream':
            return MaterialPageRoute(
              builder: (context) => WatchPage(
                episodeSrc: args!['episodeSrc'],
                episodeData: args['episodeData'],
                currentEpisode: args['currentEpisode'],
                episodeTitle: args['episodeTitle'],
                subtitleTracks: args['subtitleTracks'],
                animeTitle: args['animeTitle'],
                activeServer: args['activeServer'],
                isDub: args['isDub'],
                animeId: int.parse(args['animeId']),
              ),
            );

          case '/searchAnime':
            final name = args?['name'] ?? '';
            return MaterialPageRoute(
              builder: (context) => SearchAnime(name: name),
            );

          // Manga - Routes
          case '/mangaDetail':
            final id = args?['id'] ?? '';
            final image = args?['image'] ?? '';
            final tagg = args?['tagg'] ?? '';
            return MaterialPageRoute(
              builder: (context) =>
                  Mangadetails(id: id, image: image, tagg: tagg),
            );

          case '/read':
            final mangaId = args?['mangaId'] ?? '';
            final chapterLink = args?['chapterLink'] ?? '';
            final image = args?['image'] ?? '';
            return MaterialPageRoute(
              builder: (context) => Read(
                mangaId: mangaId,
                chapterLink: chapterLink,
                image: image,
              ),
            );

          case '/searchManga':
            final name = args?['name'] ?? '';
            return MaterialPageRoute(
              builder: (context) => SearchManga(name: name),
            );

          // Main-Screen
          case '/homeScreen':
            return MaterialPageRoute(builder: (context) => const HomeScreen());

          //Bottom-Menu-Screens
          case './profile':
            return MaterialPageRoute(builder: (context) => const Profile());
          case './settings':
            return MaterialPageRoute(builder: (context) => const Setting());

          //Setting-Screens
          case './theme-changer':
            return MaterialPageRoute(builder: (context) => const ThemeChange());
          case './languages':
            return MaterialPageRoute(builder: (context) => const Languages());
          case './about':
            return MaterialPageRoute(builder: (context) => const About());

          //Lists
          case './animelist':
            return MaterialPageRoute(builder: (context) => const Animelist());
          case './mangalist':
            return MaterialPageRoute(builder: (context) => const Mangalist());

          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const Animepage(),
    const HomePage(),
    const Mangapage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.black.withOpacity(0.2),
            border: Border.all(
                color: Theme.of(context).colorScheme.inverseSurface, width: 2)),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabMargin: const EdgeInsets.symmetric(horizontal:  10),
            backgroundColor: Colors.transparent,
            tabs: [
              GButton(
                padding: const EdgeInsets.all(10),
                gap: 7,
                icon: Icons.movie,
                text: 'Anime',
                backgroundColor:
                    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6),
                rippleColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
                iconActiveColor: Theme.of(context).colorScheme.primary,
                iconColor: Theme.of(context).colorScheme.primary,
              ),
              GButton(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor:
                    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6),
                gap: 7,
                icon: Iconsax.home_15,
                text: 'Home',
                rippleColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
                iconColor: Theme.of(context).colorScheme.primary,
                iconActiveColor: Theme.of(context).colorScheme.primary,
              ),
              GButton(
                 padding: const EdgeInsets.all(10),
                backgroundColor:
                    Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6),
                gap: 7,
                icon: Icons.book_rounded,
                text: 'Home',
                iconColor: Theme.of(context).colorScheme.primary,
                rippleColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
                iconActiveColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
